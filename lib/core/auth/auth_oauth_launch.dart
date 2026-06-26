import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

/// How to open the Google OAuth page.
///
/// [LaunchMode.inAppWebView] cannot complete custom-scheme redirects (`triftly://`)
/// on iOS — the sheet closes with no session. External Safari hands off to the app
/// via the deep link, which Supabase handles through `app_links`.
LaunchMode googleOAuthLaunchMode() {
  if (kIsWeb) return LaunchMode.platformDefault;
  if (Platform.isIOS || Platform.isAndroid) {
    return LaunchMode.externalApplication;
  }
  return LaunchMode.platformDefault;
}
