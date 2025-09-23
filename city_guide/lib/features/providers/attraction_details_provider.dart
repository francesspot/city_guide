import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/attraction.dart";
import "attraction_repository_provider.dart";

final attractionDetailsProvider = FutureProvider.family<Attraction, String>((
  ref,
  xid,
) async {
  final repository = ref.watch(attractionRepositoryProvider);
  return repository.fetchAttractionDetails(xid);
});
