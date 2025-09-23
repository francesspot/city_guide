import "package:freezed_annotation/freezed_annotation.dart";

part "attraction.freezed.dart";
part "attraction.g.dart";

@freezed
abstract class Attraction with _$Attraction {
  const factory Attraction({
    required String xid,
    required String name,
    @Default("") String kinds,
    @Default("Brak opisu") String description,
    required double lat,
    required double lon,
  }) = _Attraction;

  factory Attraction.fromJson(Map<String, Object?> json) =>
      _$AttractionFromJson(json);
}
