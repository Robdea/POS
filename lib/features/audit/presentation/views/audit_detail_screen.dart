import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../audit_action_label.dart';
import '../providers/audit_provider.dart';

class AuditDetailScreen extends ConsumerWidget {
  const AuditDetailScreen({super.key, required this.logId});

  final String logId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logAsync = ref.watch(auditLogProvider(logId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de auditoría')),
      body: logAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => AppErrorWidget(
          message: '$error',
          onRetry: () => ref.invalidate(auditLogProvider(logId)),
        ),
        data: (log) {
          if (log == null) {
            return const EmptyState(
              icon: Icons.search_off,
              title: 'Registro no encontrado',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DetailTile(label: 'Acción', value: auditActionLabel(log.action)),
              _DetailTile(label: 'Tipo de entidad', value: log.entityType),
              _DetailTile(label: 'ID de entidad', value: log.entityId),
              _DetailTile(label: 'Usuario', value: '${log.userName} (${log.userId})'),
              _DetailTile(label: 'Fecha', value: DateHelpers.formatFull(log.createdAt)),
              const Divider(height: 24),
              Text(
                'Descripción',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(log.description, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          );
        },
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}