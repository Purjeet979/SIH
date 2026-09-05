import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inspections.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const numType = 'REAL';
    
    await db.execute('''
CREATE TABLE inspections (
  id $idType,
  category $textType,
  timestamp $textType,
  latitude $numType,
  longitude $numType,
  violations $textType,
  synced INTEGER NOT NULL DEFAULT 0
)
''');
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition();
  }

  Future<int> insertInspection(String category, String violationsJson) async {
    final db = await instance.database;
    
    // Attempt to get Geotag
    Position? pos;
    try {
      pos = await _determinePosition();
    } catch (e) {
      print("Geotagging failed: $e");
    }

    final data = {
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
      'latitude': pos?.latitude ?? 0.0,
      'longitude': pos?.longitude ?? 0.0,
      'violations': violationsJson,
      'synced': 0
    };

    return await db.insert('inspections', data);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedInspections() async {
    final db = await instance.database;
    return await db.query('inspections', where: 'synced = 0');
  }

  Future<void> markAsSynced(int id) async {
    final db = await instance.database;
    await db.update('inspections', {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }
}
