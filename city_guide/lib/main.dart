import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "features/routing/app_router.dart";

void main() {
  runApp(const ProviderScope(child: CityGuideApp()));
}

class CityGuideApp extends StatelessWidget {
  const CityGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "City Guide",
      theme: ThemeData(primarySwatch: Colors.indigo),
      routerConfig: goRouter,
    );
  }
}
