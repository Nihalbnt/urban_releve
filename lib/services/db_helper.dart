import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/construction.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'urban_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE constructions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            adresse TEXT,
            contact TEXT,
            polygon_geojson TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  /// INSÉRER UNE CONSTRUCTION
  Future<void> insertConstruction(Construction construction) async {
    final db = await database;
    await db.insert(
      'constructions',
      {
        'type': construction.type,
        'adresse': construction.adresse,
        'contact': construction.contact,
        'polygon_geojson': construction.polygonGeoJson,
        'date': construction.date.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// RÉCUPÉRER TOUTES LES CONSTRUCTIONS
  Future<List<Construction>> getAllConstructions() async {
    final db = await database;
    final res = await db.query('constructions', orderBy: 'id DESC');
    return res.map((e) => Construction(
      id: e['id'] as int?,
      type: e['type'] as String,
      adresse: e['adresse'] as String,
      contact: e['contact'] as String,
      polygonGeoJson: e['polygon_geojson'] as String,
      date: DateTime.parse(e['date'] as String),
    )).toList();
  }
}
