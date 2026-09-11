import '../../../../core/constants/app_constants.dart';
import '../models/product_model.dart';

abstract class ProductsRepository {
  Future<List<ProductModel>> getProducts({
    String? query,
    String? categoryId,
    ProductStockStatus? stockStatus,
  });

  Future<ProductModel?> getById(String id);

  Future<ProductModel> create({
    required String name,
    String? description,
    required String categoryId,
    required DateTime entryDate,
    DateTime? expirationDate,
    required int currentStock,
    required double purchaseCost,
  });

  Future<ProductModel> update({
    required String id,
    required String name,
    String? description,
    required String categoryId,
    required DateTime entryDate,
    DateTime? expirationDate,
    required double purchaseCost,
  });

  Future<ProductModel> updateStock(String id, int newStock);

  Future<void> delete(String id);
}