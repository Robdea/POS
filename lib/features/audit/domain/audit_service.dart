import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/id_generator.dart';
import '../../auth/presentation/viewmodels/auth_state.dart';
import '../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../data/models/audit_log_model.dart';
import '../data/repositories/audit_repository.dart';

class AuditService {
  AuditService(this._repository, this._ref);

  final AuditRepository _repository;
  final Ref _ref;

  Future<void> record({
    required AuditAction action,
    required String entityType,
    required String entityId,
    required String description,
  }) async {
    final authState = _ref.read(authStateProvider);
    final user = authState is AuthStateAuthenticated ? authState.user : null;

    final log = AuditLogModel(
      id: IdGenerator.generate(),
      userId: user?.id ?? 'system',
      userName: user?.name ?? 'Sistema',
      action: action.value,
      entityType: entityType,
      entityId: entityId,
      description: description,
      createdAt: DateTime.now(),
    );
    await _repository.add(log);
  }
}