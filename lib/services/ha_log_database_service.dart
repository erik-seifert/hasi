import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class HaLogDatabaseService {
  static Database? _database;
  static const String tableName = 'ha_logs';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ha_communication.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            direction TEXT, -- 'SENT' or 'RECEIVED'
            payload TEXT,
            type TEXT
          )
        ''');
      },
    );
  }

  static Future<void> log(String direction, dynamic payload) async {
    try {
      final db = await database;
      String payloadStr;
      String? type;

      if (payload is Map) {
        payloadStr = jsonEncode(payload);
        type = payload['type'];
      } else if (payload is String) {
        payloadStr = payload;
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            type = decoded['type'];
          }
        } catch (_) {}
      } else {
        payloadStr = payload.toString();
      }

      await db.insert(tableName, {
        'timestamp': DateTime.now().toIso8601String(),
        'direction': direction,
        'payload': payloadStr,
        'type': type ?? 'unknown',
      });

      // Maintain a limit (keep last 1000 logs)
      _trimLogs(db);
    } catch (e) {
      // Don't use AppLogger here to avoid circularity if we ever log logger errors
      print('Error logging to HA database: $e');
    }
  }

  static Future<void> _trimLogs(Database db) async {
    try {
      // Delete entries if they exceed 1000
      await db.execute('''
        DELETE FROM $tableName WHERE id IN (
          SELECT id FROM $tableName ORDER BY id DESC LIMIT -1 OFFSET 1000
        )
      ''');
    } catch (e) {
      print('Error trimming HA logs: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLogs({int limit = 100}) async {
    final db = await database;
    return await db.query(tableName, orderBy: 'id DESC', limit: limit);
  }

  static Future<void> clearLogs() async {
    final db = await database;
    await db.delete(tableName);
  }
}
