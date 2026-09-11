import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/connectivity_helper.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../audit/domain/audit_service.dart';
import '../datasources/products_local_datasource.dart';
import '../datasources/products_remote_datasource.dart';
import '../models/product_model.dart';
import 'products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl({
    required ProductsLocalDataSource local,
    required ProductsRemoteDataSource remote,
    required AuditService audit,
  })  : _local = local,
        _remote = remote,
        _audit = audit;

  final ProductsLocalDataSource _local;
  final ProductsRemoteDataSource _remote;
  final AuditService _audit;

  @override
  Future<List<ProductModel>> getProducts({
    String? query,
    String? categoryId,
    ProductStockStatus? stockStatus,
  }) async {
    await _pullFromRemote();
    return _local.search(
      query: query,
      categoryId: categoryId,
      stockStatus: stockStatus,
    );
  }

  @override
  Future<ProductModel?> getById(String id) async {
    await _pullFromRemote();
    return _local.getById(id);
  }

  @override
  Future<ProductModel> create({
    required String name,
    String? description,
    required String categoryId,
    required DateTime entryDate,
    DateTime? expirationDate,
    required int currentStock,
    required double purchaseCost,
  }) async {
    final now = DateTime.now();
    final product = ProductModel(
      id: IdGenerator.generate(),
      name: name,
      description: description,
      categoryId: categoryId,
      entryDate: entryDate,
      expirationDate: expirationDate,
      currentStock: currentStock,
      purchaseCost: purchaseCost,
      createdAt: now,
      updatedAt: now,
    );
    await _local.upsert(product, pendingSync: true);
    await _audit.record(
      action: AuditAction.createProduct,
      entityType: 'product',
      entityId: product.id,
      description: 'Producto creado: ${product.name}',
    );
    await _push(product);
    return product;
  }

  @override
  Future<ProductModel> update({
    required String id,
    required String name,
    String? description,
    required String categoryId,
    required DateTime entryDate,
    DateTime? expirationDate,
    required double purchaseCost,
  }) async {
    final existing = await _local.getById(id);
    if (existing == null) {
      throw const AppException('El producto no existe localmente.');
    }
    final updated = existing.copyWith(
      name: name,
      description: description,
      categoryId: categoryId,
      entryDate: entryDate,
      expirationDate: expirationDate,
      purchaseCost: purchaseCost,
      updatedAt: DateTime.now(),
    );
    await _local.upsert(updated, pendingSync: true);
    await _audit.record(
      action: AuditAction.updateProduct,
      entityType: 'product',
      entityId: updated.id,
      description: 'Producto actualizado: ${updated.name}',
    );
    await _push(updated);
    return updated;
  }

  @override
  Future<ProductModel> updateStock(String id, int newStock) async {
    final existing = await _local.getById(id);
    if (existing == null) {
      throw const AppException('El producto no existe localmente.');
    }
    final updated = existing.copyWith(
      currentStock: newStock,
      updatedAt: DateTime.now(),
    );
    await _local.upsert(updated, pendingSync: true);
    await _audit.record(
      action: AuditAction.updateStock,
      entityType: 'product',
      entityId: updated.id,
      description:
          'Stock actualizado de ${existing.currentStock} a $newStock',
    );
    await _push(updated);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    if (!await ConnectivityHelper.hasConnection()) {
      throw const OfflineOperationException(
        'No es posible eliminar productos sin conexión.',
      );
    }
    final existing = await _local.getById(id);
    if (existing == null) {
      throw const AppException('El producto no existe localmente.');
    }
    await _remote.deleteById(id);
    await _local.deleteById(id);
    await _audit.record(
      action: AuditAction.deleteProduct,
      entityType: 'product',
      entityId: existing.id,
      description: 'Producto eliminado: ${existing.name}',
    );
  }

  Future<void> _push(ProductModel product) async {
    if (!await ConnectivityHelper.hasConnection()) return;
    try {
      await _remote.upsert(product);
      await _local.markSynced(product.id);
    } catch (_) {}
  }

  Future<void> _pullFromRemote() async {
    if (!await ConnectivityHelper.hasConnection()) return;
    try {
      final remote = await _remote.getAll();
      for (final product in remote) {
        final local = await _local.getById(product.id);
        if (local == null || !local.pendingSync) {
          await _local.upsert(product, pendingSync: false);
        }
      }
    } catch (_) {}
  }
}