/// Friendly domain/application errors shown to the user.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class PricingException extends AppException {
  const PricingException(super.message);
}
