[Polski](README.md) | **English**

# City Guide

A Flutter mobile app for discovering **tourist attractions in any city**. You type a city name, and the app fetches nearby places from the [OpenTripMap](https://opentripmap.io) API, shows them on a list and a map, and lets you save favourites for later. The interface is in Polish.

## Features

- **City search** — attractions within a chosen radius of the city centre, with a history of recently searched cities.
- **Filters** — by attraction category (loaded from the OpenTripMap category tree) and by search radius.
- **Attraction details** — description, category and location on a map.
- **Map view** — all attractions of the current city on an OpenStreetMap map.
- **Favourites** — saved in a local SQLite database, with their own list, details screen and map.
- **Themes** — light, dark or follow the system; the choice is remembered.

## Tech stack

- **State management:** Riverpod 3 (with code generation)
- **Navigation:** go_router
- **Networking:** Dio
- **Maps:** flutter_map + latlong2 (OpenStreetMap tiles)
- **Local database:** Drift (SQLite)
- **Models:** freezed + json_serializable
- **Settings:** shared_preferences

The code is organised by layers in `lib/features/`: `models`, `repositories`, `providers`, `database`, `routing` and `themes`. Screens are in `lib/`.

## Running

The Flutter project is in the `city_guide/` subfolder. Generated files (`*.g.dart`, `*.freezed.dart`) are not committed, so generate them before the first run:

```bash
cd city_guide
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Requires Flutter with Dart SDK 3.9 or newer.
