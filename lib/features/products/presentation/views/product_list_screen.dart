import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setStockStatus(ProductStockStatus? status) {
    final current = ref.read(productFiltersProvider);
    ref.read(productFiltersProvider.notifier).state = ProductFilters(
      query: current.query,
      categoryId: current.categoryId,
      stockStatus: status,
    );
  }

  void _setCategory(String? categoryId) {
    final current = ref.read(productFiltersProvider);
    ref.read(productFiltersProvider.notifier).state = ProductFilters(
      query: current.query,
      categoryId: categoryId,
      stockStatus: current.stockStatus,
    );
  }

  void _setQuery(String value) {
    final current = ref.read(productFiltersProvider);
    final query = value.trim().isEmpty ? null : value;
    ref.read(productFiltersProvider.notifier).state = ProductFilters(
      query: query,
      categoryId: current.categoryId,
      stockStatus: current.stockStatus,
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(
      productsProvider(ref.read(productFiltersProvider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(productFiltersProvider);
    final productsAsync = ref.watch(productsProvider(filters));
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _setQuery,
              decoration: const InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _CategoryFilter(
                    value: filters.categoryId,
                    onChanged: _setCategory,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StockFilter(
                    value: filters.stockStatus,
                    onChanged: _setStockStatus,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: productsAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, _) => AppErrorWidget(
                  message: '$error',
                  onRetry: _refresh,
                ),
                data: (products) => products.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          EmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: 'Sin productos',
                            subtitle: 'Agrega tu primer producto.',
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            categoryName: _categoryName(
                              categoriesAsync,
                              product.categoryId,
                            ),
                            onTap: () => context.push(
                              RouteNames.productDetail.replaceFirst(
                                ':id',
                                product.id,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(RouteNames.productCreate);
          _refresh();
        },
        tooltip: 'Nuevo producto',
        child: const Icon(Icons.add),
      ),
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

class _CategoryFilter extends ConsumerWidget {
  const _CategoryFilter({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? [];
    return DropdownButtonFormField<String?>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Categoría',
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
        for (final c in categories)
          DropdownMenuItem<String?>(value: c.id, child: Text(c.name)),
      ],
      onChanged: onChanged,
    );
  }
}

class _StockFilter extends ConsumerWidget {
  const _StockFilter({required this.value, required this.onChanged});

  final ProductStockStatus? value;
  final ValueChanged<ProductStockStatus?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DropdownButtonFormField<ProductStockStatus?>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Stock',
        isDense: true,
      ),
      items: [
        const DropdownMenuItem<ProductStockStatus?>(
          value: null,
          child: Text('Todos'),
        ),
        const DropdownMenuItem<ProductStockStatus?>(
          value: ProductStockStatus.sinStock,
          child: Text('Sin stock'),
        ),
        const DropdownMenuItem<ProductStockStatus?>(
          value: ProductStockStatus.stockBajo,
          child: Text('Stock bajo'),
        ),
        const DropdownMenuItem<ProductStockStatus?>(
          value: ProductStockStatus.disponible,
          child: Text('Disponible'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}