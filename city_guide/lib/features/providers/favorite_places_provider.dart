import 'package:city_guide/features/database/favorite_places_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../repositories/favorite_places_repository.dart";

final databaseProvider = Provider<FavoritePlacesDatabase>((ref) {
  return FavoritePlacesDatabase();
});

final favoritesRepositoryProvider = Provider<FavoritePlacesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FavoritePlacesRepository(db);
});

final favoritesProvider = StreamProvider<List<FavoritePlace>>((ref) {
  return ref.watch(favoritesRepositoryProvider).watchAllFavoritePlaces();
});
