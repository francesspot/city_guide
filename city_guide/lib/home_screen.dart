import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "features/providers/categories_provider.dart";
import "features/providers/city_attractions_provider.dart";
import "features/providers/current_city_provider.dart";
import "features/providers/radius_provider.dart";
import "features/repositories/local_theme_repository.dart";
import "features/themes/theme_notifier.dart";
import "details_screen.dart";
import "features/models/attraction.dart";
import "features/providers/filter_providers.dart";
import "features/providers/last_searched_cities_provider.dart";

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _FilterSheetContent extends StatefulWidget {
  final String initialQuery;
  final Set<String> initialSelected;

  const _FilterSheetContent({
    required this.initialQuery,
    required this.initialSelected,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late String _localQuery;
  late Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localQuery = widget.initialQuery;
    _localSelected = widget.initialSelected.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final categoriesAsync = ref.watch(categoriesProvider);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text('Filtry'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _localQuery = '';
                          _localSelected = <String>{};
                        });
                      },
                      child: const Text('Wyczyść'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Szukaj po nazwie',
                      prefixIcon: Icon(Icons.search),
                    ),
                    initialValue: _localQuery,
                    onChanged: (v) {
                      setState(() {
                        _localQuery = v;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: categoriesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Błąd pobierania kategorii: $e')),
                    data: (cats) {
                      if (cats.isEmpty) {
                        return const Center(
                          child: Text('Brak dostępnych kategorii'),
                        );
                      }
                      return ListView(
                        children: cats.map((top) {
                          return ExpansionTile(
                            title: Text(
                              top.name.isNotEmpty ? top.name : top.key,
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    FilterChip(
                                      label: Text(
                                        top.name.isNotEmpty
                                            ? top.name
                                            : top.key,
                                      ),
                                      selected: _localSelected.contains(
                                        top.key,
                                      ),
                                      selectedColor: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.3),
                                      checkmarkColor: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      onSelected: (sel) {
                                        setState(() {
                                          if (sel) {
                                            _localSelected.add(top.key);
                                          } else {
                                            _localSelected.remove(top.key);
                                          }
                                        });
                                      },
                                    ),
                                    ...top.children.map((c) {
                                      final k = c.key;
                                      final label = c.name.isNotEmpty
                                          ? c.name
                                          : k;
                                      return FilterChip(
                                        label: Text(label),
                                        selected: _localSelected.contains(k),
                                        selectedColor: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.3),
                                        checkmarkColor: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        onSelected: (sel) {
                                          setState(() {
                                            if (sel) {
                                              _localSelected.add(k);
                                            } else {
                                              _localSelected.remove(k);
                                            }
                                          });
                                        },
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(filterQueryProvider.notifier).state =
                          _localQuery;
                      ref.read(selectedCategoriesProvider.notifier).state =
                          _localSelected;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Zatwierdź filtry'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool clearButtonVisible = false;
  bool isSearchBarHovered = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(filterQueryProvider.notifier).state = '';
      ref.read(selectedCategoriesProvider.notifier).state = <String>{};
    });
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
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _searchCity(String cityName) {
    final trimmedCityName = cityName.trim();
    if (trimmedCityName.isNotEmpty) {
      final currentCity = ref.read(currentCityProvider);

      if (currentCity != trimmedCityName) {
        ref.read(filterQueryProvider.notifier).state = '';
        ref.read(selectedCategoriesProvider.notifier).state = <String>{};
      }

      ref.read(currentCityProvider.notifier).state = trimmedCityName;
      ref.read(radiusProvider.notifier).state = 1000;

      ref.read(lastSearchedCitiesProvider.notifier).addCity(trimmedCityName);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(currentCityProvider.notifier).state = '';
    ref.read(filterQueryProvider.notifier).state = '';
    ref.read(selectedCategoriesProvider.notifier).state = <String>{};
  }

  void _showFilterSheet() {
    final currentQuery = ref.read(filterQueryProvider);
    final currentSelected = ref.read(selectedCategoriesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheetContent(
        initialQuery: currentQuery,
        initialSelected: currentSelected,
      ),
    );
  }

  void _clearFilters() {
    ref.read(filterQueryProvider.notifier).state = '';
    ref.read(selectedCategoriesProvider.notifier).state = <String>{};
  }

  @override
  Widget build(BuildContext context) {
    final currentCity = ref.watch(currentCityProvider);
    final radius = ref.watch(radiusProvider);
    final attractionsAsync = ref.watch(filteredCityAttractionsProvider);
    final themeAsync = ref.watch(themeNotifierProvider);
    final hasActiveFilters =
        ref.watch(filterQueryProvider).isNotEmpty ||
        ref.watch(selectedCategoriesProvider).isNotEmpty;
    final lastCities = ref.watch(lastSearchedCitiesProvider);

    ref.listen(currentCityProvider, (_, city) {
      if (city.isNotEmpty && _searchController.text != city) {
        _searchController.text = city;
      }
    });

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
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return lastCities;
                }
                return lastCities.where((String option) {
                  return option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  );
                });
              },
              onSelected: (String selection) {
                _searchCity(selection);
              },
              fieldViewBuilder:
                  (
                    BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted,
                  ) {
                    if (_searchController.text != textEditingController.text) {
                      _searchController.text = textEditingController.text;
                    }
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
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
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color,
                            ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: iconColorForSearchField,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (textEditingController.text.isNotEmpty &&
                                isSearchBarHovered)
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: iconColorForSearchField,
                                  size: 20,
                                ),
                                onPressed: () {
                                  textEditingController.clear();
                                  _clearSearch();
                                },
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.search,
                                color: iconColorForSearchField,
                              ),
                              onPressed: () =>
                                  _searchCity(textEditingController.text),
                            ),
                          ],
                        ),
                      ),
                      style: TextStyle(color: textColor, fontSize: 16),
                      onSubmitted: (value) => _searchCity(value),
                    );
                  },
              optionsViewBuilder:
                  (
                    BuildContext context,
                    AutocompleteOnSelected<String> onSelected,
                    Iterable<String> options,
                  ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final String option = options.elementAt(index);
                              return ListTile(
                                leading: const Icon(Icons.history, size: 20),
                                title: Text(option),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
            ),
          ),
        ),
        actions: [
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Wyczyść filtry',
              onPressed: _clearFilters,
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
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
              ref.read(filterQueryProvider.notifier).state = '';
              ref.read(selectedCategoriesProvider.notifier).state = <String>{};
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
                if (hasActiveFilters)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_alt,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Aktywne filtry',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: _clearFilters,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                          ),
                          child: Text(
                            'Wyczyść',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      onRetry: () => _searchCity(currentCity),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            "Wpisz nazwę miasta i wciśnij Enter",
            style:
                Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 18) ??
                const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "lub wybierz z ostatnio wyszukiwanych",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
          onTap: () => context.push("${DetailsScreen.route}/${attraction.xid}"),
        );
      },
    );
  }
}
