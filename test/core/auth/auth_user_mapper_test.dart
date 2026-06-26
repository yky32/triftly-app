import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/auth/auth_user_mapper.dart';
import 'package:triftly/core/models/user.dart';

void main() {
  group('AuthUserMapper', () {
    test('displayNameFromMetadata prefers Google full_name', () {
      expect(
        AuthUserMapper.displayNameFromMetadata(
          {'full_name': 'Wayne Yu', 'name': 'Wayne'},
          'wayne@example.com',
        ),
        'Wayne Yu',
      );
    });

    test('displayNameFromMetadata falls back to email local part', () {
      expect(
        AuthUserMapper.displayNameFromMetadata({}, 'yky32is@gmail.com'),
        'yky32is',
      );
    });

    test('avatarUrlFromMetadata reads picture and avatar_url', () {
      expect(
        AuthUserMapper.avatarUrlFromMetadata({
          'picture': 'https://example.com/a.jpg',
        }),
        'https://example.com/a.jpg',
      );
      expect(
        AuthUserMapper.avatarUrlFromMetadata({
          'avatar_url': 'https://example.com/b.jpg',
        }),
        'https://example.com/b.jpg',
      );
    });

    test('User.signedInWithGoogle reflects signInProvider', () {
      final googleUser = User(
        id: 'id',
        displayName: 'Wayne',
        signInProvider: 'google',
        updatedAt: DateTime(2026, 1, 1),
      );
      final emailUser = User(
        id: 'id',
        displayName: 'Wayne',
        signInProvider: 'email',
        updatedAt: DateTime(2026, 1, 1),
      );
      expect(googleUser.signedInWithGoogle, isTrue);
      expect(emailUser.signedInWithGoogle, isFalse);
    });
  });
}
