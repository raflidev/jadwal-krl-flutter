import 'package:flutter/material.dart';
import '../interface/station.dart';

class ItemStation extends StatelessWidget {
  final Station station;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ItemStation({
    super.key,
    required this.station,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          station.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Kode: ${station.id} | Type: ${station.type}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(isFavorite ? Icons.star : Icons.star_border),
              color: isFavorite ? Colors.amber : Colors.grey,
              onPressed: onFavoriteToggle,
            ),
          ],
        ),
      ),
    );
  }
}
