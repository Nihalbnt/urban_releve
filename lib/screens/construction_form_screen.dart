import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/construction.dart';
import '../services/db_helper.dart';
import 'dart:convert';


class ConstructionFormScreen extends StatefulWidget {
  final List<LatLng> polygonPoints; // points dessinés sur la carte
  const ConstructionFormScreen({super.key, required this.polygonPoints});

  @override
  State<ConstructionFormScreen> createState() => _ConstructionFormScreenState();
}

class _ConstructionFormScreenState extends State<ConstructionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _type = 'Résidentiel';
  bool _saving = false;

  final DBHelper _dbHelper = DBHelper();
  final List<String> _types = ['Résidentiel', 'Commercial', 'Industriel', 'Autre'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une construction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, 'Nom de la construction'),
              const SizedBox(height: 12),
              _buildTextField(_addressController, 'Adresse'),
              const SizedBox(height: 12),
              _buildDropdown(),
              const SizedBox(height: 12),
              _buildTextField(_contactController, 'Contact (Nom ou téléphone)'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: _saving ? null : _saveConstruction,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enregistrer', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Entrez $label',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Ce champ est obligatoire' : null,
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _type,
      items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
      onChanged: (value) {
        if (value != null) setState(() => _type = value);
      },
      decoration: InputDecoration(
        labelText: 'Type de construction',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _saveConstruction() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.polygonPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez dessiner le polygone sur la carte')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // convertir les points en GeoJSON simple
      final geoJson = _polygonToGeoJson(widget.polygonPoints);

      final construction = Construction(
        type: _type,
        adresse: _addressController.text.trim(),
        contact: _contactController.text.trim(),
        polygonGeoJson: geoJson,
        date: DateTime.now(),
      );

      await _dbHelper.insertConstruction(construction);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Construction enregistrée !')),
      );

      Navigator.pop(context, true); // retourne true pour refresh carte
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'enregistrement')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

 String _polygonToGeoJson(List<LatLng> points) {
  final coordinates = points
      .map((p) => [p.longitude, p.latitude])
      .toList();

  return jsonEncode({
    "type": "Polygon",
    "coordinates": [coordinates]
  });
}

}
