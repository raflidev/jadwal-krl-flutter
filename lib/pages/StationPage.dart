import 'package:flutter/material.dart';
import '../interface/station.dart';
import '../services/StationService.dart';
import '../components/ItemStation.dart';

class StationPage extends StatefulWidget {
  const StationPage({super.key});

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  late Future<List<Station>> stationFuture;

  @override
  void initState() {
    super.initState();
    stationFuture = StationService().fetchStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Stasiun KRL")),
      body: FutureBuilder<List<Station>>(
        future: stationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final stations = snapshot.data ?? [];

          return ListView.builder(
            itemCount: stations.length,
            itemBuilder: (context, index) {
              return StationItem(station: stations[index]);
            },
          );
        },
      ),
    );
  }
}
