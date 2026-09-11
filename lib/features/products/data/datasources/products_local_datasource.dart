import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../models/product_model.dart';

class ProductsLocalDataSource {
  Future<List<ProductModel>> getAll() async {
    final db = await AppDatabase.database;
    final rows = await db.query(Tables.products, orderBy: 'name ASC');
    return rows.map(_fromMap).toList();
  }

  Future<ProductModel?> getById(String id) async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      Tables.products,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<List<ProductModel>> search({
    String? query,
    String? categoryId,
    ProductStockStatus? stockStatus,
  }) async {
    final db = await AppDatabase.database;
    final where = <String>[];
    final args = <Object?>[];

    if (query != null && query.trim().isNotEmpty) {
      where.add('name LIKE ?');
      args.add('%${query.trim()}%');
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      where.add('category_id = ?');
      args.add(categoryId);
    }
    if (stockStatus != null) {
      switch (stockStatus) {
        case ProductStockStatus.sinStock:
          where.add('current_stock = 0');
          break;
        case ProductStockStatus.stockBajo:
          where.add('current_stock > 0 AND current_stock <= ?');
          args.add(AppConstants.lowStockThreshold);
          break;
        case ProductStockStatus.disponible:
          where.add('current_stock > ?');
          args.add(AppConstants.lowStockThreshold);
          break;
      }
    }

    final rows = await db.query(
      Tables.products,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name ASC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> upsert(ProductModel product, {required bool pendingSync}) async {
    final db = await AppDatabase.database;
    await db.insert(
      Tables.products,
      _toMap(product, pendingSync: pendingSync),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteById(String id) async {
    final db = await AppDatabase.database;
    await db.delete(
      Tables.products,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ProductModel>> getPendingSync() async {
    final db = await AppDatabase.database;
    final rows = await db.query(
      Tables.products,
      where: 'pending_sync = 1',
      orderBy: 'updated_at ASC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> markSynced(String id) async {
    final db = await AppDatabase.database;
    await db.update(
      Tables.products,
      {'pending_sync': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countByCategory(String categoryId) async {
    final db = await AppDatabase.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${Tables.products} WHERE category_id = ?',
      [categoryId],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  Map<String, dynamic> _toMap(
    ProductModel product, {
    required bool pendingSync,
  }) {
    return {
      'id': product.id,
      'name': product.name,
      'description': product.description,
      'category_id': product.categoryId,
      'entry_date': product.entryDate.millisecondsSinceEpoch,
      'expiration_date': product.expirationDate?.millisecondsSinceEpoch,
      'current_stock': product.currentStock,
      'purchase_cost': product.purchaseCost,
      'created_at': product.createdAt.millisecondsSinceEpoch,
      'updated_at': product.updatedAt.millisecondsSinceEpoch,
      'pending_sync': pendingSync ? 1 : 0,
    };
  }

  ProductModel _fromMap(Map<String, dynamic> map) => ProductModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        categoryId: map['category_id'] as String,
        entryDate: DateTime.fromMillisecondsSinceEpoch(
          map['entry_date'] as int,
        ),
        expirationDate: map['expiration_date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                map['expiration_date'] as int,
              ),
        currentStock: map['current_stock'] as int,
        purchaseCost: (map['purchase_cost'] as num).toDouble(),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          map['updated_at'] as int,
        ),
        pendingSync: (map['pending_sync'] as int) == 1,
      );
}