class Construction {
  int? id;
  String type;
  String adresse;
  String contact;
  String polygonGeoJson;
  DateTime date;
  

  Construction({
    this.id,
    required this.type,
    required this.adresse,
    required this.contact,
    required this.polygonGeoJson,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'adresse': adresse,
      'contact': contact,
      'polygon_geojson': polygonGeoJson,
      'date': date.toIso8601String(),
    };
  }

  factory Construction.fromMap(Map<String, dynamic> map) {
    return Construction(
      id: map['id'],
      type: map['type'],
      adresse: map['adresse'],
      contact: map['contact'],
      polygonGeoJson: map['polygon_geojson'],
      date: DateTime.parse(map['date']),
    );
  }
}
