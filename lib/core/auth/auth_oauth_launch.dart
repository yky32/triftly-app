import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// How to open the Google OAuth page on Android / desktop.
///
/// iOS uses [AuthOAuthSession] (`ASWebAuthenticationSession`) instead — it stays
/// in-app, auto-returns on `triftly://login-callback`, and does not leave Safari open.
LaunchMode googleOAuthLaunchMode() {
  if (kIsWeb) return LaunchMode.platformDefault;
  if (Platform.isAndroid) {
    return LaunchMode.externalApplication;
  }
  return LaunchMode.platformDefault;
}
