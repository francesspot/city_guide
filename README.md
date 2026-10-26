🇵🇱 **Polski** | 🇬🇧 [English](README.en.md)

# 🏙️ City Guide

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white) ![Riverpod](https://img.shields.io/badge/Riverpod-00B4AB) ![SQLite](https://img.shields.io/badge/SQLite-003B57?logo=sqlite&logoColor=white)

> 🎓 Projekt ze ścieżki mobilnej **Wakacyjnego Wyzwania 2025** koła naukowego **KN Solvro** (Politechnika Wrocławska)

Twój przewodnik po dowolnym mieście 🧭 — wpisujesz nazwę, a aplikacja pokazuje okoliczne atrakcje na liście i na mapie. Najciekawsze miejsca zapisujesz do ulubionych i masz je zawsze pod ręką, także offline. ❤️

## ✨ Funkcje

- 🔎 **Wyszukiwanie miasta** z historią ostatnich wyszukiwań
- 🎛️ **Filtry** — kategoria atrakcji i promień wyszukiwania
- 🗺️ **Mapa** atrakcji (OpenStreetMap) i ekran szczegółów z opisem
- ❤️ **Ulubione** zapisywane w lokalnej bazie SQLite, z osobną mapą
- 🌗 **Motyw** jasny, ciemny albo systemowy — zapamiętywany

## 🛠️ Technologie

Flutter · **Riverpod 3** (z generowaniem kodu) · **go_router** · **Dio** · **Drift** (SQLite) · **flutter_map** · **freezed** · API OpenTripMap

Kod podzielony na warstwy: modele, repozytoria, providery, bazę danych, routing i motywy.

## 🚀 Uruchomienie

```bash
cd city_guide
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```
