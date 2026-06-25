import 'package:shared_preferences/shared_preferences.dart';

/// Local prefs for guest identity and Me-page settings.
class ProfilePreferences {
  ProfilePreferences(this._prefs);

  static ProfilePreferences? _instance;
  static ProfilePreferences get instance {
    assert(_instance != null, 'ProfilePreferences.initialize() must be called first');
    return _instance!;
  }

  final SharedPreferences _prefs;

  static const _guestNameKey = 'guest_display_name';
  static const _currencyKey = 'default_currency';
  static const _localeKey = 'locale';

  static Future<ProfilePreferences> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = ProfilePreferences(prefs);
    return _instance!;
  }

  String get guestDisplayName => _prefs.getString(_guestNameKey) ?? 'Traveler';

  Future<void> setGuestDisplayName(String name) =>
      _prefs.setString(_guestNameKey, name.trim());

  String get defaultCurrency => _prefs.getString(_currencyKey) ?? 'HKD';

  Future<void> setDefaultCurrency(String code) => _prefs.setString(_currencyKey, code);

  String get locale => _prefs.getString(_localeKey) ?? 'en';

  Future<void> setLocale(String code) => _prefs.setString(_localeKey, code);
}
