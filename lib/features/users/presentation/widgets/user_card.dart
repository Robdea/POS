import 'package:flutter/material.dart';
import '../../../../core/theme/app_shapes.dart';
import '../../../auth/data/models/user_model.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.isCurrentUser,
    this.onTap,
  });

  final UserModel user;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isJefe = user.role == 'Jefe';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Text(
            user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 6),
              Text(
                '(tú)',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isJefe
                ? scheme.primaryContainer
                : scheme.surfaceContainerHighest,
            borderRadius: AppShapes.borderRadius,
          ),
          child: Text(
            user.role,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isJefe ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}