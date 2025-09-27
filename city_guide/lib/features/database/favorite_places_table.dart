import "package:drift/drift.dart";

class FavoritePlaces extends Table {
  TextColumn get xid => text()();
  TextColumn get name => text()();
  TextColumn get city => text()();
  TextColumn get kinds => text().nullable()();
  TextColumn get description => text().nullable()();
  RealColumn get lat => real()();
  RealColumn get lon => real()();

  @override
  Set<Column> get primaryKey => {xid};
}
