extension StringExtension on String {
  /// 首字母大写
  String get capitalized => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// 是否为有效邮箱
  bool get isValidEmail => RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// 是否为有效密码（≥6位）
  bool get isValidPassword => length >= 6;
}

extension IntExtension on int {
  /// 经验值 → 等级（估算）
  int get toEstimatedLevel {
    double exp = 0;
    for (int lv = 1; lv <= 100; lv++) {
      exp += 1500 * (1.15).pow(lv - 1);
      if (exp > this) return lv;
    }
    return 100;
  }
}

extension DateTimeExtension on DateTime {
  /// 是否同一天
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// 格式化 yyyy-MM-dd
  String get yyyyMmDd => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
