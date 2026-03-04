import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _keyThemeMode = 'theme_mode';
const String _valueLight = 'light';
const String _valueDark = 'dark';

/// Persists and restores user's theme choice (light or dark).
/// UI is designed for light mode first; default is light.
class ThemePreference {
  ThemePreference(this._prefs);

  final SharedPreferences _prefs;

  static const String keyThemeMode = _keyThemeMode;

  /// Default is [ThemeMode.light] (design focus is light mode first).
  ThemeMode get themeMode {
    final value = _prefs.getString(_keyThemeMode);
    return value == _valueDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = mode == ThemeMode.dark ? _valueDark : _valueLight;
    await _prefs.setString(_keyThemeMode, value);
  }
}
