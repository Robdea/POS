import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/auth_failure.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required UserRemoteDataSource userRemoteDataSource,
    required UserLocalDataSource userLocalDataSource,
  })  : _remote = remoteDataSource,
        _userRemote = userRemoteDataSource,
        _userLocal = userLocalDataSource;

  final AuthRemoteDataSource _remote;
  final UserRemoteDataSource _userRemote;
  final UserLocalDataSource _userLocal;

  @override
  Stream<String?> get authStateChanges => _remote.authStateChanges;

  @override
  Future<UserModel?> getProfile(String uid) async {
    final local = await _userLocal.getUser(uid);
    if (local != null && !local.pendingSync) return local;

    try {
      final remote = await _userRemote.getUser(uid);
      if (remote != null) {
        await _userLocal.insert(remote);
        return remote;
      }
    } catch (_) {}

    return local;
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final String uid;
    try {
      uid = await _remote.signIn(email, password);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure.fromFirebaseCode(e.code);
    }

    var profile = await _userRemote.getUser(uid);

    if (profile == null) {
      final now = DateTime.now();
      profile = UserModel(
        id: uid,
        name: email.split('@').first,
        email: email.trim(),
        role: UserRole.empleado.label,
        createdAt: now,
        updatedAt: now,
      );
      try {
        await _userRemote.upsert(profile);
      } catch (_) {}
    }

    await _userLocal.insert(profile);
    return profile;
  }

  @override
  Future<void> signOut() => _remote.signOut();
}