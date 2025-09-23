import "package:flutter_riverpod/flutter_riverpod.dart";
import "../repositories/attraction_repository.dart";
import "../repositories/attraction_repository_impl.dart";
import "dio_provider.dart";

final attractionRepositoryProvider = Provider<AttractionRepository>((ref) {
  final dio = ref.read(dioProvider);
  const apiKey = "5ae2e3f221c38a28845f05b669d07f0bbade0f85c1a54e939f0aba97";
  return AttractionRepositoryImpl(dio: dio, apiKey: apiKey);
});
