**Polski** | [English](README.en.md)

# City Guide

Aplikacja mobilna we Flutterze do odkrywania **atrakcji turystycznych w dowolnym mieście**. Wpisujesz nazwę miasta, a aplikacja pobiera pobliskie miejsca z API [OpenTripMap](https://opentripmap.io), pokazuje je na liście i na mapie oraz pozwala zapisać ulubione na później.

## Funkcje

- **Wyszukiwanie miasta** — atrakcje w wybranym promieniu od centrum, z historią ostatnio wyszukiwanych miast.
- **Filtry** — według kategorii atrakcji (pobieranych z drzewa kategorii OpenTripMap) i promienia wyszukiwania.
- **Szczegóły atrakcji** — opis, kategoria i lokalizacja na mapie.
- **Widok mapy** — wszystkie atrakcje bieżącego miasta na mapie OpenStreetMap.
- **Ulubione** — zapisywane w lokalnej bazie SQLite, z osobną listą, ekranem szczegółów i mapą.
- **Motywy** — jasny, ciemny lub zgodny z systemem; wybór jest zapamiętywany.

## Technologie

- **Zarządzanie stanem:** Riverpod 3 (z generowaniem kodu)
- **Nawigacja:** go_router
- **Sieć:** Dio
- **Mapy:** flutter_map + latlong2 (kafelki OpenStreetMap)
- **Lokalna baza danych:** Drift (SQLite)
- **Modele:** freezed + json_serializable
- **Ustawienia:** shared_preferences

Kod jest podzielony na warstwy w `lib/features/`: `models`, `repositories`, `providers`, `database`, `routing` i `themes`. Ekrany znajdują się w `lib/`.

## Uruchomienie

Projekt Fluttera jest w podfolderze `city_guide/`. Pliki generowane (`*.g.dart`, `*.freezed.dart`) nie są w repozytorium, więc przed pierwszym uruchomieniem trzeba je wygenerować:

```bash
cd city_guide
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Wymagany Flutter z Dart SDK 3.9 lub nowszym.
