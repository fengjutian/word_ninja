import 'package:shared_preferences/shared_preferences.dart';

/// 本地偏好设置存储
class Preferences {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── bool ───
  static bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  static Future<bool> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  // ─── int ───
  static int getInt(String key, {int defaultValue = 0}) =>
      _prefs.getInt(key) ?? defaultValue;

  static Future<bool> setInt(String key, int value) =>
      _prefs.setInt(key, value);

  // ─── String ───
  static String getString(String key, {String defaultValue = ''}) =>
      _prefs.getString(key) ?? defaultValue;

  static Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  // ─── double ───
  static double getDouble(String key, {double defaultValue = 0.0}) =>
      _prefs.getDouble(key) ?? defaultValue;

  static Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  // ─── 通用 ───
  static Future<bool> remove(String key) => _prefs.remove(key);

  static Future<void> clear() => _prefs.clear();
}
