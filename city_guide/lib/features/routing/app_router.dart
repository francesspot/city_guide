import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "../../favorite_places_map_screen.dart";
import "../../home_screen.dart";
import "../../details_screen.dart";
import "../../map_screen.dart";
import "../../favorite_places_screen.dart";
import "../../favorite_places_details_screen.dart";
import "../database/favorite_places_database.dart";

final goRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: "/", builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: "${DetailsScreen.route}/:id",
      builder: (context, state) {
        final id = state.pathParameters["id"]!;
        return DetailsScreen(xid: id);
      },
    ),
    GoRoute(
      path: "/favorites",
      builder: (context, state) => const FavoritePlacesScreen(),
    ),
    GoRoute(
      path: "${FavoritePlacesDetailsScreen.route}/:id",
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra;
        if (extra is FavoritePlace) {
          return FavoritePlacesDetailsScreen(place: extra, xid: id);
        }
        return Scaffold(
          appBar: AppBar(title: const Text("Błąd")),
          body: const Center(child: Text("Nie znaleziono miejsca")),
        );
      },
    ),
    GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
    GoRoute(
      path: '/favorites_map',
      builder: (context, state) => const FavoritePlacesMapScreen(),
    ),
  ],
);
