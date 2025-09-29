import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/local_theme_repository.dart';
import 'shared_preferences_provider.dart';

final localThemeRepositoryProvider = FutureProvider<LocalThemeRepository>((
  ref,
) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalThemeRepository(prefs);
});
