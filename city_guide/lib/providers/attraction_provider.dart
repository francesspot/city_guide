import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/attraction.dart";

final attractionProvider = Provider<List<Attraction>>((ref) {
  return const [
    Attraction(
      name: "Muzeum Narodowe",
      description: "Jedno z największych muzeów sztuki w Polsce.",
      category: "Muzeum",
    ),
    Attraction(
      name: "Park Szczytnicki",
      description: "Duży park miejski idealny na spacer i relaks.",
      category: "Park",
    ),
    Attraction(
      name: "Restauracja Pod Złotym Psem",
      description: "Popularna restauracja w centrum miasta.",
      category: "Restauracja",
    ),
  ];
});
