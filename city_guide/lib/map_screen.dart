import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "./features/providers/attraction_provider.dart";

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attractions = ref.watch(attractionProvider);

    final avgLat = attractions.isNotEmpty
        ? attractions.map((a) => a.lat).reduce((a, b) => a + b) /
              attractions.length
        : 0.0;
    final avgLng = attractions.isNotEmpty
        ? attractions.map((a) => a.lng).reduce((a, b) => a + b) /
              attractions.length
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa atrakcji"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(avgLat, avgLng),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.city_guide',
          ),
          MarkerLayer(
            markers: attractions.map((attraction) {
              return Marker(
                width: 40,
                height: 40,
                point: LatLng(attraction.lat, attraction.lng),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 36,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
