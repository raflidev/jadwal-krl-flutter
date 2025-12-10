import 'package:flutter/material.dart';
import '../interface/station.dart';
import '../services/StationService.dart';
import '../components/ItemStation.dart';
import '../utils/FavoriteStorage.dart';
import 'SchedulePage.dart';

class StationPage extends StatefulWidget {
  const StationPage({super.key});

  @override
  State<StationPage> createState() => _StationPageState();
}

class _StationPageState extends State<StationPage> {
  late Future<List<Station>> stationFuture;
  Set<String> favoriteIds = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    stationFuture = StationService().fetchStations();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

        final stations = snapshot.data ?? [];

        // filter berdasarkan search
        final query = _searchQuery.toLowerCase().trim();
        final filtered = query.isEmpty
            ? stations
            : stations.where((s) {
                final name = s.name.toLowerCase();
                final id = s.id.toLowerCase();
                return name.contains(query) || id.contains(query);
              }).toList();

        return Column(
          children: [
            // search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Cari stasiun atau kode (mis. TB, Tambun)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),

            // list stasiun
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        "Stasiun tidak ditemukan.",
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final station = filtered[index];
                        final isFav = favoriteIds.contains(station.id);

                        return ItemStation(
                          station: station,
                          isFavorite: isFav,
                          onFavoriteToggle: () => _toggleFavorite(station.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SchedulePage(station: station),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
