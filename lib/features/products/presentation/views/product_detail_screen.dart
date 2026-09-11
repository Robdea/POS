import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../../auth/presentation/viewmodels/auth_state.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/models/product_model.dart';
import '../product_status_helper.dart';
import '../providers/products_provider.dart';
import '../widgets/stock_update_dialog.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(productId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final authState = ref.watch(authStateProvider);
    final isJefe = authState is AuthStateAuthenticated &&
        authState.user.role == UserRole.jefe.label;

    return productAsync.when(
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (error, _) => Scaffold(
        body: AppErrorWidget(
          message: '$error',
          onRetry: () => ref.invalidate(productProvider(productId)),
        ),
      ),
      data: (product) {
        if (product == null) {
          return const Scaffold(
            body: EmptyState(
              icon: Icons.search_off,
              title: 'Producto no encontrado',
            ),
          );
        }
        return _DetailView(
          product: product,
          categoryName: _categoryName(categoriesAsync, product.categoryId),
          isJefe: isJefe,
          refresh: () => ref.invalidate(
            productsProvider(ref.read(productFiltersProvider)),
          ),
        );
      },
    );
  }

  String? _categoryName(
    AsyncValue<List<CategoryModel>> categoriesAsync,
    String categoryId,
  ) {
    final categories = categoriesAsync.valueOrNull;
    if (categories == null) return null;
    final match = categories.where((c) => c.id == categoryId).toList();
    return match.isEmpty ? null : match.first.name;
  }
}

class _DetailView extends ConsumerWidget {
  const _DetailView({
    required this.product,
    required this.categoryName,
    required this.isJefe,
    required this.refresh,
  });

  final ProductModel product;
  final String? categoryName;
  final bool isJefe;
  final VoidCallback refresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final stockStatus = stockStatusOf(product);
    final expStatus = expirationStatusOf(product);

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              label: 'Categoría',
              value: categoryName ?? 'Sin categoría',
            ),
            if (product.description != null) ...[
              const SizedBox(height: 8),
              _InfoRow(label: 'Descripción', value: product.description!),
            ],
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Stock actual',
              value: '${product.currentStock} '
                  '- ${stockStatusLabel(stockStatus)}',
              valueColor: stockStatus == ProductStockStatus.sinStock
                  ? scheme.error
                  : null,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Fecha de ingreso',
              value: DateHelpers.formatDate(product.entryDate),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Caducidad',
              value: product.expirationDate == null
                  ? 'Sin fecha'
                  : '${DateHelpers.formatDate(product.expirationDate!)} '
                      '${_expirationSuffix(expStatus)}',
              valueColor: expStatus == ProductExpirationStatus.caducado
                  ? scheme.error
                  : null,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Costo de adquisición',
              value: _formatCost(product.purchaseCost),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => StockUpdateDialog(
                  product: product,
                  onSubmit: (newStock) async {
                    await ref
                        .read(productsRepositoryProvider)
                        .updateStock(product.id, newStock);
                    refresh();
                  },
                ),
              ),
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('Actualizar stock'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final saved = await context.push(
                  RouteNames.productEdit.replaceFirst(':id', product.id),
                );
                if (saved == true) refresh();
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar producto'),
            ),
            if (isJefe) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar producto'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Eliminar producto',
      message: '¿Eliminar "${product.name}" de forma permanente?',
      confirmLabel: 'Eliminar',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(productsRepositoryProvider).delete(product.id);
      if (context.mounted) context.go(RouteNames.products);
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  String _formatCost(double value) =>
      '\$${value.toStringAsFixed(2)}';

  String _expirationSuffix(ProductExpirationStatus status) {
    switch (status) {
      case ProductExpirationStatus.caducado:
        return '(caducado)';
      case ProductExpirationStatus.proximoACaducar:
        return '(próximo a caducar)';
      case ProductExpirationStatus.sinFecha:
      case ProductExpirationStatus.vigente:
        return '';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
          ),
        ),
      ],
    );
  }
}