import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_map/flutter_map.dart";
import "package:go_router/go_router.dart";
import "package:latlong2/latlong.dart";
import "favorite_places_details_screen.dart";
import "features/providers/favorite_places_provider.dart";

class FavoritePlacesMapScreen extends ConsumerWidget {
  const FavoritePlacesMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa ulubionych miejsc"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Błąd: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(favoritesProvider),
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return const Center(
              child: Text("Brak ulubionych miejsc do wyświetlenia na mapie"),
            );
          }

          final cities = favorites.map((place) => place.city).toSet();
          final hasMultipleCities = cities.length > 1;

          final avgLat =
              favorites.map((a) => a.lat).reduce((a, b) => a + b) /
              favorites.length;
          final avgLon =
              favorites.map((a) => a.lon).reduce((a, b) => a + b) /
              favorites.length;

          return FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(avgLat, avgLon),
              initialZoom: hasMultipleCities ? 6.0 : 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.city_guide',
              ),
              MarkerLayer(
                markers: favorites.map((place) {
                  return Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(place.lat, place.lon),
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
                            title: Text(place.name),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(place.kinds ?? 'Brak kategorii'),
                                const SizedBox(height: 8),
                                Text(
                                  "Miasto: ${place.city.isNotEmpty ? place.city : 'Nieznane'}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  context.push(
                                    "${FavoritePlacesDetailsScreen.route}/${place.xid}",
                                    extra: place,
                                  );
                                },
                                child: const Text('Szczegóły'),
                              ),
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
