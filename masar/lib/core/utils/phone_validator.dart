abstract final class PhoneValidator {
  /// Accepts common Iraqi mobile formats and generic digits.
  static bool isValid(String? phone) {
    if (phone == null) return false;
    final cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (cleaned.isEmpty) return false;
    return RegExp(r'^(\+?964|0)?7\d{8,9}$').hasMatch(cleaned) ||
        RegExp(r'^\d{7,15}$').hasMatch(cleaned);
  }

  static String normalize(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-]'), '').trim();
  }
}
