import 'package:flutter/material.dart';
import '../interface/station.dart';

class StationItem extends StatelessWidget {
  final Station station;

  const StationItem({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(station.name),
        subtitle: Text("Kode: ${station.id} | Type: ${station.type}"),
        trailing: Icon(
          station.active ? Icons.check_circle : Icons.cancel,
          color: station.active ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
