import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../models/category_model.dart';

class CategoriesLocalDataSource {
  Future<List<CategoryModel>> getAll() async {
    final db = await AppDatabase.database;
    final rows = await db.query(Tables.categories, orderBy: 'name ASC');
    return rows.map(_fromMap).toList();
  }

  Future<CategoryModel?> getById(String id) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      Tables.categories,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<void> upsert(CategoryModel category, {required bool pendingSync}) async {
    final db = await AppDatabase.database;
    await db.insert(
      Tables.categories,
      _toMap(category, pendingSync: pendingSync),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteById(String id) async {
    final db = await AppDatabase.database;
    await db.delete(
      Tables.categories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getPendingSync() async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      Tables.categories,
      where: 'pending_sync = 1',
      orderBy: 'updated_at ASC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> markSynced(String id) async {
    final db = await AppDatabase.database;
    await db.update(
      Tables.categories,
      {'pending_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(
    CategoryModel category, {
    required bool pendingSync,
  }) {
    return {
      'id': category.id,
      'name': category.name,
      'description': category.description,
      'created_at': category.createdAt.millisecondsSinceEpoch,
      'updated_at': category.updatedAt.millisecondsSinceEpoch,
      'pending_sync': pendingSync ? 1 : 0,
    };
  }

  CategoryModel _fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          map['updated_at'] as int,
        ),
        pendingSync: (map['pending_sync'] as int) == 1,
      );
}