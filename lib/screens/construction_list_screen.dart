import 'package:flutter/material.dart';
import '../models/construction.dart';
import 'draw_map_screen.dart';
import 'full_map_screen.dart';

class ConstructionListScreen extends StatelessWidget {
  final List<Construction> constructions;

  const ConstructionListScreen({super.key, required this.constructions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des constructions'),
        actions: [
          /// Bouton Modifier
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DrawMapScreen(),
                ),
              );
            },
          ),

          /// Bouton Aller vers la carte
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Aller vers la carte',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullMapScreen(
                    constructions: constructions,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: constructions.length,
        itemBuilder: (context, index) {
          final c = constructions[index];
          return ListTile(
            leading: const Icon(Icons.home_work_outlined),
            title: Text(c.adresse),
            subtitle: Text(c.type),
            onTap: () {
              // Plus tard : zoom sur la construction dans la carte
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
