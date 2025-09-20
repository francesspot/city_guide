import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "../models/attraction.dart";

final attractionProvider = Provider<List<Attraction>>((ref) {
  return const [
    Attraction(
      id: 1,
      name: "Muzeum Narodowe",
      description: "Jedno z największych muzeów sztuki w Polsce.",
      category: "Muzeum",
    ),
    Attraction(
      id: 2,
      name: "Park Szczytnicki",
      description: "Duży park miejski idealny na spacer i relaks.",
      category: "Park",
    ),
    Attraction(
      id: 3,
      name: "Restauracja Pod Złotym Psem",
      description: "Popularna restauracja w centrum miasta.",
      category: "Restauracja",
    ),
  ];
});

final searchQueryProvider = StateProvider<String>((ref) => "");

final filteredAttractionProvider = Provider<List<Attraction>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final attractions = ref.watch(attractionProvider);

  if (query.isEmpty) {
    return attractions;
  } else {
    return attractions
        .where(
          (attraction) =>
              attraction.name.toLowerCase().contains(query) ||
              attraction.category.toLowerCase().contains(query),
        )
        .toList();
  }
});
