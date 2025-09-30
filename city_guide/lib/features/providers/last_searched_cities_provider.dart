import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'shared_preferences_provider.dart';

final lastSearchedCitiesProvider =
    StateNotifierProvider<LastSearchedCitiesNotifier, List<String>>((ref) {
      return LastSearchedCitiesNotifier(ref);
    });

class LastSearchedCitiesNotifier extends StateNotifier<List<String>> {
  final Ref ref;
  static const String _key = 'lastSearchedCities';
  static const int _maxCities = 5;

  LastSearchedCitiesNotifier(this.ref) : super([]) {
    _loadCities();
  }

  Future<void> _loadCities() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final cities = prefs.getStringList(_key) ?? [];
    state = cities;
  }

  Future<void> addCity(String city) async {
    if (city.isEmpty) return;
    final prefs = await ref.read(sharedPreferencesProvider.future);

    List<String> cities = [city, ...state.where((c) => c != city)];

    if (cities.length > _maxCities) {
      cities = cities.sublist(0, _maxCities);
    }

    await prefs.setStringList(_key, cities);
    state = cities;
  }

  Future<void> clearCities() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove(_key);
    state = [];
  }

  Future<void> removeCity(String city) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final cities = state.where((c) => c != city).toList();
    await prefs.setStringList(_key, cities);
    state = cities;
  }
}
