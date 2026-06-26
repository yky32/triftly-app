import 'package:flutter/services.dart';

/// Parses `KEY=value` lines from env files.
abstract final class LocalEnvReader {
  static Map<String, String> parse(String raw) {
    final values = <String, String>{};
    for (final line in raw.split('\n')) {
      final trimmed = line.split('#').first.trim();
      if (trimmed.isEmpty || !trimmed.contains('=')) continue;
      final key = trimmed.substring(0, trimmed.indexOf('=')).trim();
      var value = trimmed.substring(trimmed.indexOf('=') + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      if (value.isEmpty || value.contains('...') || value.contains('YOUR_PROJECT_REF')) {
        continue;
      }
      values[key] = value;
    }
    return values;
  }

  /// Loads [env/.env.local] from the asset bundle (present on dev machines only).
  static Future<Map<String, String>> loadFromAssets() async {
    try {
      final raw = await rootBundle.loadString('env/.env.local');
      return parse(raw);
    } catch (_) {
      return const {};
    }
  }
}
