import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/viewmodels/auth_state.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../providers/categories_provider.dart';
import '../widgets/category_card.dart';

class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final authState = ref.watch(authStateProvider);
    final isJefe = authState is AuthStateAuthenticated &&
        authState.user.role == UserRole.jefe.label;

    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: categoriesAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => AppErrorWidget(
          message: '$error',
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) => categories.isEmpty
            ? const EmptyState(
                icon: Icons.category_outlined,
                title: 'Sin categorías',
                subtitle: 'Crea categorías para organizar tus productos.',
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(categoriesProvider),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryCard(
                      category: category,
                      onEdit: () async {
                        final saved = await context.push(
                          RouteNames.categoryEdit.replaceFirst(':id', category.id),
                        );
                        if (saved == true) ref.invalidate(categoriesProvider);
                      },
                      onDelete: isJefe
                          ? () => _delete(context, ref, category)
                          : null,
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await context.push(RouteNames.categoryCreate);
          if (saved == true) ref.invalidate(categoriesProvider);
        },
        tooltip: 'Nueva categoría',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    dynamic category,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Eliminar categoría',
      message:
          '¿Eliminar "${category.name}"? No se podrá eliminar si tiene productos.',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(categoriesRepositoryProvider).delete(category.id);
      ref.invalidate(categoriesProvider);
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}