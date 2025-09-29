import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/local_theme_repository.dart';
import '../providers/local_theme_repository_provider.dart';

final themeNotifierProvider = AsyncNotifierProvider<ThemeNotifier, AppTheme>(
  () => ThemeNotifier(),
);

class ThemeNotifier extends AsyncNotifier<AppTheme> {
  @override
  Future<AppTheme> build() async {
    final repo = await ref.watch(localThemeRepositoryProvider.future);
    return repo.getTheme();
  }

  Future<void> toggleTheme() async {
    final repo = await ref.watch(localThemeRepositoryProvider.future);
    final current = state.value ?? AppTheme.system;
    final newTheme = switch (current) {
      AppTheme.light => AppTheme.dark,
      AppTheme.dark => AppTheme.light,
      AppTheme.system => AppTheme.light,
    };
    state = AsyncData(newTheme);
    await repo.setTheme(newTheme);
  }

  Future<void> setTheme(AppTheme theme) async {
    final repo = await ref.watch(localThemeRepositoryProvider.future);
    state = AsyncData(theme);
    await repo.setTheme(theme);
  }
}
