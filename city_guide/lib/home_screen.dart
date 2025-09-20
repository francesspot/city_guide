import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "details_screen.dart";
import "features/providers/attraction_provider.dart";

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attrList = ref.watch(filteredAttractionProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Szukaj atrakcji...",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),
      ),
      body: attrList.isEmpty
          ? const Center(child: Text("Brak wyników wyszukiwania"))
          : ListView.builder(
              itemCount: attrList.length,
              itemBuilder: (context, index) {
                final attraction = attrList[index];
                return ListTile(
                  title: Text(attraction.name),
                  subtitle: Text(attraction.category),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailsScreen(attraction: attraction),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
