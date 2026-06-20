import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 安全存储（Token/密码）
class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<String?> read(String key) => _storage.read(key: key);

  static Future<void> delete(String key) => _storage.delete(key: key);

  static Future<void> clear() => _storage.deleteAll();
}

/// SharedPreferences 封装（偏好设置）
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
      _prefs.getString(key) ?? defaultValue;

  static Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  static Future<void> remove(String key) => _prefs.remove(key);
}

/// 存储 Key 常量
class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
  static const userId = 'user_id';
  static const firstLaunch = 'first_launch';
  static const locale = 'locale';
  static const themeMode = 'theme_mode';
  static const lastSyncAt = 'last_sync_at';
}
