import '../models/category_model.dart';

abstract class CategoriesRepository {
  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel?> getById(String id);

  Future<CategoryModel> create({
    required String name,
    String? description,
  });

  Future<CategoryModel> update({
    required String id,
    required String name,
    String? description,
  });

  Future<void> delete(String id);
}