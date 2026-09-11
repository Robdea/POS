import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/connectivity_helper.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../audit/domain/audit_service.dart';
import '../../../products/data/datasources/products_local_datasource.dart';
import '../datasources/categories_local_datasource.dart';
import '../datasources/categories_remote_datasource.dart';
import '../models/category_model.dart';
import 'categories_repository.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl({
    required CategoriesLocalDataSource local,
    required CategoriesRemoteDataSource remote,
    required ProductsLocalDataSource productsLocal,
    required AuditService audit,
  })  : _local = local,
        _remote = remote,
        _productsLocal = productsLocal,
        _audit = audit;

  final CategoriesLocalDataSource _local;
  final CategoriesRemoteDataSource _remote;
  final ProductsLocalDataSource _productsLocal;
  final AuditService _audit;

  @override
  Future<List<CategoryModel>> getCategories() async {
    await _pullFromRemote();
    return _local.getAll();
  }

  @override
  Future<CategoryModel?> getById(String id) async {
    await _pullFromRemote();
    return _local.getById(id);
  }

  @override
  Future<CategoryModel> create({
    required String name,
    String? description,
  }) async {
    final now = DateTime.now();
    final category = CategoryModel(
      id: IdGenerator.generate(),
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    await _local.upsert(category, pendingSync: true);
    await _audit.record(
      action: AuditAction.createCategory,
      entityType: 'category',
      entityId: category.id,
      description: 'Categoría creada: ${category.name}',
    );
    await _push(category);
    return category;
  }

  @override
  Future<CategoryModel> update({
    required String id,
    required String name,
    String? description,
  }) async {
    final existing = await _local.getById(id);
    if (existing == null) {
      throw const AppException('La categoría no existe localmente.');
    }
    final updated = existing.copyWith(
      name: name,
      description: description,
      updatedAt: DateTime.now(),
    );
    await _local.upsert(updated, pendingSync: true);
    await _audit.record(
      action: AuditAction.updateCategory,
      entityType: 'category',
      entityId: updated.id,
      description: 'Categoría actualizada: ${updated.name}',
    );
    await _push(updated);
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    final usedCount = await _productsLocal.countByCategory(id);
    if (usedCount > 0) {
      throw AppException(
        'No se puede eliminar: hay $usedCount producto(s) en esta categoría.',
      );
    }
    if (!await ConnectivityHelper.hasConnection()) {
      throw const OfflineOperationException(
        'No es posible eliminar categorías sin conexión.',
      );
    }
    final existing = await _local.getById(id);
    if (existing == null) {
      throw const AppException('La categoría no existe localmente.');
    }
    await _remote.deleteById(id);
    await _local.deleteById(id);
    await _audit.record(
      action: AuditAction.deleteCategory,
      entityType: 'category',
      entityId: existing.id,
      description: 'Categoría eliminada: ${existing.name}',
    );
  }

  Future<void> _push(CategoryModel category) async {
    if (!await ConnectivityHelper.hasConnection()) return;
    try {
      await _remote.upsert(category);
      await _local.markSynced(category.id);
    } catch (_) {}
  }

  Future<void> _pullFromRemote() async {
    if (!await ConnectivityHelper.hasConnection()) return;
    try {
      final remote = await _remote.getAll();
      for (final category in remote) {
        final local = await _local.getById(category.id);
        if (local == null || !local.pendingSync) {
          await _local.upsert(category, pendingSync: false);
        }
      }
    } catch (_) {}
  }
}