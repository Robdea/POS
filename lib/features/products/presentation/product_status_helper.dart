import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../data/models/product_model.dart';

ProductStockStatus stockStatusOf(ProductModel product) {
  if (product.currentStock == 0) return ProductStockStatus.sinStock;
  if (product.currentStock <= AppConstants.lowStockThreshold) {
    return ProductStockStatus.stockBajo;
  }
  return ProductStockStatus.disponible;
}

ProductExpirationStatus expirationStatusOf(ProductModel product) {
  final exp = product.expirationDate;
  if (exp == null) return ProductExpirationStatus.sinFecha;
  final now = DateTime.now();
  if (exp.isBefore(now)) return ProductExpirationStatus.caducado;
  final threshold = now.add(
    Duration(days: AppConstants.nearExpirationDays),
  );
  if (exp.isBefore(threshold)) return ProductExpirationStatus.proximoACaducar;
  return ProductExpirationStatus.vigente;
}

String stockStatusLabel(ProductStockStatus status) {
  switch (status) {
    case ProductStockStatus.sinStock:
      return 'Sin stock';
    case ProductStockStatus.stockBajo:
      return 'Stock bajo';
    case ProductStockStatus.disponible:
      return 'Disponible';
  }
}

Color? stockStatusColor(
  ProductStockStatus status,
  ColorScheme scheme,
) {
  switch (status) {
    case ProductStockStatus.sinStock:
      return scheme.error;
    case ProductStockStatus.stockBajo:
      return null;
    case ProductStockStatus.disponible:
      return null;
  }
}