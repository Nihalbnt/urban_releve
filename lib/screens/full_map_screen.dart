import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/construction.dart';
import '../services/db_helper.dart';
import 'draw_map_screen.dart';
import 'construction_list_screen.dart';
import 'dart:convert';

class FullMapScreen extends StatefulWidget {
  final List<Construction> constructions;

  const FullMapScreen({super.key, required this.constructions});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  final MapController _mapController = MapController();

  Color _colorByType(String type) {
    switch (type) {
      case 'Résidentiel':
        return Colors.blue.withAlpha(120);
      case 'Commercial':
        return Colors.orange.withAlpha(120);
      case 'Industriel':
        return Colors.purple.withAlpha(120);
      default:
        return Colors.grey.withAlpha(120);
    }
  }

  List<LatLng> _geoJsonToLatLng(String geoJson) {
    final decoded = jsonDecode(geoJson);
    final List coords = decoded['coordinates'][0];
    return coords.map<LatLng>((p) => LatLng(p[1], p[0])).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des constructions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DrawMapScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Aller vers la liste',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConstructionListScreen(
                    constructions: widget.constructions,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(33.5731, -7.5898),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          PolygonLayer(
            polygons: widget.constructions.map((c) {
              return Polygon(
                points: _geoJsonToLatLng(c.polygonGeoJson),
                color: _colorByType(c.type),
                borderColor: Colors.black,
                borderStrokeWidth: 2,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
