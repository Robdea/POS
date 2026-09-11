import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../audit/presentation/providers/audit_provider.dart';
import '../../data/datasources/products_local_datasource.dart';
import '../../data/datasources/products_remote_datasource.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/products_repository.dart';
import '../../data/repositories/products_repository_impl.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(
    local: ProductsLocalDataSource(),
    remote: ProductsRemoteDataSource(),
    audit: ref.watch(auditServiceProvider),
  );
});

@immutable
class ProductFilters {
  const ProductFilters({
    this.query,
    this.categoryId,
    this.stockStatus,
  });

  final String? query;
  final String? categoryId;
  final ProductStockStatus? stockStatus;

  ProductFilters copyWith({
    String? query,
    String? categoryId,
    ProductStockStatus? stockStatus,
  }) {
    return ProductFilters(
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      stockStatus: stockStatus ?? this.stockStatus,
    );
  }
}

final productFiltersProvider = StateProvider<ProductFilters>((ref) {
  return const ProductFilters();
});

final productsProvider =
    FutureProvider.autoDispose.family<List<ProductModel>, ProductFilters>(
  (ref, filters) async {
    return ref.watch(productsRepositoryProvider).getProducts(
          query: filters.query,
          categoryId: filters.categoryId,
          stockStatus: filters.stockStatus,
        );
  },
);

final productProvider =
    FutureProvider.autoDispose.family<ProductModel?, String>(
  (ref, id) => ref.watch(productsRepositoryProvider).getById(id),
);

String messageFrom(Object error) {
  if (error is AppException) return error.message;
  return 'Ocurrió un error inesperado.';
}