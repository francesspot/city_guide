import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../database/favorite_places_database.dart';
import '../models/attraction.dart';
import 'city_attractions_provider.dart';
import 'current_city_provider.dart';
import 'radius_provider.dart';
import 'favorite_places_provider.dart';

final filterQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoriesProvider = StateProvider<Set<String>>(
  (ref) => <String>{},
);

final filteredCityAttractionsProvider =
    Provider.autoDispose<AsyncValue<List<Attraction>>>((ref) {
      final currentCity = ref.watch(currentCityProvider);
      final radius = ref.watch(radiusProvider);
      final attractionsAsync = ref.watch(
        cityAttractionsProvider((currentCity, radius)),
      );
      final queryRaw = ref.watch(filterQueryProvider).toLowerCase().trim();
      final selected = ref.watch(selectedCategoriesProvider);

      ref.listen(currentCityProvider, (previousCity, nextCity) {
        if (nextCity.isNotEmpty && previousCity != nextCity) {
          ref.read(filterQueryProvider.notifier).state = '';
          ref.read(selectedCategoriesProvider.notifier).state = <String>{};
        }
      });

      return attractionsAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
        data: (list) {
          if (queryRaw.isEmpty && selected.isEmpty) {
            return AsyncValue.data(list);
          }

          final query = queryRaw;
          final filtered = list.where((a) {
            final name = a.name.toLowerCase();
            final kindsTokens = a.kinds
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .where((s) => s.isNotEmpty)
                .toList();

            final matchesQuery = query.isEmpty || name.contains(query);

            final matchesCategory =
                selected.isEmpty ||
                kindsTokens.any((k) {
                  return selected.any((sel) => k.startsWith(sel.toLowerCase()));
                });

            return matchesQuery && matchesCategory;
          }).toList();

          return AsyncValue.data(filtered);
        },
      );
    });

final filteredFavoritesProvider =
    Provider.autoDispose<AsyncValue<List<FavoritePlace>>>((ref) {
      final favoritesAsync = ref.watch(favoritesProvider);
      final queryRaw = ref.watch(filterQueryProvider).toLowerCase().trim();
      final selected = ref.watch(selectedCategoriesProvider);

      return favoritesAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (e, s) => AsyncValue.error(e, s),
        data: (list) {
          if (queryRaw.isEmpty && selected.isEmpty) {
            return AsyncValue.data(list);
          }

          final query = queryRaw;
          final filtered = list.where((p) {
            final name = p.name.toLowerCase();
            final city = p.city.toLowerCase();
            final kindsTokens = (p.kinds ?? '')
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .where((s) => s.isNotEmpty)
                .toList();

            final matchesQuery =
                query.isEmpty || name.contains(query) || city.contains(query);

            final matchesCategory =
                selected.isEmpty ||
                kindsTokens.any((k) {
                  return selected.any((sel) => k.startsWith(sel.toLowerCase()));
                });

            return matchesQuery && matchesCategory;
          }).toList();

          return AsyncValue.data(filtered);
        },
      );
    });
