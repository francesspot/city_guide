import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/attraction.dart";
import "attraction_repository_provider.dart";

final cityAttractionsProvider = FutureProvider.autoDispose
    .family<List<Attraction>, (String, int)>((ref, parameters) async {
      final (cityName, radius) = parameters;
      if (cityName.isEmpty) {
        return [];
      }
      final repository = ref.watch(attractionRepositoryProvider);
      return await repository.fetchAttractionsForCity(cityName, radius);
    });
