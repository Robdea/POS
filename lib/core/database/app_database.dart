import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(Tables.createUsers);
    await db.execute(Tables.createCategories);
    await db.execute(Tables.createProducts);
    await db.execute(Tables.createAuditLogs);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE ${Tables.auditLogs} '
        'ADD COLUMN pending_sync INTEGER NOT NULL DEFAULT 1',
      );
    }
  }

  static Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
