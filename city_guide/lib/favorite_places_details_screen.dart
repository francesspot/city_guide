import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:drift/drift.dart' hide Column;
import 'features/database/favorite_places_database.dart';
import 'features/providers/favorite_places_provider.dart';
import 'features/providers/current_city_provider.dart';

class FavoritePlacesDetailsScreen extends ConsumerWidget {
  final FavoritePlace place;
  final String xid;
  static const route = '/favorite';

  const FavoritePlacesDetailsScreen({
    super.key,
    required this.place,
    required this.xid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    final repo = ref.read(favoritesRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Szczegóły atrakcji"),
        actions: [
          favoritesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (favorites) {
              final isFav = favorites.any((p) => p.xid == place.xid);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: () async {
                  final currentCity = ref.read(currentCityProvider);
                  final entry = FavoritePlacesCompanion(
                    xid: Value(place.xid),
                    name: Value(place.name),
                    city: Value(
                      currentCity.isNotEmpty ? currentCity : place.city,
                    ),
                    kinds: Value(place.kinds),
                    description: Value(place.description),
                    lat: Value(place.lat),
                    lon: Value(place.lon),
                  );

                  final nowFav = await repo.toggleFavorite(entry);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        nowFav
                            ? '❤️ Dodano do ulubionych'
                            : '❌ Usunięto z ulubionych',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.name,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if ((place.kinds ?? '').isNotEmpty)
              Text(
                "Kategorie: ${place.kinds?.replaceAll(',', ', ') ?? 'Brak kategorii'}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            const SizedBox(height: 16),
            if ((place.description ?? '').isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Opis:', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    place.description ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Text('Miasto:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              place.city.isNotEmpty ? place.city : 'Nieznane miasto',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Lokalizacja:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Szerokość geograficzna: ${place.lat.toStringAsFixed(2).replaceAll('.', ',')}°",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              "Długość geograficzna: ${place.lon.toStringAsFixed(2).replaceAll('.', ',')}°",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(place.lat, place.lon),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.city_guide',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(place.lat, place.lon),
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
      ),
    );
  }
}
