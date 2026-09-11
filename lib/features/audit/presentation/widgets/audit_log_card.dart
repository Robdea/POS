import 'package:flutter/material.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../data/models/audit_log_model.dart';
import '../audit_action_label.dart';

class AuditLogCard extends StatelessWidget {
  const AuditLogCard({
    super.key,
    required this.log,
    this.onTap,
  });

  final AuditLogModel log;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(
            Icons.receipt_long_outlined,
            size: 20,
            color: scheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          auditActionLabel(log.action),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${log.userName} · ${log.entityType}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              DateHelpers.formatFull(log.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        isThreeLine: false,
      ),
    );
  }
}