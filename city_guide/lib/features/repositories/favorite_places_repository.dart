import "../database/favorite_places_database.dart";

class FavoritePlacesRepository {
  final FavoritePlacesDatabase db;

  FavoritePlacesRepository(this.db);

  Future<List<FavoritePlace>> getAllFavoritePlaces() {
    return db.getAllFavoritePlaces();
  }

  Stream<List<FavoritePlace>> watchAllFavoritePlaces() {
    return db.watchAllFavoritePlaces();
  }

  Future<void> insertFavorite(FavoritePlacesCompanion place) {
    return db.insertFavorite(place);
  }

  Future<void> deleteFavorite(String xid) {
    return db.deleteFavorite(xid);
  }

  Future<bool> isFavorite(String xid) async {
    final result = await (db.select(
      db.favoritePlaces,
    )..where((t) => t.xid.equals(xid))).get();
    return result.isNotEmpty;
  }

  Future<bool> toggleFavorite(FavoritePlacesCompanion place) async {
    final isFav = await isFavorite(place.xid.value);
    final xid = place.xid.value;
    if (isFav) {
      await deleteFavorite(xid);
      return false;
    } else {
      await insertFavorite(place);
      return true;
    }
  }
}
