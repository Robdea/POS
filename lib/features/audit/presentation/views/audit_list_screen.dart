import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/audit_provider.dart';
import '../widgets/audit_filter_bar.dart';
import '../widgets/audit_log_card.dart';

class AuditListScreen extends ConsumerWidget {
  const AuditListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(auditFiltersProvider);
    final logsAsync = ref.watch(auditLogsProvider(filters));

    return Scaffold(
      appBar: AppBar(title: const Text('Auditoría')),
      body: Column(
        children: [
          const AuditFilterBar(),
          const SizedBox(height: 8),
          Expanded(
            child: logsAsync.when(
              loading: () => const LoadingWidget(),
              error: (error, _) => AppErrorWidget(
                message: '$error',
                onRetry: () => ref.invalidate(auditLogsProvider(filters)),
              ),
              data: (logs) => logs.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Sin registros',
                      subtitle: 'No hay movimientos que coincidan.',
                    )
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(auditLogsProvider(filters)),
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          return AuditLogCard(
                            log: log,
                            onTap: () => context.push(
                              RouteNames.auditDetail.replaceFirst(':id', log.id),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}