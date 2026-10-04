/// User-facing domain/validation failures with Arabic messages.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}
