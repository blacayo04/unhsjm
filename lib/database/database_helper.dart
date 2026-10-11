import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/hardware.dart';
import '../models/software.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('unhsjm.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hardware (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL,
        nombre TEXT NOT NULL,
        tipo TEXT NOT NULL,
        marca TEXT,
        modelo TEXT,
        serie TEXT,
        estado TEXT NOT NULL,
        fecha TEXT NOT NULL,
        sincronizado INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE software (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        version TEXT,
        fabricante TEXT,
        tipo TEXT NOT NULL,
        estado TEXT NOT NULL,
        fecha TEXT NOT NULL,
        sincronizado INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE software (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        version TEXT,
        fabricante TEXT,
        tipo TEXT NOT NULL,
        estado TEXT NOT NULL,
        fecha TEXT NOT NULL,
        sincronizado INTEGER NOT NULL DEFAULT 0
      )
    ''');
    }
  }

  Future<int> insertHardware(Hardware hardware) async {
    final db = await instance.database;

    return await db.insert('hardware', hardware.toMap());
  }

  Future<List<Hardware>> getHardware() async {
    final db = await instance.database;

    final result = await db.query('hardware', orderBy: 'id DESC');

    return result.map((map) => Hardware.fromMap(map)).toList();
  }

  Future<int> updateHardware(Hardware hardware) async {
    final db = await instance.database;

    return await db.update(
      'hardware',
      hardware.toMap(),
      where: 'id = ?',
      whereArgs: [hardware.id],
    );
  }

  Future<int> deleteHardware(int id) async {
    final db = await instance.database;

    return await db.delete('hardware', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Hardware>> getPendingSyncHardware() async {
    final db = await instance.database;

    final result = await db.query(
      'hardware',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );

    return result.map((map) => Hardware.fromMap(map)).toList();
  }

  Future<List<Software>> getPendingSyncSoftware() async {
    final db = await database;

    final registros = await db.query(
      'software',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );

    return registros.map((registro) => Software.fromMap(registro)).toList();
  }

  Future<void> marcarHardwareSincronizado(int id) async {
    final db = await database;

    await db.update(
      'hardware',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> marcarSoftwareSincronizado(int id) async {
    final db = await database;

    await db.update(
      'software',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertSoftware(Software software) async {
    final db = await instance.database;

    return await db.insert('software', software.toMap());
  }

  Future<List<Software>> getSoftware() async {
    final db = await instance.database;

    final result = await db.query('software', orderBy: 'id DESC');

    return result.map((map) => Software.fromMap(map)).toList();
  }

  Future<int> updateSoftware(Software software) async {
    final db = await instance.database;

    return await db.update(
      'software',
      software.toMap(),
      where: 'id = ?',
      whereArgs: [software.id],
    );
  }

  Future<int> deleteSoftware(int id) async {
    final db = await instance.database;

    return await db.delete('software', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> guardarHardwareDescargado(Map<String, dynamic> registro) async {
    final db = await database;
    final id = registro['id'] as int?;

    if (id != null) {
      final local = await db.query(
        'hardware',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (local.isNotEmpty && local.first['sincronizado'] == 0) {
        return;
      }
    }

    await db.insert('hardware', {
      ...registro,
      'sincronizado': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> guardarSoftwareDescargado(Map<String, dynamic> registro) async {
    final db = await database;
    final id = registro['id'] as int?;

    if (id != null) {
      final local = await db.query(
        'software',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (local.isNotEmpty && local.first['sincronizado'] == 0) {
        return;
      }
    }

    await db.insert('software', {
      ...registro,
      'sincronizado': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
