import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "features/providers/city_attractions_provider.dart";
import "features/providers/current_city_provider.dart";
import "features/providers/radius_provider.dart";
import "features/repositories/local_theme_repository.dart";
import "features/themes/theme_notifier.dart";
import "details_screen.dart";
import "features/models/attraction.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool clearButtonVisible = false;
  bool isSearchBarHovered = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      clearButtonVisible = _searchController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _searchCity() {
    final cityName = _searchController.text.trim();
    if (cityName.isNotEmpty) {
      ref.read(currentCityProvider.notifier).state = cityName;
      ref.read(radiusProvider.notifier).state = 1000;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(currentCityProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final currentCity = ref.watch(currentCityProvider);
    final radius = ref.watch(radiusProvider);
    final attractionsAsync = ref.watch(
      cityAttractionsProvider((currentCity, radius)),
    );
    final themeAsync = ref.watch(themeNotifierProvider);

    final inputFill =
        Theme.of(context).inputDecorationTheme.fillColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.grey[100]);

    final bool isLight = Theme.of(context).brightness == Brightness.light;
    final iconColorForSearchField = isLight
        ? Colors.grey
        : (Theme.of(context).iconTheme.color ?? Colors.white);

    final appBarIconColor =
        Theme.of(context).appBarTheme.iconTheme?.color ??
        Theme.of(context).iconTheme.color ??
        (isLight ? Colors.white : Colors.white);

    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ??
        (isLight ? Colors.black : Colors.white);

    final sliderPrimary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: MouseRegion(
          onEnter: (_) => setState(() => isSearchBarHovered = true),
          onExit: (_) => setState(() => isSearchBarHovered = false),
          child: Container(
            decoration: BoxDecoration(
              color: inputFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              cursorColor:
                  Theme.of(context).textSelectionTheme.cursorColor ??
                  Theme.of(context).colorScheme.primary,
              decoration: InputDecoration(
                hintText: "Wpisz nazwę miasta...",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintStyle:
                    Theme.of(context).inputDecorationTheme.hintStyle ??
                    TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                prefixIcon: Icon(Icons.search, color: iconColorForSearchField),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (clearButtonVisible && isSearchBarHovered)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: iconColorForSearchField,
                          size: 20,
                        ),
                        onPressed: _clearSearch,
                      ),
                    IconButton(
                      icon: Icon(Icons.search, color: iconColorForSearchField),
                      onPressed: _searchCity,
                    ),
                  ],
                ),
              ),
              style: TextStyle(color: textColor, fontSize: 16),
              onSubmitted: (_) => _searchCity(),
            ),
          ),
        ),
        actions: [
          switch (themeAsync) {
            AsyncData(value: final currentTheme) => IconButton(
              icon: Icon(
                currentTheme == AppTheme.light
                    ? Icons.light_mode
                    : currentTheme == AppTheme.dark
                    ? Icons.dark_mode
                    : Icons.auto_mode,
              ),
              onPressed: () =>
                  ref.read(themeNotifierProvider.notifier).toggleTheme(),
            ),
            AsyncLoading() => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            AsyncError() => IconButton(
              icon: const Icon(Icons.error),
              onPressed: () => ref.invalidate(themeNotifierProvider),
            ),
          },
          IconButton(
            icon: Icon(Icons.favorite, color: appBarIconColor),
            onPressed: () {
              context.push('/favorites');
            },
          ),
          IconButton(
            icon: Icon(Icons.map, color: appBarIconColor),
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
                        "Promień wyszukiwania: ${(radius / 1000).toStringAsFixed(1).replaceAll('.', ',')} km",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ) ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbColor: sliderPrimary,
                          activeTrackColor: sliderPrimary,
                          inactiveTrackColor: sliderPrimary.withAlpha(60),
                          overlayColor: sliderPrimary.withAlpha(36),
                          valueIndicatorColor: sliderPrimary,
                          trackHeight: 4.0,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 18.0,
                          ),
                        ),
                        child: Slider(
                          value: radius.toDouble(),
                          min: 1000,
                          max: 10000,
                          divisions: 9,
                          label:
                              "${(radius / 1000).toStringAsFixed(1).replaceAll('.', ',')} km",
                          onChanged: (value) {
                            final newRadius = value.toInt();
                            ref.read(radiusProvider.notifier).state = newRadius;
                            ref.invalidate(
                              cityAttractionsProvider((currentCity, newRadius)),
                            );
                          },
                        ),
                      ),
                      Text(
                        "1 km – 10 km",
                        style:
                            Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 12) ??
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                        ? Center(
                            child: Text(
                              "Brak atrakcji dla tego miasta",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
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
    return Center(
      child: Text(
        "Wpisz nazwę miasta i wciśnij Enter",
        style:
            Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18) ??
            const TextStyle(fontSize: 18),
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
              style: Theme.of(context).textTheme.bodyMedium,
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
          title: Text(
            attraction.name,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            attraction.kinds.split(',').map((e) => e.trim()).join(', '),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: () {
            context.push("${DetailsScreen.route}/${attraction.xid}");
          },
        );
      },
    );
  }
}
