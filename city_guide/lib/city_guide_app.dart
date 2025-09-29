import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "features/routing/app_router.dart";
import "features/themes/app_theme.dart";
import "features/themes/theme_notifier.dart";
import "features/repositories/local_theme_repository.dart";

void main() {
  runApp(const ProviderScope(child: CityGuideApp()));
}

class CityGuideApp extends ConsumerWidget {
  const CityGuideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeNotifierProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final appTheme = AppThemeImplementation();

    return themeAsync.when(
      data: (theme) {
        final themeMode = switch (theme) {
          AppTheme.light => ThemeMode.light,
          AppTheme.dark => ThemeMode.dark,
          AppTheme.system =>
            platformBrightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
        };

        return MaterialApp.router(
          title: 'City Guide',
          debugShowCheckedModeBanner: false,
          routerConfig: goRouter,
          themeMode: themeMode,
          theme: appTheme.light,
          darkTheme: appTheme.dark,
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(body: Center(child: Text("Błąd: $error"))),
      ),
    );
  }
}
