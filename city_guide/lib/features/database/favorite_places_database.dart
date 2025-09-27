import "dart:io";
import "package:drift/drift.dart";
import "package:drift/native.dart";
import "package:path/path.dart" as p;
import "package:path_provider/path_provider.dart";
import "favorite_places_table.dart";

part "favorite_places_database.g.dart";

@DriftDatabase(tables: [FavoritePlaces])
class FavoritePlacesDatabase extends _$FavoritePlacesDatabase {
  FavoritePlacesDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<FavoritePlace>> getAllFavoritePlaces() {
    return select(favoritePlaces).get();
  }

  Stream<List<FavoritePlace>> watchAllFavoritePlaces() {
    return select(favoritePlaces).watch();
  }

  Future<void> insertFavorite(FavoritePlacesCompanion place) {
    return into(favoritePlaces).insertOnConflictUpdate(place);
  }

  Future<void> deleteFavorite(String xid) {
    return (delete(favoritePlaces)..where((tbl) => tbl.xid.equals(xid))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, "favorite_places.sqlite"));
    return NativeDatabase(file);
  });
}
