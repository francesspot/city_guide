import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "features/providers/attraction_provider.dart";

class DetailsScreen extends ConsumerWidget {
  final String id;
  static const route = "/place";

  const DetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attractions = ref.watch(attractionProvider);
    final attraction = attractions.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception("Atrakcja nie została znaleziona"),
    );

    return Scaffold(
      appBar: AppBar(title: Text(attraction.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attraction.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Kategoria: ${attraction.category}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              attraction.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              "Współrzędne lokalizacji: (${attraction.lat}, ${attraction.lng})",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(attraction.lat, attraction.lng),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.city_guide',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(attraction.lat, attraction.lng),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
