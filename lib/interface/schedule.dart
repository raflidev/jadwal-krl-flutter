class Schedule {
  final String id;
  final String stationId;
  final String originId;
  final String destinationId;
  final String trainId;
  final String line;
  final String route;
  final DateTime departsAt;
  final DateTime arrivesAt;
  final String color;

  Schedule({
    required this.id,
    required this.stationId,
    required this.originId,
    required this.destinationId,
    required this.trainId,
    required this.line,
    required this.route,
    required this.departsAt,
    required this.arrivesAt,
    required this.color,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json["id"],
      stationId: json["station_id"],
      originId: json["station_origin_id"],
      destinationId: json["station_destination_id"],
      trainId: json["train_id"],
      line: json["line"],
      route: json["route"],
      departsAt: DateTime.parse(json["departs_at"]),
      arrivesAt: DateTime.parse(json["arrives_at"]),
      color: json["metadata"]?["origin"]?["color"] ?? "#000000",
    );
  }
}
