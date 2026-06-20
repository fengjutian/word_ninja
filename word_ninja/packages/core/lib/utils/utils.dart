/// 计算升到指定等级所需的总经验
int expForLevel(int level) {
  if (level <= 1) return 0;
  double total = 0;
  for (int i = 1; i < level; i++) {
    total += 1500 * (1.15).pow(i - 1);
  }
  return total.round();
}

/// 格式化经验值显示
String formatExp(int current, int needed) => '$current / $needed';

/// 生成唯一 ID
String generateId() {
  final now = DateTime.now();
  return '${now.millisecondsSinceEpoch}_${now.microsecondsSinceEpoch}';
}

/// 计算连续学习天数
int calculateStreak(List<DateTime> dates) {
  if (dates.isEmpty) return 0;
  final sorted = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
    ..sort((a, b) => b.compareTo(a));

  int streak = 1;
  for (int i = 0; i < sorted.length - 1; i++) {
    final diff = sorted[i].difference(sorted[i + 1]).inDays;
    if (diff == 1) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

/// 根据掌握度返回颜色值（0-100）
int masteryColor(int mastery) {
  if (mastery < 30) return 0xFFE53935; // 红
  if (mastery < 60) return 0xFFFB8C00; // 橙
  if (mastery < 85) return 0xFF43A047; // 绿
  return 0xFF1E88E5; // 蓝
}
