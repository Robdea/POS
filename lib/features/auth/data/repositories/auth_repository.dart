import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<String?> get authStateChanges;

  Future<UserModel?> getProfile(String uid);

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}