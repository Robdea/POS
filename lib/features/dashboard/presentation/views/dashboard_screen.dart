import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/viewmodels/auth_state.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final authState = ref.watch(authStateProvider);
    final scheme = Theme.of(context).colorScheme;
    final userName = authState is AuthStateAuthenticated
        ? authState.user.name.split(' ').first
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(userName == null ? 'Inicio' : 'Hola, $userName'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => AppErrorWidget(
          message: '$error',
          onRetry: () => ref.invalidate(dashboardStatsProvider),
        ),
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardStatsProvider),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.1,
                children: [
                  StatCard(
                    label: 'Productos registrados',
                    value: '${stats.totalProducts}',
                    icon: Icons.inventory_2_outlined,
                    onTap: _goToProducts(context, ref),
                  ),
                  StatCard(
                    label: 'Unidades en stock',
                    value: '${stats.totalStockUnits}',
                    icon: Icons.warehouse_outlined,
                    onTap: _goToProducts(context, ref),
                  ),
                  StatCard(
                    label: 'Stock bajo',
                    value: '${stats.lowStockCount}',
                    icon: Icons.trending_down,
                    valueColor: scheme.warning,
                    onTap: _goToStockFilter(context, ref,
                        ProductStockStatus.stockBajo),
                  ),
                  StatCard(
                    label: 'Sin stock',
                    value: '${stats.sinStockCount}',
                    icon: Icons.remove_circle_outline,
                    valueColor: scheme.error,
                    onTap: _goToStockFilter(context, ref,
                        ProductStockStatus.sinStock),
                  ),
                  StatCard(
                    label: 'Próximos a caducar',
                    value: '${stats.nearExpirationCount}',
                    icon: Icons.schedule,
                    valueColor: scheme.warning,
                    onTap: _goToProducts(context, ref),
                  ),
                  StatCard(
                    label: 'Caducados',
                    value: '${stats.expiredCount}',
                    icon: Icons.event_busy,
                    valueColor: scheme.error,
                    onTap: _goToProducts(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StatCard(
                label: 'Categorías',
                value: '${stats.totalCategories}',
                icon: Icons.category_outlined,
                onTap: () => context.go(RouteNames.categories),
              ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback _goToProducts(BuildContext context, WidgetRef ref) {
    return () => context.go(RouteNames.products);
  }

  VoidCallback _goToStockFilter(
    BuildContext context,
    WidgetRef ref,
    ProductStockStatus status,
  ) {
    return () {
      ref.read(productFiltersProvider.notifier).state =
          ref.read(productFiltersProvider).copyWith(stockStatus: status);
      context.go(RouteNames.products);
    };
  }
}