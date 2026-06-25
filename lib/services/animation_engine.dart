import 'dart:async';
import 'dart:math';

import 'hue_bridge.dart';
import '../models/hue_light.dart';

/// Odpowiednik animations.py — animacja „Impreza”.
class AnimationEngine {
  AnimationEngine({
    required HueBridge bridge,
    required Map<String, HueLight> Function() getLights,
  })  : _bridge = bridge,
        _getLights = getLights;

  final HueBridge _bridge;
  final Map<String, HueLight> Function() _getLights;
  final _random = Random();

  bool _stop = false;
  Future<void>? _running;

  bool get isRunning => _running != null;

  Future<void> start() {
    stop();
    _stop = false;
    _running = _party();
    return _running!;
  }

  void stop() {
    _stop = true;
    _running = null;
  }

  Map<String, HueLight> _reachableLights() {
    final lights = _getLights();
    return Map.fromEntries(
      lights.entries.where((e) => e.value.state.reachable),
    );
  }

  static bool _hasColor(HueLightState state) =>
      state.hue != null && state.sat != null;

  Future<void> _setLight(String lightId, Map<String, dynamic> kwargs) async {
    if (_stop) return;
    try {
      await _bridge.setLightState(lightId, {'on': true, 'transitiontime': 2, ...kwargs});
    } catch (_) {}
  }

  Future<bool> _sleep(double seconds) async {
    await Future.delayed(Duration(milliseconds: (seconds * 1000).round()));
    return !_stop;
  }

  Future<void> _party() async {
    while (!_stop) {
      final lights = _reachableLights();
      if (lights.isEmpty) {
        if (!await _sleep(1)) break;
        continue;
      }

      for (final entry in lights.entries) {
        if (_stop) return;
        final st = entry.value.state;
        if (_hasColor(st)) {
          await _setLight(entry.key, {
            'hue': _random.nextInt(65536),
            'sat': _random.nextInt(75) + 180,
            'bri': _random.nextInt(105) + 150,
          });
        } else {
          await _setLight(entry.key, {'bri': _random.nextInt(175) + 80});
        }
        await Future.delayed(const Duration(milliseconds: 50));
      }

      if (!await _sleep(0.35)) break;
    }
    _running = null;
  }
}
