class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class OfflineOperationException extends AppException {
  const OfflineOperationException(super.message);
}