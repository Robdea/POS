import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/viewmodels/auth_state.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../providers/users_provider.dart';
import '../widgets/user_card.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);
    final authState = ref.watch(authStateProvider);
    final currentUserId =
        authState is AuthStateAuthenticated ? authState.user.id : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: usersAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => AppErrorWidget(
          message: '$error',
          onRetry: () => ref.invalidate(usersProvider),
        ),
        data: (users) => users.isEmpty
            ? const EmptyState(
                icon: Icons.group_outlined,
                title: 'Sin usuarios',
                subtitle: 'Invita a un usuario con su email.',
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(usersProvider),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserCard(
                      user: user,
                      isCurrentUser: user.id == currentUserId,
                      onTap: () async {
                        final saved = await context.push(
                          RouteNames.userEdit.replaceFirst(':id', user.id),
                        );
                        if (saved == true) ref.invalidate(usersProvider);
                      },
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await context.push(RouteNames.userCreate);
          if (saved == true) ref.invalidate(usersProvider);
        },
        tooltip: 'Nuevo usuario',
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }
}