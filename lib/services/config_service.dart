import 'dart:convert';
import 'dart:io';

import '../models/app_config.dart';

/// Odpowiednik config.py — zapis/odczyt config.json.
class ConfigService {
  static const configFileName = 'config.json';
  static const _appFolder = 'LumiGrzyb';

  /// Katalog na dane użytkownika (zapisywalny także po instalacji w Program Files).
  /// Windows: %APPDATA%\LumiGrzyb, w innym wypadku katalog domowy.
  String get _configDir {
    final env = Platform.environment;
    final base = env['APPDATA'] ??
        env['XDG_CONFIG_HOME'] ??
        env['HOME'] ??
        Directory.current.path;
    return '$base${Platform.pathSeparator}$_appFolder';
  }

  String get _path => '$_configDir${Platform.pathSeparator}$configFileName';

  AppConfig load() {
    const defaults = AppConfig();
    var file = File(_path);
    if (!file.existsSync()) {
      // Zgodność wstecz — odczyt z dawnej lokalizacji (katalog roboczy).
      final legacy = File(
        '${Directory.current.path}${Platform.pathSeparator}$configFileName',
      );
      if (!legacy.existsSync()) return defaults;
      file = legacy;
    }

    try {
      final json = jsonDecode(file.readAsStringSync(encoding: utf8)) as Map<String, dynamic>;
      final config = AppConfig.fromJson(json);
      return AppConfig(
        bridgeIp: config.bridgeIp.isNotEmpty ? config.bridgeIp : defaults.bridgeIp,
        apiKey: config.apiKey.isNotEmpty ? config.apiKey : defaults.apiKey,
      );
    } catch (_) {
      return defaults;
    }
  }

  bool save(AppConfig config) {
    try {
      final dir = Directory(_configDir);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File(_path).writeAsStringSync(
        const JsonEncoder.withIndent('    ').convert(config.toJson()),
        encoding: utf8,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
