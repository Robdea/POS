import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/auth/presentation/views/splash_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/viewmodels/auth_state.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../core/constants/app_constants.dart';
import '../../features/dashboard/presentation/views/dashboard_screen.dart';
import '../../features/products/presentation/views/product_list_screen.dart';
import '../../features/products/presentation/views/product_form_screen.dart';
import '../../features/products/presentation/views/product_detail_screen.dart';
import '../../features/categories/presentation/views/category_list_screen.dart';
import '../../features/categories/presentation/views/category_form_screen.dart';
import '../../features/users/presentation/views/user_list_screen.dart';
import '../../features/users/presentation/views/user_form_screen.dart';
import '../../features/audit/presentation/views/audit_list_screen.dart';
import '../../features/audit/presentation/views/audit_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isSplash = location == RouteNames.splash;
      final isLogin = location == RouteNames.login;

      if (authState is AuthStateAuthenticated) {
        if (isSplash || isLogin) return RouteNames.dashboard;
        final isJefe = authState.user.role == UserRole.jefe.label;
        final inAdminSection =
            location.startsWith(RouteNames.users) ||
            location.startsWith(RouteNames.audit);
        if (!isJefe && inAdminSection) return RouteNames.dashboard;
        return null;
      }
      if (authState is AuthStateUnauthenticated || authState is AuthStateError) {
        if (isSplash || !isLogin) return RouteNames.login;
        return null;
      }
      if (isSplash) return null;
      return RouteNames.splash;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.products,
            builder: (context, state) => const ProductListScreen(),
          ),
          GoRoute(
            path: RouteNames.productCreate,
            builder: (context, state) => const ProductFormScreen(),
          ),
          GoRoute(
            path: RouteNames.productDetail,
            builder: (context, state) => ProductDetailScreen(
              productId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: RouteNames.productEdit,
            builder: (context, state) => ProductFormScreen(
              productId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: RouteNames.categories,
            builder: (context, state) => const CategoryListScreen(),
          ),
          GoRoute(
            path: RouteNames.categoryCreate,
            builder: (context, state) => const CategoryFormScreen(),
          ),
          GoRoute(
            path: RouteNames.categoryEdit,
            builder: (context, state) => CategoryFormScreen(
              categoryId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: RouteNames.users,
            builder: (context, state) => const UserListScreen(),
          ),
          GoRoute(
            path: RouteNames.userCreate,
            builder: (context, state) => const UserFormScreen(),
          ),
          GoRoute(
            path: RouteNames.userEdit,
            builder: (context, state) => UserFormScreen(
              userId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: RouteNames.audit,
            builder: (context, state) => const AuditListScreen(),
          ),
          GoRoute(
            path: RouteNames.auditDetail,
            builder: (context, state) => AuditDetailScreen(
              logId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
    ],
  );
});

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isJefe = authState is AuthStateAuthenticated &&
        authState.user.role == UserRole.jefe.label;

    final tabs = <_ShellTab>[
      _ShellTab(
        path: RouteNames.dashboard,
        label: 'Inicio',
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
      ),
      _ShellTab(
        path: RouteNames.products,
        label: 'Productos',
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2,
      ),
      _ShellTab(
        path: RouteNames.categories,
        label: 'Categorías',
        icon: Icons.category_outlined,
        selectedIcon: Icons.category,
      ),
      if (isJefe)
        _ShellTab(
          path: RouteNames.users,
          label: 'Usuarios',
          icon: Icons.group_outlined,
          selectedIcon: Icons.group,
        ),
      _ShellTab(
        path: RouteNames.audit,
        label: 'Auditoría',
        icon: Icons.history_outlined,
        selectedIcon: Icons.history,
      ),
    ];

    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _calculateSelectedIndex(location, tabs);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex >= 0 && selectedIndex < tabs.length
            ? selectedIndex
            : 0,
        onDestinationSelected: (index) {
          if (index >= 0 && index < tabs.length) {
            context.go(tabs[index].path);
          }
        },
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(String location, List<_ShellTab> tabs) {
    for (var i = 0; i < tabs.length; i++) {
      if (location.startsWith(tabs[i].path) || location == '/') {
        return i;
      }
    }
    return 0;
  }
}

class _ShellTab {
  const _ShellTab({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}