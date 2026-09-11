import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/auth_failure.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/user_local_datasource.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSource(),
    userRemoteDataSource: UserRemoteDataSource(),
    userLocalDataSource: UserLocalDataSource(),
  );
});

final authStateProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._repository) : super(const AuthStateInitial()) {
    _authSubscription = _repository.authStateChanges.listen(
      (uid) => _onAuthChanged(uid),
      onError: (_) => state = const AuthStateUnauthenticated(),
    );
  }

  final AuthRepository _repository;
  late final StreamSubscription<String?> _authSubscription;

  Future<void> _onAuthChanged(String? uid) async {
    if (uid == null) {
      state = const AuthStateUnauthenticated();
      return;
    }
    try {
      final profile = await _repository.getProfile(uid);
      if (profile == null) {
        state = const AuthStateUnauthenticated();
      } else {
        state = AuthStateAuthenticated(profile);
      }
    } catch (_) {
      state = const AuthStateUnauthenticated();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthStateLoading();
    try {
      final user = await _repository.signIn(email: email, password: password);
      state = AuthStateAuthenticated(user);
    } on AuthFailure catch (e) {
      state = AuthStateError(e.message);
    } catch (_) {
      state = const AuthStateError(
        'Error al iniciar sesión. Verifica tu conexión.',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _repository.signOut();
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}