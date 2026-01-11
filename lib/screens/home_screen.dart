import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_releve/screens/draw_map_screen.dart';

import '../models/construction.dart';
import '../services/db_helper.dart';
import 'full_map_screen.dart';
import 'construction_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _dbHelper = DBHelper();
  final MapController _mapController = MapController();

  List<Construction> _constructions = [];

  @override
  void initState() {
    super.initState();
    _loadConstructions();
  }

  Future<void> _loadConstructions() async {
    final data = await _dbHelper.getAllConstructions();
    setState(() => _constructions = data);
    
  }

  Color _colorByType(String type) {
    switch (type) {
      case 'Résidentiel':
        return Colors.red.withAlpha(120);
      case 'Commercial':
        return Colors.blue.withAlpha(120);
      case 'Industriel':
        return Colors.green.withAlpha(120);
      default:
        return Colors.grey.withAlpha(120);
    }
  }

  List<LatLng> _geoJsonToLatLng(String geoJson) {
    final decoded = jsonDecode(geoJson);
    final List coords = decoded['coordinates'][0];
    return coords.map<LatLng>((p) => LatLng(p[1], p[0])).toList();
  }

  /// 🔹 Dernières constructions (max 5)
  List<Construction> get _latestConstructions {
    if (_constructions.length <= 5) return _constructions;
    return _constructions.sublist(_constructions.length - 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil'), centerTitle: true),
      body: Column(
        children: [
          /// 🗺️ PARTIE CARTE (50%)
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(33.5731, -7.5898),
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    PolygonLayer(
                      polygons: _constructions.map((c) {
                        return Polygon(
                          points: _geoJsonToLatLng(c.polygonGeoJson),
                          color: _colorByType(c.type),
                          borderColor: Colors.black,
                          borderStrokeWidth: 1.5,
                        );
                      }).toList(),
                    ),
                  ],
                ),

                /// 🔘 Bouton Aller vers carte
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: _ModernNavButton(
                    label: 'Aller vers la carte',
                    icon: Icons.map,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullMapScreen(constructions: _constructions),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          /// 📋 PARTIE LISTE (50%)
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: _latestConstructions.length,
                  itemBuilder: (context, index) {
                    final c = _latestConstructions.reversed.toList()[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(c.type),
                        subtitle: Text(c.adresse),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),

                /// 🔘 Bouton Aller vers liste
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: _ModernNavButton(
                    label: 'Aller vers la liste',
                    icon: Icons.list,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConstructionListScreen(
                            constructions: _constructions,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Bouton moderne transparent
class _ModernNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ModernNavButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black.withAlpha(120),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
