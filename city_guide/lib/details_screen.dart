import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "features/providers/attraction_provider.dart";

class DetailsScreen extends ConsumerWidget {
  final String id;
  static const route = "/place";

  const DetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attractions = ref.watch(attractionProvider);
    final attraction = attractions.firstWhere(
      (a) => a.id == id,
      orElse: () => throw Exception("Atrakcja nie została znaleziona"),
    );

    return Scaffold(
      appBar: AppBar(title: Text(attraction.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attraction.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Kategoria: ${attraction.category}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              attraction.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              "Lokalizacja: (${attraction.lat}, ${attraction.lng})",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
