import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'favorite_places_details_screen.dart';
import 'features/database/favorite_places_database.dart';
import 'features/providers/categories_provider.dart';
import 'features/providers/favorite_places_provider.dart';
import 'features/providers/filter_providers.dart';

class FavoritePlacesScreen extends ConsumerWidget {
  const FavoritePlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(filteredFavoritesProvider);
    final hasActiveFilters =
        ref.watch(filterQueryProvider).isNotEmpty ||
        ref.watch(selectedCategoriesProvider).isNotEmpty;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(filterQueryProvider.notifier).state = '';
      ref.read(selectedCategoriesProvider.notifier).state = <String>{};
    });

    void clearFilters() {
      ref.read(filterQueryProvider.notifier).state = '';
      ref.read(selectedCategoriesProvider.notifier).state = <String>{};
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ulubione miejsca'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Wyczyść filtry',
              onPressed: clearFilters,
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => context.push('/favorites_map'),
          ),
        ],
      ),
      body: Column(
        children: [
          if (hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: clearFilters,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                    ),
                    child: Text(
                      'Wyczyść',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: favoritesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Błąd: $error')),
              data: (favorites) {
                if (favorites.isEmpty) {
                  return const Center(child: Text('Brak ulubionych miejsc.'));
                }

                final Map<String, List<FavoritePlace>> groupedByCity = {};
                for (var place in favorites) {
                  final cityKey = (place.city.isEmpty)
                      ? 'Nieznane miasto'
                      : place.city;
                  groupedByCity.putIfAbsent(cityKey, () => []).add(place);
                }

                final sortedCities = groupedByCity.keys.toList()..sort();

                return ListView.builder(
                  itemCount: sortedCities.length,
                  itemBuilder: (context, index) {
                    final city = sortedCities[index];
                    final places = groupedByCity[city]!
                      ..sort((a, b) => a.name.compareTo(b.name));

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 6,
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text(
                          city,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: places.map((place) {
                          return ListTile(
                            leading: const Icon(Icons.place, color: Colors.red),
                            title: Text(place.name),
                            subtitle: Text(
                              place.kinds != null
                                  ? place.kinds!
                                        .split(',')
                                        .map((e) => e.trim())
                                        .join(', ')
                                  : 'Brak kategorii',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.tertiary,
                                  ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await ref
                                    .read(favoritesRepositoryProvider)
                                    .deleteFavorite(place.xid);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("❌ Usunięto z ulubionych"),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            onTap: () => context.push(
                              "${FavoritePlacesDetailsScreen.route}/${place.xid}",
                              extra: place,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
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
                      labelText: 'Szukaj po nazwie lub mieście',
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
