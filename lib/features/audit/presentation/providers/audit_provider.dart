import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/audit_service.dart';
import '../../data/datasources/audit_local_datasource.dart';
import '../../data/datasources/audit_remote_datasource.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/repositories/audit_repository.dart';
import '../../data/repositories/audit_repository_impl.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepositoryImpl(
    local: AuditLocalDataSource(),
    remote: AuditRemoteDataSource(),
  );
});

final auditServiceProvider = Provider<AuditService>((ref) {
  return AuditService(ref.watch(auditRepositoryProvider), ref);
});

@immutable
class AuditFilters {
  const AuditFilters({
    this.userId,
    this.action,
    this.from,
    this.to,
  });

  final String? userId;
  final String? action;
  final DateTime? from;
  final DateTime? to;

  AuditFilters copyWith({
    String? userId,
    String? action,
    DateTime? from,
    DateTime? to,
  }) {
    return AuditFilters(
      userId: userId ?? this.userId,
      action: action ?? this.action,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

final auditFiltersProvider = StateProvider<AuditFilters>((ref) {
  return const AuditFilters();
});

final auditLogsProvider =
    FutureProvider.autoDispose.family<List<AuditLogModel>, AuditFilters>(
  (ref, filters) async {
    return ref.watch(auditRepositoryProvider).getLogs(
          userId: filters.userId,
          action: filters.action,
          from: filters.from,
          to: filters.to,
        );
  },
);

final auditLogProvider = FutureProvider.autoDispose.family<AuditLogModel?, String>(
  (ref, id) => ref.watch(auditRepositoryProvider).getById(id),
);