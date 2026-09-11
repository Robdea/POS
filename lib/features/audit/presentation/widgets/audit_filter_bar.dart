import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_helpers.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../providers/audit_provider.dart';

class AuditFilterBar extends ConsumerWidget {
  const AuditFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(auditFiltersProvider);
    final usersAsync = ref.watch(usersProvider);
    final users = usersAsync.valueOrNull ?? [];
    final hasFilters = filters.action != null ||
        filters.userId != null ||
        filters.from != null ||
        filters.to != null;

    void setFilters(AuditFilters next) {
      ref.read(auditFiltersProvider.notifier).state = next;
    }

    Future<void> pickFrom() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: filters.from ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked == null) return;
      setFilters(filters.copyWith(from: picked));
    }

    Future<void> pickTo() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: filters.to ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked == null) return;
      setFilters(filters.copyWith(to: picked));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 170),
                child: DropdownButtonFormField<String?>(
                  initialValue: filters.action,
                  decoration: const InputDecoration(
                    labelText: 'Acción',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todas'),
                    ),
                    for (final action in AuditAction.values)
                      DropdownMenuItem<String?>(
                        value: action.value,
                        child: Text(action.name),
                      ),
                  ],
                  onChanged: (value) => setFilters(
                    AuditFilters(
                      action: value,
                      userId: filters.userId,
                      from: filters.from,
                      to: filters.to,
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 170),
                child: DropdownButtonFormField<String?>(
                  initialValue: filters.userId,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Todos'),
                    ),
                    for (final user in users)
                      DropdownMenuItem<String?>(
                        value: user.id,
                        child: Text(user.name),
                      ),
                  ],
                  onChanged: (value) => setFilters(
                    AuditFilters(
                      action: filters.action,
                      userId: value,
                      from: filters.from,
                      to: filters.to,
                    ),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: pickFrom,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  filters.from == null
                      ? 'Desde'
                      : DateHelpers.formatDate(filters.from!),
                ),
              ),
              OutlinedButton.icon(
                onPressed: pickTo,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  filters.to == null
                      ? 'Hasta'
                      : DateHelpers.formatDate(filters.to!),
                ),
              ),
            ],
          ),
          if (hasFilters)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => setFilters(const AuditFilters()),
                icon: const Icon(Icons.filter_alt_off, size: 18),
                label: const Text('Limpiar filtros'),
              ),
            ),
        ],
      ),
    );
  }
}