/// Centralized email validation for sign-in and forms.
abstract final class EmailValidator {
  /// Practical email pattern — local part, @, domain with TLD.
  static final RegExp _pattern = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$",
  );

  static bool isValid(String? value) {
    final email = value?.trim();
    if (email == null || email.isEmpty) return false;
    return _pattern.hasMatch(email);
  }

  /// Returns a user-facing error, or `null` when valid.
  static String? validate(String? value) {
    final email = value?.trim();
    if (email == null || email.isEmpty) {
      return 'Enter your email address';
    }
    if (!isValid(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
