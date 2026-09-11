import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../audit/presentation/providers/audit_provider.dart';
import '../../../products/data/datasources/products_local_datasource.dart';
import '../../data/datasources/categories_local_datasource.dart';
import '../../data/datasources/categories_remote_datasource.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/categories_repository_impl.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepositoryImpl(
    local: CategoriesLocalDataSource(),
    remote: CategoriesRemoteDataSource(),
    productsLocal: ProductsLocalDataSource(),
    audit: ref.watch(auditServiceProvider),
  );
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(categoriesRepositoryProvider).getCategories();
});