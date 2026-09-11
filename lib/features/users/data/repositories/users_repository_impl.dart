import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exceptions.dart';
import '../../../../core/utils/connectivity_helper.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../audit/domain/audit_service.dart';
import '../../../auth/data/datasources/user_local_datasource.dart';
import '../../../auth/data/models/user_model.dart';
import '../datasources/users_remote_datasource.dart';
import 'users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  UsersRepositoryImpl({
    required UserLocalDataSource local,
    required UsersRemoteDataSource remote,
    required AuditService audit,
  })  : _local = local,
        _remote = remote,
        _audit = audit;

  final UserLocalDataSource _local;
  final UsersRemoteDataSource _remote;
  final AuditService _audit;

  @override
  Future<List<UserModel>> getUsers() async {
    await _pullFromRemote();
    return _local.getUsers();
  }

  @override
  Future<UserModel> createUser({
    required String name,
    required String email,
    required String role,
  }) async {
    final validRole = UserRole.values.map((r) => r.label).contains(role);
    if (!validRole) {
      throw const AppException('El rol debe ser Empleado o Jefe.');
    }
    final now = DateTime.now();
    final user = UserModel(
      id: IdGenerator.generate(),
      name: name,
      email: email.trim(),
      role: role,
      createdAt: now,
      updatedAt: now,
      pendingSync: true,
    );
    await _local.insert(user);
    await _audit.record(
      action: AuditAction.createUser,
      entityType: 'user',
      entityId: user.id,
      description: 'Usuario creado: ${user.name} (${user.role})',
    );
    await _push(user);
    return user;
  }

  @override
  Future<UserModel> changeRole(String id, String role) async {
    final validRole = UserRole.values.map((r) => r.label).contains(role);
    if (!validRole) {
      throw const AppException('El rol debe ser Empleado o Jefe.');
    }
    final existing = await _local.getUser(id);
    if (existing == null) {
      throw const AppException('El usuario no existe localmente.');
    }
    final updatedAt = DateTime.now();
    await _local.updateRole(id, role, updatedAt);
    await _audit.record(
      action: AuditAction.changeUserRole,
      entityType: 'user',
      entityId: id,
      description:
          'Rol de ${existing.name} cambiado de ${existing.role} a $role',
    );
    final updated = existing.copyWith(role: role, updatedAt: updatedAt);
    await _push(updated);
    return updated;
  }

  Future<void> _push(UserModel user) async {
    if (!await ConnectivityHelper.hasConnection()) return;
    try {
      await _remote.upsert(user);
      await _local.markSynced(user.id);
    } catch (_) {}
  }

  Future<void> _pullFromRemote() async {
    if (!await ConnectivityHelper.hasConnection()) return;
    try {
      final remote = await _remote.getAll();
      for (final user in remote) {
        final local = await _local.getUser(user.id);
        if (local == null || !local.pendingSync) {
          await _local.insert(user);
        }
      }
    } catch (_) {}
  }
}