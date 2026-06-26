import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/validation/email_validator.dart';

void main() {
  group('EmailValidator', () {
    test('accepts standard emails', () {
      expect(EmailValidator.isValid('user@example.com'), isTrue);
      expect(EmailValidator.isValid('wayne.yu+trip@yky.dev'), isTrue);
      expect(EmailValidator.validate('user@example.com'), isNull);
    });

    test('rejects invalid formats', () {
      expect(EmailValidator.isValid('not-an-email'), isFalse);
      expect(EmailValidator.isValid('missing@domain'), isFalse);
      expect(EmailValidator.isValid('@example.com'), isFalse);
      expect(EmailValidator.isValid('user@'), isFalse);
      expect(EmailValidator.validate('bad'), isNotNull);
    });

    test('rejects empty input', () {
      expect(EmailValidator.isValid(''), isFalse);
      expect(EmailValidator.isValid('   '), isFalse);
      expect(EmailValidator.validate(''), 'Enter your email address');
    });
  });
}
