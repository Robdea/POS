import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../categories/data/datasources/categories_local_datasource.dart';
import '../../../products/data/datasources/products_local_datasource.dart';

class DashboardData {
  const DashboardData({
    required this.totalProducts,
    required this.totalStockUnits,
    required this.lowStockCount,
    required this.sinStockCount,
    required this.nearExpirationCount,
    required this.expiredCount,
    required this.totalCategories,
  });

  final int totalProducts;
  final int totalStockUnits;
  final int lowStockCount;
  final int sinStockCount;
  final int nearExpirationCount;
  final int expiredCount;
  final int totalCategories;
}

final dashboardStatsProvider = FutureProvider<DashboardData>((ref) async {
  final products = await ProductsLocalDataSource().getAll();
  final categories = await CategoriesLocalDataSource().getAll();
  final now = DateTime.now();
  final nearThreshold =
      now.add(const Duration(days: AppConstants.nearExpirationDays));

  var totalStockUnits = 0;
  var lowStockCount = 0;
  var sinStockCount = 0;
  var nearExpirationCount = 0;
  var expiredCount = 0;

  for (final product in products) {
    totalStockUnits += product.currentStock;
    if (product.currentStock == 0) {
      sinStockCount++;
    } else if (product.currentStock <= AppConstants.lowStockThreshold) {
      lowStockCount++;
    }
    final exp = product.expirationDate;
    if (exp == null) continue;
    if (exp.isBefore(now)) {
      expiredCount++;
    } else if (exp.isBefore(nearThreshold)) {
      nearExpirationCount++;
    }
  }

  return DashboardData(
    totalProducts: products.length,
    totalStockUnits: totalStockUnits,
    lowStockCount: lowStockCount,
    sinStockCount: sinStockCount,
    nearExpirationCount: nearExpirationCount,
    expiredCount: expiredCount,
    totalCategories: categories.length,
  );
});