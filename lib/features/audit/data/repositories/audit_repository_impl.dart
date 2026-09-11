import '../../../../core/utils/connectivity_helper.dart';
import '../datasources/audit_local_datasource.dart';
import '../datasources/audit_remote_datasource.dart';
import '../models/audit_log_model.dart';
import 'audit_repository.dart';

class AuditRepositoryImpl implements AuditRepository {
  AuditRepositoryImpl({
    required AuditLocalDataSource local,
    required AuditRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final AuditLocalDataSource _local;
  final AuditRemoteDataSource _remote;

  @override
  Future<void> add(AuditLogModel log) async {
    await _local.insert(log);
    if (!await ConnectivityHelper.hasConnection()) return;
    try {
      await _remote.upsert(log);
      await _local.markSynced(log.id);
    } catch (_) {}
  }

  @override
  Future<AuditLogModel?> getById(String id) => _local.getById(id);

  @override
  Future<List<AuditLogModel>> getLogs({
    String? userId,
    String? action,
    DateTime? from,
    DateTime? to,
  }) async {
    await _pullFromRemote();
    return _local.getLogs(
      userId: userId,
      action: action,
      from: from,
      to: to,
    );
  }

  @override
  Future<List<AuditLogModel>> getPendingSync() => _local.getPendingSync();

  @override
  Future<void> markSynced(String id) => _local.markSynced(id);

  Future<void> _pullFromRemote() async {
    if (!await ConnectivityHelper.hasConnection()) return;
    try {
      final remote = await _remote.getAll();
      for (final log in remote) {
        final local = await _local.getById(log.id);
        if (local == null) {
          await _local.insert(log);
        }
      }
    } catch (_) {}
  }
}