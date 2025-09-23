import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:dio/dio.dart";

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: "https://api.opentripmap.com/0.1/en",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "User-Agent": "CityGuide/1.0 (franciszekpora2@gmail.com)",
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  return dio;
});
