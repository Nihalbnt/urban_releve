// polygon_widget.dart
import 'package:latlong2/latlong.dart';
import 'dart:convert';

List<LatLng> geoJsonToLatLng(String geoJson) {
  final data = json.decode(geoJson);
  final coords = data['coordinates'][0] as List;
  return coords.map((e) => LatLng(e[1], e[0])).toList();
}
