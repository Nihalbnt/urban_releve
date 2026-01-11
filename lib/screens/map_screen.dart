import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/construction.dart';
import '../services/db_helper.dart';
import 'construction_form_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Construction> _constructions = [];
  List<Polygon> _polygons = [];

  @override
  void initState() {
    super.initState();
    _loadConstructions();
  }

  Future<void> _loadConstructions() async {
    final constructions = await _dbHelper.getAllConstructions();

    setState(() {
      _constructions = constructions;
      _polygons = constructions.map(_constructionToPolygon).toList();
    });
  }

  Polygon _constructionToPolygon(Construction c) {
    final coordsJson = c.polygonGeoJson;
    List<LatLng> points = [];
    try {
      final regex = RegExp(r'\[([-\d\.]+),([-\d\.]+)\]');
      for (final match in regex.allMatches(coordsJson)) {
        final lng = double.parse(match.group(1)!);
        final lat = double.parse(match.group(2)!);
        points.add(LatLng(lat, lng));
      }
    } catch (e) {
      debugPrint('Erreur parsing GeoJSON: $e');
    }

    Color color;
    switch (c.type) {
      case 'Résidentiel':
        color = const Color.fromARGB(128, 255, 0, 0); // 50% opacity
        break;
      case 'Commercial':
        color = const Color.fromARGB(128, 0, 0, 255);
        break;
      case 'Industriel':
        color = const Color.fromARGB(128, 255, 165, 0);
        break;
      default:
        color = const Color.fromARGB(128, 0, 128, 0);
    }

    return Polygon(
      points: points,
      color: color,
      borderColor: Colors.black,
      borderStrokeWidth: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carte des constructions')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(33.5731, -7.5898), // Casablanca par défaut
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          PolygonLayer(polygons: _polygons),
          MarkerLayer(
            markers: _constructions.map((c) {
              if (c.polygonGeoJson.isEmpty) return null;
              List<LatLng> points = [];
              final regex = RegExp(r'\[([-\d\.]+),([-\d\.]+)\]');
              for (final match in regex.allMatches(c.polygonGeoJson)) {
                final lng = double.parse(match.group(1)!);
                final lat = double.parse(match.group(2)!);
                points.add(LatLng(lat, lng));
              }
              if (points.isEmpty) return null;

              double avgLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
              double avgLng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;

              return Marker(
                point: LatLng(avgLat, avgLng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => _showConstructionInfo(c),
                  child: const Icon(Icons.location_on, color: Colors.black, size: 30),
                ),
              );
            }).whereType<Marker>().toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addConstruction,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showConstructionInfo(Construction c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(c.type),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nom: ${c.adresse}'),
            Text('Contact: ${c.contact}'),
            Text('Date: ${c.date.toLocal()}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
        ],
      ),
    );
  }

  Future<void> _addConstruction() async {
    final polygonPoints = <LatLng>[
      LatLng(33.573, -7.590),
      LatLng(33.572, -7.590),
      LatLng(33.572, -7.589),
      LatLng(33.573, -7.589),
    ];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConstructionFormScreen(polygonPoints: polygonPoints),
      ),
    );

    if (result == true) {
      _loadConstructions();
    }
  }
}
