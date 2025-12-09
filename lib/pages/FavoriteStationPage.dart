import 'package:flutter/material.dart';
import '../interface/station.dart';
import '../services/StationService.dart';
import '../components/ItemStation.dart';
import '../pages/SchedulePage.dart';
import '../utils/FavoriteStorage.dart';

class FavoriteStationPage extends StatefulWidget {
  const FavoriteStationPage({super.key});

  @override
  State<FavoriteStationPage> createState() => _FavoriteStationPageState();
}

class _FavoriteStationPageState extends State<FavoriteStationPage> {
  late Future<List<Station>> stationFuture;
  Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    stationFuture = StationService().fetchStations();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await FavoriteStorage.loadFavorites();
    setState(() {
      favoriteIds = favs;
    });
  }

  Future<void> _toggleFavorite(String stationId) async {
    setState(() {
      if (favoriteIds.contains(stationId)) {
        favoriteIds.remove(stationId);
      } else {
        favoriteIds.add(stationId);
      }
    });
    await FavoriteStorage.saveFavorites(favoriteIds);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Station>>(
      future: stationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final allStations = snapshot.data ?? [];
        final favStations = allStations
            .where((s) => favoriteIds.contains(s.id))
            .toList();

        if (favStations.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada stasiun favorit.\nTambahkan dari tab 'Semua Stasiun'.",
              textAlign: TextAlign.center,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadFavorites,
          child: ListView.builder(
            itemCount: favStations.length,
            itemBuilder: (context, index) {
              final station = favStations[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SchedulePage(station: station),
                    ),
                  );
                },
                child: ItemStation(
                  station: station,
                  isFavorite: favoriteIds.contains(station.id),
                  onFavoriteToggle: () => _toggleFavorite(station.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
