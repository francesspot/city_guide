import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "features/providers/city_attractions_provider.dart";
import "features/providers/current_city_provider.dart";
import "features/providers/radius_provider.dart";

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentCity = ref.watch(currentCityProvider);
    final radius = ref.watch(radiusProvider);
    final attractionsAsync = ref.watch(
      cityAttractionsProvider((currentCity, radius)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mapa atrakcji - $currentCity"),
            Text(
              "Promień: ${(radius / 1000).toStringAsFixed(1)} km",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: attractionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Błąd: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                  cityAttractionsProvider((currentCity, radius)),
                ),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
        data: (attractions) {
          if (attractions.isEmpty) {
            return const Center(
              child: Text("Brak atrakcji do wyświetlenia na mapie"),
            );
          }

          final avgLat =
              attractions.map((a) => a.lat).reduce((a, b) => a + b) /
              attractions.length;
          final avgLon =
              attractions.map((a) => a.lon).reduce((a, b) => a + b) /
              attractions.length;

          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(avgLat, avgLon),
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.city_guide',
              ),
              MarkerLayer(
                markers: attractions.map((attraction) {
                  return Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(attraction.lat, attraction.lon),
                    child: IconButton(
                      icon: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(attraction.name),
                            content: Text(attraction.kinds.split(',').first),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Zamknij'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
