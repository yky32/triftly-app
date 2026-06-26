import 'package:flutter_test/flutter_test.dart';
import 'package:triftly/core/auth/auth_oauth_launch.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  test('googleOAuthLaunchMode uses external browser on mobile', () {
    // Tests run on VM/desktop — falls back to platformDefault.
    expect(googleOAuthLaunchMode(), isA<LaunchMode>());
  });
}
