import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../audit/presentation/providers/audit_provider.dart';
import '../../../auth/data/datasources/user_local_datasource.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/datasources/users_remote_datasource.dart';
import '../../data/repositories/users_repository.dart';
import '../../data/repositories/users_repository_impl.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl(
    local: UserLocalDataSource(),
    remote: UsersRemoteDataSource(),
    audit: ref.watch(auditServiceProvider),
  );
});

final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.watch(usersRepositoryProvider).getUsers();
});