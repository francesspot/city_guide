import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "features/providers/attraction_details_provider.dart";

class DetailsScreen extends ConsumerWidget {
  final String xid;
  static const route = "/place";

  const DetailsScreen({super.key, required this.xid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attractionAsync = ref.watch(attractionDetailsProvider(xid));

    return Scaffold(
      appBar: AppBar(title: const Text("Szczegóły atrakcji")),
      body: attractionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Błąd ładowania: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(attractionDetailsProvider(xid)),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
        data: (attraction) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attraction.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (attraction.kinds.isNotEmpty &&
                    attraction.kinds != "Unknown")
                  Text(
                    "Kategorie: ${attraction.kinds.replaceAll(',', ', ')}",
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                  ),
                const SizedBox(height: 16),
                if (attraction.description.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Opis:",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        attraction.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                Text(
                  "Lokalizacja:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Szerokość geograficzna: ${attraction.lat.toStringAsFixed(4)}°",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  "Długość geograficzna: ${attraction.lon.toStringAsFixed(4)}°",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(attraction.lat, attraction.lon),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.city_guide',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(attraction.lat, attraction.lon),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
