class HueLightState {
  const HueLightState({
    required this.on,
    required this.reachable,
    this.bri = 128,
    this.ct,
    this.hue,
    this.sat,
  });

  final bool on;
  final bool reachable;
  final int bri;
  final int? ct;
  final int? hue;
  final int? sat;

  bool get supportsCt => ct != null;
  bool get supportsColor => hue != null && sat != null;

  HueLightState copyWith({
    bool? on,
    bool? reachable,
    int? bri,
    int? ct,
    int? hue,
    int? sat,
  }) {
    return HueLightState(
      on: on ?? this.on,
      reachable: reachable ?? this.reachable,
      bri: bri ?? this.bri,
      ct: ct ?? this.ct,
      hue: hue ?? this.hue,
      sat: sat ?? this.sat,
    );
  }

  factory HueLightState.fromJson(Map<String, dynamic> json) {
    return HueLightState(
      on: json['on'] as bool? ?? false,
      reachable: json['reachable'] as bool? ?? false,
      bri: json['bri'] as int? ?? 128,
      ct: json['ct'] as int?,
      hue: json['hue'] as int?,
      sat: json['sat'] as int?,
    );
  }
}

class HueLight {
  const HueLight({
    required this.id,
    required this.name,
    required this.state,
  });

  final String id;
  final String name;
  final HueLightState state;

  HueLight copyWith({String? id, String? name, HueLightState? state}) {
    return HueLight(
      id: id ?? this.id,
      name: name ?? this.name,
      state: state ?? this.state,
    );
  }

  factory HueLight.fromEntry(String id, Map<String, dynamic> json) {
    return HueLight(
      id: id,
      name: json['name'] as String? ?? 'Lampa $id',
      state: HueLightState.fromJson(
        Map<String, dynamic>.from(json['state'] as Map? ?? {}),
      ),
    );
  }
}
