import "package:flutter/material.dart";
import "details_screen.dart";

class Attraction {
  final String name;
  final String description;
  final String category;

  const Attraction({
    required this.name,
    required this.description,
    required this.category,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Attraction> attrList = const [
    Attraction(
      name: "Muzeum Narodowe",
      description: "Jedno z największych muzeów sztuki w Polsce.",
      category: "Muzeum",
    ),
    Attraction(
      name: "Park Szczytnicki",
      description: "Duży park miejski idealny na spacer i relaks.",
      category: "Park",
    ),
    Attraction(
      name: "Restauracja Pod Złotym Psem",
      description: "Popularna restauracja w centrum miasta.",
      category: "Restauracja",
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
