import '../models/audit_log_model.dart';

abstract class AuditRepository {
  Future<void> add(AuditLogModel log);

  Future<AuditLogModel?> getById(String id);

  Future<List<AuditLogModel>> getLogs({
    String? userId,
    String? action,
    DateTime? from,
    DateTime? to,
  });

  Future<List<AuditLogModel>> getPendingSync();

  Future<void> markSynced(String id);
}