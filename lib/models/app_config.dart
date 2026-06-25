class AppConfig {
  const AppConfig({this.bridgeIp = '', this.apiKey = ''});

  final String bridgeIp;
  final String apiKey;

  Map<String, String> toJson() => {
        'bridge_ip': bridgeIp,
        'api_key': apiKey,
      };

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      bridgeIp: json['bridge_ip'] as String? ?? '',
      apiKey: json['api_key'] as String? ?? '',
    );
  }

  AppConfig copyWith({String? bridgeIp, String? apiKey}) {
    return AppConfig(
      bridgeIp: bridgeIp ?? this.bridgeIp,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}
