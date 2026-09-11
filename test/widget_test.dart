import 'package:flutter_test/flutter_test.dart';

import 'package:inventory/core/constants/app_constants.dart';
import 'package:inventory/core/utils/date_helpers.dart';
import 'package:inventory/features/auth/data/models/user_model.dart';
import 'package:inventory/features/products/data/models/product_model.dart';

void main() {
  test('Umbrales de stock y caducidad', () {
    expect(AppConstants.lowStockThreshold, 10);
    expect(AppConstants.nearExpirationDays, 7);
  });

  test('UserModel soporta serialización con freezed', () {
    final now = DateTime(2026, 1, 1);
    final user = UserModel(
      id: 'uid-1',
      name: 'Juan Pérez',
      email: 'juan@test.com',
      role: 'Jefe',
      createdAt: now,
      updatedAt: now,
    );

    final json = user.toJson();
    final restored = UserModel.fromJson(json);

    expect(restored.id, user.id);
    expect(restored.role, 'Jefe');
    expect(restored, user);
  });

  test('ProductModel soporta serialización con freezed', () {
    final now = DateTime(2026, 1, 1);
    final product = ProductModel(
      id: 'p-1',
      name: 'Arroz',
      categoryId: 'c-1',
      entryDate: now,
      expirationDate: DateTime(2027, 1, 1),
      currentStock: 25,
      purchaseCost: 120.50,
      createdAt: now,
      updatedAt: now,
    );

    final json = product.toJson();
    final restored = ProductModel.fromJson(json);

    expect(restored.name, 'Arroz');
    expect(restored.currentStock, 25);
    expect(restored.purchaseCost, 120.50);
  });

  test('DateHelpers detecta caducidad', () {
    final expired = DateTime.now().subtract(const Duration(days: 1));
    final future = DateTime.now().add(const Duration(days: 30));

    expect(DateHelpers.isExpired(expired), isTrue);
    expect(DateHelpers.isExpired(future), isFalse);
    expect(DateHelpers.isExpired(null), isFalse);
  });

  test('DateHelpers detecta próximos a caducar', () {
    final inThreeDays = DateTime.now().add(const Duration(days: 3));
    expect(DateHelpers.isNearExpiration(inThreeDays), isTrue);

    final inThirtyDays = DateTime.now().add(const Duration(days: 30));
    expect(DateHelpers.isNearExpiration(inThirtyDays), isFalse);
  });

  test('UserRole contiene únicamente Empleado y Jefe', () {
    final roles = UserRole.values.map((r) => r.label).toList();
    expect(roles, contains('Empleado'));
    expect(roles, contains('Jefe'));
    expect(roles.length, 2);
  });
}