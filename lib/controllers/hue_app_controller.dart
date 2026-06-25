import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_config.dart';
import '../models/hue_light.dart';
import '../services/animation_engine.dart';
import '../services/color_utils.dart';
import '../services/config_service.dart';
import '../services/hue_bridge.dart';

enum StatusTone { normal, success, error, party, partyStopped }

/// Logika aplikacji — odpowiednik HueApp z ui.py (bez widgetów).
class HueAppController extends ChangeNotifier {
  HueAppController({
    ConfigService? configService,
    HueBridge? bridge,
  })  : _configService = configService ?? ConfigService(),
        _bridge = bridge ?? HueBridge() {
    _animations = AnimationEngine(
      bridge: _bridge,
      getLights: () => lights,
    );
    _init();
  }

  final ConfigService _configService;
  final HueBridge _bridge;
  late final AnimationEngine _animations;

  AppConfig _config = const AppConfig();
  Map<String, HueLight> lights = {};
  String statusMessage = 'Inicjalizacja…';
  StatusTone statusTone = StatusTone.normal;
  bool connDetailsVisible = false;
  bool partyRunning = false;
  int globalBrightness = 128;
  String ipAddress = '';
  bool isDiscovering = false;
  bool isPairing = false;

  Timer? _refreshTimer;
  bool _running = false;
  final Map<String, Timer> _debounceTimers = {};
  final Set<String> _debouncingKeys = {};
  // Po wysłaniu wartości mostek potrzebuje chwili, zanim zwróci nowy stan —
  // w tym czasie zachowujemy lokalną (optymistyczną) wartość suwaka.
  final Map<String, DateTime> _settleUntil = {};

  HueBridge get bridge => _bridge;
  bool get isConfigured => _bridge.ip.isNotEmpty && _bridge.apiKey.isNotEmpty;

  Future<void> _init() async {
    _config = _configService.load();
    _bridge.ip = _config.bridgeIp;
    _bridge.apiKey = _config.apiKey;
    ipAddress = _bridge.ip;

    if (isConfigured) {
      startBackgroundRefresh();
    } else {
      setStatus(
        'Nieskonfigurowano — wprowadź IP lub użyj autowykrywania.',
        tone: StatusTone.error,
      );
    }
    notifyListeners();
  }

  void setStatus(String text, {StatusTone tone = StatusTone.normal}) {
    statusMessage = text;
    statusTone = tone;
    notifyListeners();
  }

  void toggleConnDetails() {
    connDetailsVisible = !connDetailsVisible;
    notifyListeners();
  }

  void showConnDetails() {
    if (!connDetailsVisible) {
      connDetailsVisible = true;
      notifyListeners();
    }
  }

  Future<String?> discover() async {
    isDiscovering = true;
    setStatus('Szukanie mostków Hue w sieci…');
    notifyListeners();

    final bridges = await _bridge.discover();
    isDiscovering = false;

    if (bridges.isNotEmpty) {
      final foundIp = bridges.first;
      ipAddress = foundIp;
      showConnDetails();
      setStatus(
        'Znaleziono mostek — IP: $foundIp. Kliknij „Paruj”.',
        tone: StatusTone.success,
      );
      notifyListeners();
      return foundIp;
    }

    showConnDetails();
    setStatus('Nie znaleziono mostka — wpisz IP ręcznie.', tone: StatusTone.error);
    notifyListeners();
    return null;
  }

  Future<({bool success, String? error})> pair(String ip) async {
    if (ip.trim().isEmpty) {
      showConnDetails();
      return (success: false, error: 'Wprowadź najpierw adres IP mostka.');
    }

    isPairing = true;
    setStatus('Próba parowania z mostkiem…');
    notifyListeners();

    final result = await _bridge.pair(ip.trim());
    isPairing = false;

    if (result.apiKey != null) {
      _config = AppConfig(bridgeIp: ip.trim(), apiKey: result.apiKey!);
      _configService.save(_config);
      ipAddress = ip.trim();
      setStatus('Sparowano! Pobieranie stanu lamp…', tone: StatusTone.success);
      startBackgroundRefresh();
      notifyListeners();
      return (success: true, error: null);
    }

    setStatus(result.error ?? 'Błąd parowania', tone: StatusTone.error);
    notifyListeners();
    return (success: false, error: result.error ?? 'Wystąpił nieznany błąd podczas parowania.');
  }

  void startBackgroundRefresh() {
    _running = true;
    lights = {};
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshLights());
    _refreshLights();
  }

  Future<void> _refreshLights() async {
    if (!_running) return;
    try {
      final data = await _bridge.getLights();
      lights = _mergePreservingPendingEdits(data);
      setStatus('Połączono — stan lamp zaktualizowany.', tone: StatusTone.success);
      notifyListeners();
    } catch (e) {
      setStatus('Błąd synchronizacji: $e', tone: StatusTone.error);
      notifyListeners();
    }
  }

  /// Czy dla danego klucza trwa jeszcze regulacja, wysyłka lub okno
  /// „ustabilizowania" (gdy mostek nie zwrócił jeszcze nowej wartości).
  bool _isPending(String key) {
    if (_debounceTimers.containsKey(key)) return true;
    final until = _settleUntil[key];
    return until != null && DateTime.now().isBefore(until);
  }

  /// Zachowuje lokalne (optymistyczne) wartości suwaków, które są właśnie
  /// regulowane lub wysyłane, by odświeżenie z mostka ich nie cofało.
  Map<String, HueLight> _mergePreservingPendingEdits(Map<String, HueLight> incoming) {
    final groupBriPending = _isPending('group_bri');
    return {
      for (final entry in incoming.entries)
        entry.key: _mergeLight(entry.key, entry.value, groupBriPending),
    };
  }

  HueLight _mergeLight(String id, HueLight incoming, bool groupBriPending) {
    final local = lights[id];
    if (local == null) return incoming;

    var state = incoming.state;
    if (groupBriPending || _isPending('${id}_bri')) {
      state = state.copyWith(bri: local.state.bri);
    }
    if (_isPending('${id}_ct')) {
      state = state.copyWith(ct: local.state.ct);
    }
    return incoming.copyWith(state: state);
  }

  bool isDebouncing(String lightId, String param) =>
      _debouncingKeys.contains('${lightId}_$param');

  void onSliderMove(String lightId, String param, double value) {
    final intVal = value.round();
    final key = '${lightId}_$param';

    // Optymistyczna aktualizacja — suwak (jasność / temperatura) reaguje
    // natychmiast, bez czekania na cykliczne odświeżenie stanu z mostka.
    final local = lights[lightId];
    if (local != null) {
      final state = switch (param) {
        'bri' => local.state.copyWith(bri: intVal),
        'ct' => local.state.copyWith(ct: intVal),
        _ => local.state,
      };
      lights = {...lights, lightId: local.copyWith(state: state)};
    }

    _settleUntil[key] = DateTime.now().add(const Duration(seconds: 2));
    _debounceTimers[key]?.cancel();
    _debouncingKeys.add(key);
    _debounceTimers[key] = Timer(const Duration(milliseconds: 300), () {
      _debouncingKeys.remove(key);
      _debounceTimers.remove(key);
      _sendDebouncedValue(lightId, param, intVal);
    });
    notifyListeners();
  }

  void onGroupBrightness(double value) {
    globalBrightness = value.round();
    // Mostek potrzebuje chwili, zanim zwróci zaktualizowaną jasność.
    _settleUntil['group_bri'] = DateTime.now().add(const Duration(seconds: 2));

    // Optymistyczna aktualizacja — suwaki lamp reagują natychmiast,
    // bez czekania na cykliczne odświeżenie stanu z mostka.
    lights = {
      for (final entry in lights.entries)
        entry.key: entry.value.state.reachable
            ? entry.value.copyWith(
                state: entry.value.state.copyWith(bri: globalBrightness),
              )
            : entry.value,
    };

    _debounceTimers['group_bri']?.cancel();
    _debounceTimers['group_bri'] = Timer(const Duration(milliseconds: 300), () {
      _debounceTimers.remove('group_bri');
      _sendGroupBrightness(globalBrightness);
    });
    notifyListeners();
  }

  Future<void> _sendDebouncedValue(String lightId, String param, int val) async {
    try {
      await _bridge.setLightState(lightId, {param: val});
    } catch (e) {
      // ignore: avoid_print
      print('Błąd zmiany $param dla lampy $lightId: $e');
    }
  }

  Future<void> toggleLight(String lightId, bool targetOn) async {
    try {
      await _bridge.setLightState(lightId, {'on': targetOn});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> chooseColor(String lightId, double r, double g, double b) async {
    final converted = ColorUtils.rgbToHue(r: r, g: g, b: b);
    await _bridge.setLightState(lightId, {
      'hue': converted.hue,
      'sat': converted.sat,
      'bri': converted.bri,
      'on': true,
    });
  }

  Future<void> groupPower(bool targetOn) async {
    if (lights.isEmpty) return;
    final errors = <String>[];
    for (final id in lights.keys) {
      try {
        await _bridge.setLightState(id, {'on': targetOn});
      } catch (e) {
        errors.add('Lampa $id: $e');
      }
    }
    if (errors.isNotEmpty) {
      throw Exception('Wystąpiły problemy ze sterowaniem częścią lamp:\n${errors.join('\n')}');
    }
  }

  Future<void> _sendGroupBrightness(int val) async {
    if (lights.isEmpty) return;
    for (final entry in lights.entries) {
      if (entry.value.state.reachable) {
        try {
          await _bridge.setLightState(entry.key, {'bri': val});
        } catch (e) {
          // ignore: avoid_print
          print('Błąd ustawiania jasności grupowej dla lampy ${entry.key}: $e');
        }
      }
    }
  }

  Future<void> toggleParty() async {
    if (partyRunning) {
      _animations.stop();
      partyRunning = false;
      setStatus('Impreza zatrzymana.', tone: StatusTone.partyStopped);
      notifyListeners();
      return;
    }

    if (lights.isEmpty) {
      throw StateError('Brak podłączonych lamp. Sparuj się z mostkiem i poczekaj na listę lamp.');
    }

    partyRunning = true;
    setStatus('Impreza uruchomiona.', tone: StatusTone.party);
    notifyListeners();
    // Uruchamiamy bez await — pętla animacji trwa do zatrzymania.
    unawaited(_animations.start());
  }

  void disposeController() {
    _animations.stop();
    _running = false;
    _refreshTimer?.cancel();
    for (final t in _debounceTimers.values) {
      t.cancel();
    }
    _debounceTimers.clear();
    _settleUntil.clear();
  }
}
