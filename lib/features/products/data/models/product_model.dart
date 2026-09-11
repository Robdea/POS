import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    String? description,
    required String categoryId,
    required DateTime entryDate,
    DateTime? expirationDate,
    required int currentStock,
    required double purchaseCost,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool pendingSync,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
