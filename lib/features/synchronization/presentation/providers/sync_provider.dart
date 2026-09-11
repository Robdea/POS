import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../audit/data/datasources/audit_local_datasource.dart';
import '../../../audit/data/datasources/audit_remote_datasource.dart';
import '../../../categories/data/datasources/categories_local_datasource.dart';
import '../../../categories/data/datasources/categories_remote_datasource.dart';
import '../../../auth/data/datasources/user_local_datasource.dart';
import '../../../users/data/datasources/users_remote_datasource.dart';
import '../../../products/data/datasources/products_local_datasource.dart';
import '../../../products/data/datasources/products_remote_datasource.dart';
import '../../data/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    productsLocal: ProductsLocalDataSource(),
    productsRemote: ProductsRemoteDataSource(),
    categoriesLocal: CategoriesLocalDataSource(),
    categoriesRemote: CategoriesRemoteDataSource(),
    usersLocal: UserLocalDataSource(),
    usersRemote: UsersRemoteDataSource(),
    auditLocal: AuditLocalDataSource(),
    auditRemote: AuditRemoteDataSource(),
  );
  service.start();
  ref.onDispose(service.dispose);
  return service;
});