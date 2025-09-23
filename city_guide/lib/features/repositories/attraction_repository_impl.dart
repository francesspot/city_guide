import "package:dio/dio.dart";
import "../models/attraction.dart";
import "attraction_repository.dart";

class AttractionRepositoryImpl implements AttractionRepository {
  final Dio _dio;
  final String _apiKey;

  AttractionRepositoryImpl({required Dio dio, required String apiKey})
    : _dio = dio,
      _apiKey = apiKey;

  @override
  Future<List<Attraction>> fetchAttractionsForCity(
    String cityName,
    int radius,
  ) async {
    try {
      final geoRes = await _dio.get(
        "/places/geoname",
        queryParameters: {"name": cityName, "apikey": _apiKey},
      );

      if (geoRes.statusCode != 200 || geoRes.data == null) {
        throw Exception("Nie udało się znaleźć miasta: '$cityName'");
      }

      final lat = (geoRes.data['lat'] as num).toDouble();
      final lon = (geoRes.data['lon'] as num).toDouble();

      final attractionsRes = await _dio.get(
        "/places/radius",
        queryParameters: {
          "lat": lat,
          "lon": lon,
          "radius": radius,
          "limit": 500,
          "rate": 3,
          "apikey": _apiKey,
          "format": "json",
        },
      );

      if (attractionsRes.statusCode != 200) {
        throw Exception("Błąd API: ${attractionsRes.statusCode}");
      }

      final dataList = attractionsRes.data is List
          ? attractionsRes.data as List
          : [];

      final List<Attraction> attractions = [];
      for (final item in dataList) {
        if (item is! Map<String, dynamic>) continue;

        final xid = item['xid'] as String?;
        final name = item['name'] as String?;

        if (xid == null || name == null) continue;

        final lat = (item['point']?['lat'] ?? item['lat']) as num?;
        final lon = (item['point']?['lon'] ?? item['lon']) as num?;

        if (lat == null || lon == null) continue;

        attractions.add(
          Attraction(
            xid: xid,
            name: name,
            kinds: item['kinds'] as String? ?? "Brak kategorii",
            description: _extractDescription(item),
            lat: lat.toDouble(),
            lon: lon.toDouble(),
          ),
        );
      }

      if (attractions.isEmpty) {
        throw Exception("Brak atrakcji dla miasta: '$cityName'");
      }

      return attractions;
    } on DioException catch (e) {
      throw Exception("Błąd sieci: ${e.message}");
    } catch (e) {
      throw Exception("Wystąpił nieoczekiwany błąd: $e");
    }
  }

  @override
  Future<Attraction> fetchAttractionDetails(String xid) async {
    try {
      final res = await _dio.get(
        "/places/xid/$xid",
        queryParameters: {"apikey": _apiKey},
      );

      if (res.statusCode != 200) {
        throw Exception(
          "Błąd podczas pobierania szczegółów: ${res.statusCode}",
        );
      }

      final data = res.data as Map<String, dynamic>;

      return Attraction(
        xid: data['xid'] as String? ?? xid,
        name: data['name'] as String? ?? "Brak nazwy",
        kinds: data['kinds'] as String? ?? "Brak kategorii",
        description: _extractDescription(data),
        lat: (data['point']?['lat'] ?? data['lat'] as num?)?.toDouble() ?? 0.0,
        lon: (data['point']?['lon'] ?? data['lon'] as num?)?.toDouble() ?? 0.0,
      );
    } on DioException catch (e) {
      throw Exception("Błąd sieci: ${e.message}");
    }
  }

  String _extractDescription(Map<String, dynamic> data) {
    if (data['wikipedia_extracts']?['text'] != null) {
      return data['wikipedia_extracts']['text'] as String;
    }
    if (data['wikipedia'] != null) return data['wikipedia'] as String;
    if (data['info'] != null) return data['info'] as String;
    if (data['descr'] != null) return data['descr'] as String;
    return "Brak opisu";
  }
}
