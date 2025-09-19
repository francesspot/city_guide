import "package:flutter/material.dart";
import "home_screen.dart";

void main() {
  runApp(const CityGuideApp());
}

class CityGuideApp extends StatelessWidget {
  const CityGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "City Guide",
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
