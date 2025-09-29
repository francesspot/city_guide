import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'favorite_places_details_screen.dart';
import 'features/database/favorite_places_database.dart';
import 'features/providers/favorite_places_provider.dart';

class FavoritePlacesScreen extends ConsumerWidget {
  const FavoritePlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione miejsca'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              context.push('/favorites_map');
            },
          ),
        ],
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Błąd: $error')),
        data: (favorites) {
          if (favorites.isEmpty) {
            return const Center(child: Text('Brak ulubionych miejsc.'));
          }

          final Map<String, List<FavoritePlace>> groupedByCity = {};
          for (var place in favorites) {
            final cityKey = (place.city.isEmpty)
                ? 'Nieznane miasto'
                : place.city;
            groupedByCity.putIfAbsent(cityKey, () => []).add(place);
          }

          final sortedCities = groupedByCity.keys.toList()..sort();

          return ListView.builder(
            itemCount: sortedCities.length,
            itemBuilder: (context, index) {
              final city = sortedCities[index];
              final places = groupedByCity[city]!
                ..sort((a, b) => a.name.compareTo(b.name));

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text(
                    city,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: places.map((place) {
                    return ListTile(
                      leading: const Icon(Icons.place, color: Colors.red),
                      title: Text(place.name),
                      subtitle: Text(
                        place.kinds != null
                            ? place.kinds!
                                  .split(',')
                                  .map((e) => e.trim())
                                  .join(', ')
                            : 'Brak kategorii',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await ref
                              .read(favoritesRepositoryProvider)
                              .deleteFavorite(place.xid);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("❌ Usunięto z ulubionych"),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        context.push(
                          "${FavoritePlacesDetailsScreen.route}/${place.xid}",
                          extra: place,
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
