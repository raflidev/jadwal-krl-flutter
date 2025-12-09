class Station {
  final String uid;
  final String id;
  final String name;
  final String type;
  final bool active;

  Station({
    required this.uid,
    required this.id,
    required this.name,
    required this.type,
    required this.active,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    final meta = json['metadata'] as Map<String, dynamic>?;

    return Station(
      uid: (json['uid'] ?? '').toString(),
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      active: (meta?['active'] as bool?) ?? false,
    );
  }
}
