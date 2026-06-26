import 'local_env_reader.dart';

/// Single Supabase project for local dev and TestFlight (no separate staging).
class Environment {
  static Map<String, String> _local = const {};

  /// Loads [env/.env.local] when compile-time defines are not set (local dev).
  static Future<void> load() async {
    _local = await LocalEnvReader.loadFromAssets();
  }

  static const String _compileEnv = String.fromEnvironment('ENV', defaultValue: '');

  static String get envName {
    if (_compileEnv.isNotEmpty) return _compileEnv;
    return _local['ENV'] ?? _local['APP_ENV'] ?? 'prod';
  }

  // Supabase
  static const String _compileSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String _compileSupabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String _compileSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static String get supabaseUrl {
    final compiled = _compileSupabaseUrl.trim();
    if (_isUsableSupabaseUrl(compiled)) return compiled;
    return (_local['SUPABASE_URL'] ?? '').trim();
  }

  static String get supabasePublishableKey {
    final compiled = _compileSupabasePublishableKey.trim();
    if (compiled.isNotEmpty) return compiled;
    return (_local['SUPABASE_PUBLISHABLE_KEY'] ?? '').trim();
  }

  static String get supabaseAnonKey {
    final compiled = _compileSupabaseAnonKey.trim();
    if (compiled.isNotEmpty && compiled != 'your-anon-key') return compiled;
    return (_local['SUPABASE_ANON_KEY'] ?? '').trim();
  }

  static String get supabaseClientKey {
    if (supabasePublishableKey.isNotEmpty) return supabasePublishableKey;
    return supabaseAnonKey;
  }

  static bool get hasSupabase {
    final urlOk = _isUsableSupabaseUrl(supabaseUrl);
    final key = supabaseClientKey;
    final keyOk = key.isNotEmpty &&
        key != 'your-anon-key' &&
        !key.startsWith('sb_publishable_...') &&
        (key.startsWith('sb_publishable_') || key.startsWith('eyJ'));
    return urlOk && keyOk;
  }

  // Google Maps
  static const String _compileGoogleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static String get googleMapsApiKey {
    final compiled = _compileGoogleMapsApiKey.trim();
    if (compiled.isNotEmpty) return compiled;
    return (_local['GOOGLE_MAPS_API_KEY'] ?? '').trim();
  }

  static bool _isUsableSupabaseUrl(String url) =>
      url.isNotEmpty && !url.contains('your-project');
}
