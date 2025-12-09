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
    return Station(
      uid: json["uid"],
      id: json["id"],
      name: json["name"],
      type: json["type"],
      active: json["metadata"]["active"],
    );
  }
}
