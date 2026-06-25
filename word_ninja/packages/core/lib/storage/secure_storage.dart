import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage using SharedPreferences
class SecureStorage {
  static SharedPreferences? _prefs;

  static bool _initialized = false;

  static Future<void> _ensureInit() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  static Future<void> write(String key, String value) async {
    await _ensureInit();
    await _prefs!.setString(key, value);
  }

  static Future<String?> read(String key) async {
    await _ensureInit();
    return _prefs!.getString(key);
  }

  static Future<void> delete(String key) async {
    await _ensureInit();
    await _prefs!.remove(key);
  }

  static Future<void> clear() async {
    await _ensureInit();
    await _prefs!.clear();
  }
}

/// SharedPreferences wrapper
class Preferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  static Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  static int getInt(String key, {int defaultValue = 0}) =>
      _prefs.getInt(key) ?? defaultValue;

  static Future<void> setInt(String key, int value) =>
      _prefs.setInt(key, value);

  static String getString(String key, {String defaultValue = ''}) =>
      _prefs!.getString(key) ?? defaultValue;

  static Future<void> setString(String key, String value) =>
      _prefs!.setString(key, value);

  static Future<void> remove(String key) => _prefs!.remove(key);
}

/// Storage key constants
class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const userId = 'user_id';
  static const firstLaunch = 'first_launch';
  static const locale = 'locale';
  static const themeMode = 'theme_mode';
  static const lastSyncAt = 'last_sync_at';
}
