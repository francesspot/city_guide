import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "features/providers/city_attractions_provider.dart";
import "features/providers/current_city_provider.dart";
import "features/providers/radius_provider.dart";
import "details_screen.dart";
import "features/models/attraction.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchCity() {
    final cityName = _searchController.text.trim();
    if (cityName.isNotEmpty) {
      ref.read(currentCityProvider.notifier).state = cityName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCity = ref.watch(currentCityProvider);
    final radius = ref.watch(radiusProvider);
    final attractionsAsync = ref.watch(
      cityAttractionsProvider((currentCity, radius)),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Wpisz nazwę miasta...",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _searchCity,
              ),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16),
            onSubmitted: (_) => _searchCity(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              if (currentCity.isNotEmpty) {
                context.push('/map');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Najpierw wyszukaj miasto")),
                );
              }
            },
          ),
        ],
      ),
      body: currentCity.isEmpty
          ? const _EmptyState()
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Promień wyszukiwania: ${(radius / 1000).toStringAsFixed(1)} km",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: radius.toDouble(),
                        min: 1000,
                        max: 10000,
                        divisions: 9,
                        label: "${(radius / 1000).toStringAsFixed(1)} km",
                        onChanged: (value) {
                          final newRadius = value.toInt();
                          ref.read(radiusProvider.notifier).state = newRadius;
                          ref.invalidate(
                            cityAttractionsProvider((currentCity, newRadius)),
                          );
                        },
                      ),
                      Text(
                        "1 km – 10 km",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: attractionsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _ErrorState(
                      message: error.toString(),
                      onRetry: _searchCity,
                    ),
                    data: (attractions) => attractions.isEmpty
                        ? const Center(
                            child: Text("Brak atrakcji dla tego miasta"),
                          )
                        : _AttractionsList(attractions: attractions),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Wpisz nazwę miasta i wciśnij Enter",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Błąd: $message',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttractionsList extends StatelessWidget {
  final List<Attraction> attractions;

  const _AttractionsList({required this.attractions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: attractions.length,
      itemBuilder: (context, index) {
        final attraction = attractions[index];
        return ListTile(
          leading: const Icon(Icons.place, color: Colors.red),
          title: Text(attraction.name),
          subtitle: Text(
            attraction.kinds.split(',').first,
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            context.push("${DetailsScreen.route}/${attraction.xid}");
          },
        );
      },
    );
  }
}
