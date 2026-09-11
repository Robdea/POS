import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../models/user_model.dart';

class UserLocalDataSource {
  Future<UserModel?> getUser(String id) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      Tables.users,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<void> insert(UserModel user) async {
    final db = await AppDatabase.database;
    await db.insert(
      Tables.users,
      _toMap(user),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<UserModel>> getUsers() async {
    final db = await AppDatabase.database;
    final rows = await db.query(Tables.users, orderBy: 'name ASC');
    return rows.map(_fromMap).toList();
  }

  Future<List<UserModel>> getPendingSync() async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      Tables.users,
      where: 'pending_sync = 1',
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> markSynced(String id) async {
    final db = await AppDatabase.database;
    await db.update(
      Tables.users,
      {'pending_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateRole(
    String id,
    String role,
    DateTime updatedAt,
  ) async {
    final db = await AppDatabase.database;
    await db.update(
      Tables.users,
      {
        'role': role,
        'updated_at': updatedAt.millisecondsSinceEpoch,
        'pending_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(UserModel user) => {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'role': user.role,
        'created_at': user.createdAt.millisecondsSinceEpoch,
        'updated_at': user.updatedAt.millisecondsSinceEpoch,
        'pending_sync': user.pendingSync ? 1 : 0,
      };

  UserModel _fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'] as String,
        name: map['name'] as String,
        email: map['email'] as String,
        role: map['role'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          map['updated_at'] as int,
        ),
        pendingSync: (map['pending_sync'] as int) == 1,
      );
}