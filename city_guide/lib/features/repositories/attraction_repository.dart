import "../models/attraction.dart";

abstract class AttractionRepository {
  Future<List<Attraction>> fetchAttractionsForCity(String cityName, int radius);

  Future<Attraction> fetchAttractionDetails(String xid);
}
