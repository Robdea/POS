import 'dart:async';

import '../../../../core/utils/connectivity_helper.dart';
import '../../audit/data/datasources/audit_local_datasource.dart';
import '../../audit/data/datasources/audit_remote_datasource.dart';
import '../../categories/data/datasources/categories_local_datasource.dart';
import '../../categories/data/datasources/categories_remote_datasource.dart';
import '../../auth/data/datasources/user_local_datasource.dart';
import '../../users/data/datasources/users_remote_datasource.dart';
import '../../products/data/datasources/products_local_datasource.dart';
import '../../products/data/datasources/products_remote_datasource.dart';

class SyncService {
  SyncService({
    required this.productsLocal,
    required this.productsRemote,
    required this.categoriesLocal,
    required this.categoriesRemote,
    required this.usersLocal,
    required this.usersRemote,
    required this.auditLocal,
    required this.auditRemote,
  });

  final ProductsLocalDataSource productsLocal;
  final ProductsRemoteDataSource productsRemote;
  final CategoriesLocalDataSource categoriesLocal;
  final CategoriesRemoteDataSource categoriesRemote;
  final UserLocalDataSource usersLocal;
  final UsersRemoteDataSource usersRemote;
  final AuditLocalDataSource auditLocal;
  final AuditRemoteDataSource auditRemote;

  StreamSubscription<bool>? _subscription;
  bool _syncing = false;

  void start() {
    _subscription = ConnectivityHelper.onConnectionChanged.listen(
      (connected) async {
        if (connected) await sync();
      },
    );
    unawaited(_syncIfConnected());
  }

  Future<void> _syncIfConnected() async {
    if (await ConnectivityHelper.hasConnection()) {
      await sync();
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> sync() async {
    if (_syncing) return;
    _syncing = true;
    try {
      await _pushPendingOperations();
      await _pullRemoteChanges();
    } finally {
      _syncing = false;
    }
  }

  Future<void> _pushPendingOperations() async {
    for (final product in await productsLocal.getPendingSync()) {
      try {
        await productsRemote.upsert(product);
        await productsLocal.markSynced(product.id);
      } catch (_) {}
    }

    for (final category in await categoriesLocal.getPendingSync()) {
      try {
        await categoriesRemote.upsert(category);
        await categoriesLocal.markSynced(category.id);
      } catch (_) {}
    }

    for (final user in await usersLocal.getPendingSync()) {
      try {
        await usersRemote.upsert(user);
        await usersLocal.markSynced(user.id);
      } catch (_) {}
    }

    for (final log in await auditLocal.getPendingSync()) {
      try {
        await auditRemote.upsert(log);
        await auditLocal.markSynced(log.id);
      } catch (_) {}
    }
  }

  Future<void> _pullRemoteChanges() async {
    await _pullProducts();
    await _pullCategories();
    await _pullUsers();
    await _pullAuditLogs();
  }

  Future<void> _pullProducts() async {
    try {
      final remote = await productsRemote.getAll();
      for (final product in remote) {
        final local = await productsLocal.getById(product.id);
        if (local == null || !local.pendingSync) {
          await productsLocal.upsert(product, pendingSync: false);
        }
      }
    } catch (_) {}
  }

  Future<void> _pullCategories() async {
    try {
      final remote = await categoriesRemote.getAll();
      for (final category in remote) {
        final local = await categoriesLocal.getById(category.id);
        if (local == null || !local.pendingSync) {
          await categoriesLocal.upsert(category, pendingSync: false);
        }
      }
    } catch (_) {}
  }

  Future<void> _pullUsers() async {
    try {
      final remote = await usersRemote.getAll();
      for (final user in remote) {
        final local = await usersLocal.getUser(user.id);
        if (local == null || !local.pendingSync) {
          await usersLocal.insert(user);
        }
      }
    } catch (_) {}
  }

  Future<void> _pullAuditLogs() async {
    try {
      final remote = await auditRemote.getAll();
      for (final log in remote) {
        final existing = await auditLocal.getById(log.id);
        if (existing == null) {
          await auditLocal.insert(log);
        }
      }
    } catch (_) {}
  }
}