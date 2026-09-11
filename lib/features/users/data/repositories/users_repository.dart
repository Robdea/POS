import '../../../auth/data/models/user_model.dart';

abstract class UsersRepository {
  Future<List<UserModel>> getUsers();

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String role,
  });

  Future<UserModel> changeRole(String id, String role);
}