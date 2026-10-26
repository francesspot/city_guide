🇵🇱 [Polski](README.md) | 🇬🇧 **English**

# 🏙️ City Guide

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white) ![Riverpod](https://img.shields.io/badge/Riverpod-00B4AB) ![SQLite](https://img.shields.io/badge/SQLite-003B57?logo=sqlite&logoColor=white)

> 🎓 Project from the mobile track of the **Summer Challenge 2025** (*Wakacyjne Wyzwanie*) run by the **KN Solvro** student research group (Wrocław University of Science and Technology)

A mobile app for discovering tourist attractions in any city. Enter a city name to see nearby attractions on a list and a map, and save chosen places to locally stored favourites.

## ✨ Features

- **City search** with recent-search history
- **Filters** — attraction category and search radius
- **Map** of attractions (OpenStreetMap) and a details screen with a description
- **Favourites** stored in a local SQLite database, with their own map
- **Theme** — light, dark or system, remembered between launches

## 🛠️ Tech

Flutter · **Riverpod 3** (with code generation) · **go_router** · **Dio** · **Drift** (SQLite) · **flutter_map** · **freezed** · OpenTripMap API

The code is split into layers: models, repositories, providers, database, routing and themes.

## 🚀 Run it

```bash
cd city_guide
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The interface is in Polish.
