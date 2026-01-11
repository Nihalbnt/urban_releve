import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/db_helper.dart';
import '../models/construction.dart';
import 'construction_form_screen.dart';
import 'dart:convert';

class DrawMapScreen extends StatefulWidget {
  const DrawMapScreen({super.key});

  @override
  State<DrawMapScreen> createState() => _DrawMapScreenState();
}

class _DrawMapScreenState extends State<DrawMapScreen> {
  final DBHelper _dbHelper = DBHelper();
  final MapController _mapController = MapController();

  bool _drawingMode = false;
  List<LatLng> _currentPolygon = [];
  List<Construction> _constructions = [];

  static const Color _actionColor = Color(0xFF4F46E5);
  static const double _btnWidth = 220;

  @override
  void initState() {
    super.initState();
    _loadConstructions();
  }

  Future<void> _loadConstructions() async {
    final data = await _dbHelper.getAllConstructions();
    setState(() => _constructions = data);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (_drawingMode) {
      setState(() => _currentPolygon.add(point));
    }
  }

  void _startDrawing() {
    setState(() {
      _drawingMode = true;
      _currentPolygon.clear();
    });
  }

  void _cancelDrawing() {
    setState(() {
      _drawingMode = false;
      _currentPolygon.clear();
    });
  }

  Future<void> _validateDrawing() async {
    if (_currentPolygon.isEmpty) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConstructionFormScreen(
          polygonPoints: List.from(_currentPolygon),
        ),
      ),
    );

    if (result == true) {
      _cancelDrawing();
      _loadConstructions();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relevé cartographique')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(33.5731, -7.5898),
              initialZoom: 13,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),

              /// Constructions existantes
              PolygonLayer(
                polygons: _constructions.map((c) {
                  return Polygon(
                    points: _geoJsonToLatLng(c.polygonGeoJson),
                    color: _colorByType(c.type),
                    borderColor: Colors.black,
                    borderStrokeWidth: 2,
                  );
                }).toList(),
              ),

              /// Polygone en cours
              if (_currentPolygon.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _currentPolygon,
                      color: _actionColor.withAlpha(100),
                      borderColor: _actionColor,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
            ],
          ),

          /// Boutons action (bas droite)
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!_drawingMode)
                  _actionButton(
                    icon: Icons.edit,
                    label: 'Ajouter une construction',
                    onPressed: _startDrawing,
                  ),

                if (_drawingMode && _currentPolygon.isNotEmpty) ...[
                  _actionButton(
                    icon: Icons.check,
                    label: 'Valider dessin',
                    onPressed: _validateDrawing,
                  ),
                  const SizedBox(height: 12),
                  _actionButton(
                    icon: Icons.close,
                    label: 'Annuler construction',
                    onPressed: _cancelDrawing,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: _btnWidth,
      height: 48,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: _actionColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  List<LatLng> _geoJsonToLatLng(String geoJson) {
    try {
      final decoded = jsonDecode(geoJson);
      final List coordinates = decoded['coordinates'][0];

      return coordinates.map<LatLng>((point) {
        return LatLng(point[1], point[0]);
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
