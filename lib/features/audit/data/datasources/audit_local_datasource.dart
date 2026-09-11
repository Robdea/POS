import 'package:sqflite/sqflite.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../models/audit_log_model.dart';

class AuditLocalDataSource {
  Future<void> insert(AuditLogModel log) async {
    final db = await AppDatabase.database;
    await db.insert(
      Tables.auditLogs,
      _toMap(log),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AuditLogModel?> getById(String id) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      Tables.auditLogs,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<List<AuditLogModel>> getLogs({
    String? userId,
    String? action,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await AppDatabase.database;
    final where = <String>[];
    final args = <Object?>[];

    if (userId != null && userId.isNotEmpty) {
      where.add('user_id = ?');
      args.add(userId);
    }
    if (action != null && action.isNotEmpty) {
      where.add('action = ?');
      args.add(action);
    }
    if (from != null) {
      where.add('created_at >= ?');
      args.add(from.millisecondsSinceEpoch);
    }
    if (to != null) {
      where.add('created_at <= ?');
      args.add(to.millisecondsSinceEpoch);
    }

    final rows = await db.query(
      Tables.auditLogs,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<AuditLogModel>> getPendingSync() async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      Tables.auditLogs,
      where: 'pending_sync = 1',
      orderBy: 'created_at ASC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> markSynced(String id) async {
    final db = await AppDatabase.database;
    await db.update(
      Tables.auditLogs,
      {'pending_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Map<String, dynamic> _toMap(AuditLogModel log) => {
        'id': log.id,
        'user_id': log.userId,
        'user_name': log.userName,
        'action': log.action,
        'entity_type': log.entityType,
        'entity_id': log.entityId,
        'description': log.description,
        'created_at': log.createdAt.millisecondsSinceEpoch,
        'pending_sync': 1,
      };

  AuditLogModel _fromMap(Map<String, dynamic> map) => AuditLogModel(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        userName: map['user_name'] as String,
        action: map['action'] as String,
        entityType: map['entity_type'] as String,
        entityId: map['entity_id'] as String,
        description: map['description'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int,
        ),
      );
}