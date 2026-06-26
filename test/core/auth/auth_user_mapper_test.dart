import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/auth/auth_user_mapper.dart';

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
  });
}
