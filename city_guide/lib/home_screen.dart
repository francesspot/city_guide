import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "details_screen.dart";
import "providers/attraction_provider.dart";

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attrList = ref.watch(attractionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("City Guide")),
      body: ListView.builder(
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
