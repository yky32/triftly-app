/// OAuth redirect URL registered in Supabase Auth and native app URL handlers.
abstract final class AuthRedirect {
  static const url = 'triftly://login-callback';

  /// True when [uri] is the Google OAuth return URL (not an in-app page).
  static bool isOAuthCallback(Uri uri) =>
      uri.scheme == 'triftly' && uri.host == 'login-callback';
}
