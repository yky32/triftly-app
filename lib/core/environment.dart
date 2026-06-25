class Environment {
  static const String _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  static bool get isDev => _env == 'dev';
  static bool get isProd => _env == 'prod';
  static bool get isStag => _env == 'stag';

  static String get envName => _env;

  // Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  /// New opaque publishable key (`sb_publishable_…`). Preferred over legacy anon JWT.
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Legacy anon JWT — still accepted when publishable key is unset.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  static String get supabaseClientKey {
    if (supabasePublishableKey.isNotEmpty) return supabasePublishableKey;
    return supabaseAnonKey;
  }

  static bool get hasSupabase {
    final urlOk =
        supabaseUrl.isNotEmpty && !supabaseUrl.contains('your-project');
    final key = supabaseClientKey;
    final keyOk = key.isNotEmpty &&
        key != 'your-anon-key' &&
        !key.startsWith('sb_publishable_...') &&
        (key.startsWith('sb_publishable_') || key.startsWith('eyJ'));
    return urlOk && keyOk;
  }

  // Google Maps
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
