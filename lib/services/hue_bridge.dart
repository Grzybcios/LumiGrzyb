import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../models/hue_light.dart';

/// Odpowiednik bridge.py — komunikacja z mostkiem Philips Hue.
class HueBridge {
  HueBridge({this.ip = '', this.apiKey = ''});

  String ip;
  String apiKey;
  static const double timeout = 5.0;

  static http.Client _createClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    return IOClient(httpClient);
  }

  String getBaseUrl() => 'https://$ip/api';

  Future<List<String>> discover() async {
    final client = _createClient();
    try {
      final response = await client
          .get(Uri.parse('https://discovery.meethue.com'))
          .timeout(Duration(seconds: timeout.round()));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((e) => (e as Map<String, dynamic>)['internalipaddress'] as String?)
            .whereType<String>()
            .toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Błąd podczas automatycznego wykrywania: $e');
    } finally {
      client.close();
    }
    return [];
  }

  Future<({String? apiKey, String? error})> pair(String ipAddress) async {
    final client = _createClient();
    final url = Uri.parse('https://$ipAddress/api');
    final payload = jsonEncode({'devicetype': 'hue_desktop_app#pc_control'});

    try {
      final response = await client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: payload,
          )
          .timeout(Duration(seconds: timeout.round()));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final result = data[0] as Map<String, dynamic>;
          if (result.containsKey('success')) {
            ip = ipAddress;
            apiKey = result['success']['username'] as String;
            return (apiKey: apiKey, error: null);
          } else if (result.containsKey('error')) {
            final error = result['error'] as Map<String, dynamic>;
            final errorType = error['type'];
            final errorDesc = error['description'] as String?;
            if (errorType == 101) {
              return (
                apiKey: null,
                error:
                    'Przycisk parowania na mostku nie został naciśnięty. Naciśnij go i spróbuj ponownie.',
              );
            }
            return (apiKey: null, error: 'Błąd mostka: $errorDesc');
          }
        }
      }
      return (apiKey: null, error: 'Nieoczekiwana odpowiedź z mostka.');
    } on SocketException {
      return (
        apiKey: null,
        error:
            'Błąd połączenia. Upewnij się, że podany adres IP jest prawidłowy i urządzenie jest podłączone do sieci.',
      );
    } on TimeoutException {
      return (
        apiKey: null,
        error:
            'Upłynął limit czasu połączenia. Sprawdź, czy adres IP jest poprawny i czy mostek jest w tej samej sieci Wi-Fi.',
      );
    } catch (e) {
      return (apiKey: null, error: 'Błąd parowania: $e');
    } finally {
      client.close();
    }
  }

  Future<Map<String, HueLight>> getLights() async {
    if (ip.isEmpty || apiKey.isEmpty) {
      throw ArgumentError('Brak adresu IP lub klucza API. Skonfiguruj połączenie.');
    }

    final client = _createClient();
    final url = Uri.parse('${getBaseUrl()}/$apiKey/lights');
    try {
      final response = await client.get(url).timeout(Duration(seconds: timeout.round()));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0] is Map && (data[0] as Map).containsKey('error')) {
          final err = (data[0] as Map)['error'] as Map;
          throw Exception(
            'Błąd autoryzacji: ${err['description'] ?? 'Niepoprawny klucz API'}',
          );
        }
        final map = data as Map<String, dynamic>;
        return map.map((id, json) => MapEntry(id, HueLight.fromEntry(id, json)));
      }
      throw Exception('Błąd HTTP: ${response.statusCode}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Nie można połączyć się z mostkiem: $e');
    } finally {
      client.close();
    }
  }

  Future<dynamic> setLightState(String lightId, Map<String, dynamic> state) async {
    if (ip.isEmpty || apiKey.isEmpty) {
      throw ArgumentError('Brak adresu IP lub klucza API.');
    }

    final client = _createClient();
    final url = Uri.parse('${getBaseUrl()}/$apiKey/lights/$lightId/state');
    try {
      final response = await client
          .put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(state),
          )
          .timeout(Duration(seconds: timeout.round()));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Błąd HTTP: ${response.statusCode}');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Nie można wysłać polecenia do lampy $lightId: $e');
    } finally {
      client.close();
    }
  }
}
