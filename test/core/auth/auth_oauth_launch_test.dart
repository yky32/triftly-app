import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/auth/auth_oauth_launch.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  test('googleOAuthLaunchMode returns a LaunchMode on desktop', () {
    // VM/desktop — not Android; iOS uses AuthOAuthSession instead of url_launcher.
    expect(googleOAuthLaunchMode(), isA<LaunchMode>());
  });
}
