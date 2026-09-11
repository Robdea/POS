class AuthFailure {
  const AuthFailure(this.code, this.message);

  final String code;
  final String message;

  factory AuthFailure.fromFirebaseCode(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
        return AuthFailure(code, 'Credenciales incorrectas.');
      case 'user-not-found':
        return AuthFailure(code, 'No existe una cuenta con este correo.');
      case 'user-disabled':
        return AuthFailure(code, 'La cuenta está deshabilitada.');
      case 'too-many-requests':
        return AuthFailure(code, 'Demasiados intentos. Intenta más tarde.');
      case 'network-request-failed':
        return AuthFailure(code, 'Sin conexión a Internet.');
      default:
        return AuthFailure(code, 'Error al iniciar sesión.');
    }
  }
}