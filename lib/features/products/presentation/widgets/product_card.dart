import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/product_model.dart';
import '../product_status_helper.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.categoryName,
    this.onTap,
    this.onEdit,
  });

  final ProductModel product;
  final String? categoryName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stockStatus = stockStatusOf(product);
    final expStatus = expirationStatusOf(product);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoryName != null)
              Text(
                categoryName!,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            if (product.expirationDate != null)
              Text(
                'Caduca: ${_formatDate(product.expirationDate!)} '
                '${_expirationSuffix(expStatus)}',
                style: TextStyle(
                  fontSize: 12,
                  color: expStatus == ProductExpirationStatus.caducado
                      ? scheme.error
                      : scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${product.currentStock}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: stockStatus == ProductStockStatus.sinStock
                    ? scheme.error
                    : scheme.primary,
              ),
            ),
            Text(
              stockStatusLabel(stockStatus),
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        isThreeLine: categoryName != null && product.expirationDate != null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toString().split(' ').first;
    return d;
  }

  String _expirationSuffix(ProductExpirationStatus status) {
    switch (status) {
      case ProductExpirationStatus.caducado:
        return '(caducado)';
      case ProductExpirationStatus.proximoACaducar:
        return '(próximo)';
      case ProductExpirationStatus.sinFecha:
      case ProductExpirationStatus.vigente:
        return '';
    }
  }
}