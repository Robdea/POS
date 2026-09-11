import 'package:flutter_test/flutter_test.dart';

import 'package:inventory/core/constants/app_constants.dart';
import 'package:inventory/features/products/data/models/product_model.dart';
import 'package:inventory/features/products/presentation/product_status_helper.dart';

ProductModel _product({
  int stock = 100,
  DateTime? expirationDate,
  bool sinFecha = false,
}) {
  final now = DateTime.now();
  return ProductModel(
    id: 'p-test',
    name: 'Producto',
    categoryId: 'c-1',
    entryDate: now,
    expirationDate: sinFecha ? null : (expirationDate ?? now.add(const Duration(days: 60))),
    currentStock: stock,
    purchaseCost: 50.0,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  test('stockStatusOf clasifica sin stock', () {
    expect(stockStatusOf(_product(stock: 0)), ProductStockStatus.sinStock);
  });

  test('stockStatusOf clasifica stock bajo por umbral', () {
    expect(
      stockStatusOf(_product(stock: AppConstants.lowStockThreshold)),
      ProductStockStatus.stockBajo,
    );
    expect(stockStatusOf(_product(stock: 5)), ProductStockStatus.stockBajo);
  });

  test('stockStatusOf clasifica disponible por encima del umbral', () {
    expect(
      stockStatusOf(_product(stock: AppConstants.lowStockThreshold + 1)),
      ProductStockStatus.disponible,
    );
  });

  test('expirationStatusOf clasifica caducado', () {
    final expired = DateTime.now().subtract(const Duration(days: 1));
    expect(
      expirationStatusOf(_product(expirationDate: expired)),
      ProductExpirationStatus.caducado,
    );
  });

  test('expirationStatusOf clasifica próximo a caducar dentro del umbral', () {
    final soon = DateTime.now().add(const Duration(days: 3));
    expect(
      expirationStatusOf(_product(expirationDate: soon)),
      ProductExpirationStatus.proximoACaducar,
    );
  });

  test('expirationStatusOf clasifica vigente fuera del umbral', () {
    final later = DateTime.now().add(const Duration(days: 30));
    expect(
      expirationStatusOf(_product(expirationDate: later)),
      ProductExpirationStatus.vigente,
    );
  });

  test('expirationStatusOf maneja productos sin fecha', () {
    expect(
      expirationStatusOf(_product(sinFecha: true)),
      ProductExpirationStatus.sinFecha,
    );
  });

  test('stockStatusLabel devuelve etiquetas legibles', () {
    expect(stockStatusLabel(ProductStockStatus.sinStock), 'Sin stock');
    expect(stockStatusLabel(ProductStockStatus.stockBajo), 'Stock bajo');
    expect(stockStatusLabel(ProductStockStatus.disponible), 'Disponible');
  });

  test('UserRole.label es el valor almacenado y esperado', () {
    expect(UserRole.jefe.label, 'Jefe');
    expect(UserRole.empleado.label, 'Empleado');
  });
}