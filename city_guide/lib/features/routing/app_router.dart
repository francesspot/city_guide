import "package:go_router/go_router.dart";
import "../../home_screen.dart";
import "../../details_screen.dart";
import "../../map_screen.dart";

final goRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(path: "/", builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: "${DetailsScreen.route}/:id",
      builder: (context, state) {
        final id = state.pathParameters["id"]!;
        return DetailsScreen(id: id);
      },
    ),
    GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
  ],
);
