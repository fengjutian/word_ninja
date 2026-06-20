/// 全局常量
class AppConstants {
  AppConstants._();

  /// App 名称
  static const String appName = 'Word Ninja';

  /// 忍者等级上限
  static const int maxLevel = 100;

  /// 每级所需基础经验
  static const int baseExpPerLevel = 1500;

  /// 经验倍率（等级越高升级越慢）
  static const double expMultiplier = 1.15;

  /// API 基础地址
  static const String apiBaseUrl = 'http://localhost:8080';

  /// API 版本
  static const String apiVersion = '/api/v1';

  /// 学习相关
  static const int dailyWordGoal = 20;
  static const int dailyReadingGoal = 1;
  static const int dailyAiChatMinutes = 10;
  static const int reviewIntervalHours = 24;

  /// 数据库
  static const String isarDbName = 'word_ninja';
}
