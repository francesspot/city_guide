import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:drift/drift.dart" hide Column;
import "features/providers/attraction_details_provider.dart";
import "features/providers/favorite_places_provider.dart";
import "features/providers/current_city_provider.dart";
import "features/database/favorite_places_database.dart";

class DetailsScreen extends ConsumerWidget {
  final String xid;
  static const route = "/place";

  const DetailsScreen({super.key, required this.xid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attractionAsync = ref.watch(attractionDetailsProvider(xid));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Szczegóły atrakcji"),
        actions: [
          attractionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
            data: (attraction) {
              final favoritesAsync = ref.watch(favoritesProvider);

              return favoritesAsync.when(
                loading: () => const Icon(Icons.favorite_border),
                error: (e, _) => const Icon(Icons.error),
                data: (favorites) {
                  final isFav = favorites.any(
                    (place) => place.xid == attraction.xid,
                  );

                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: () async {
                      final currentCity = ref.read(currentCityProvider);
                      final repo = ref.read(favoritesRepositoryProvider);

                      final entry = FavoritePlacesCompanion(
                        xid: Value(attraction.xid),
                        name: Value(attraction.name),
                        city: Value(currentCity.isNotEmpty ? currentCity : ''),
                        kinds: Value(
                          attraction.kinds.isNotEmpty ? attraction.kinds : null,
                        ),
                        description: Value(
                          attraction.description.isNotEmpty
                              ? attraction.description
                              : null,
                        ),
                        lat: Value(attraction.lat),
                        lon: Value(attraction.lon),
                      );

                      final isNowFavorite = await repo.toggleFavorite(entry);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            isNowFavorite
                                ? "❤️ Dodano do ulubionych"
                                : "❌ Usunięto z ulubionych",
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
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
          final currentCity = ref.watch(currentCityProvider);

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
                    attraction.kinds != "Brak kategorii")
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
                const SizedBox(height: 16),
                Text("Miasto:", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  currentCity.isNotEmpty ? currentCity : 'Nieznane miasto',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Lokalizacja:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Szerokość geograficzna: ${attraction.lat.toStringAsFixed(2).replaceAll('.', ',')}°",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  "Długość geograficzna: ${attraction.lon.toStringAsFixed(2).replaceAll('.', ',')}°",
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
