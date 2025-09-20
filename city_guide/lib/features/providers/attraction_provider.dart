import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_riverpod/legacy.dart";
import "../models/attraction.dart";

final attractionProvider = Provider<List<Attraction>>((ref) {
  return const [
    Attraction(
      id: "1",
      name: "Muzeum Narodowe",
      description: "Jedno z największych muzeów sztuki w Polsce.",
      category: "Muzeum",
      lat: 51.109,
      lng: 17.044,
    ),
    Attraction(
      id: "2",
      name: "Park Szczytnicki",
      description: "Duży park miejski idealny na spacer i relaks.",
      category: "Park",
      lat: 51.1166,
      lng: 17.0779,
    ),
    Attraction(
      id: "3",
      name: "Restauracja Pod Złotym Psem",
      description: "Popularna restauracja w centrum miasta.",
      category: "Restauracja",
      lat: 51.109,
      lng: 17.033,
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
          (a) =>
              a.name.toLowerCase().contains(query) ||
              a.category.toLowerCase().contains(query),
        )
        .toList();
  }
});
