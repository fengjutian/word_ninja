/// 成就类型
enum AchievementType {
  wordCount,
  readingCount,
  streak,
  vocabularyMastery,
  aiChat,
  level,
}

/// 成就定义
class Achievement {
  final String id;
  final AchievementType type;
  final String title;
  final String description;
  final String icon;
  final int target;
  int progress;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    this.progress = 0,
    this.isUnlocked = false,
  });

  double get progressPercent => (progress / target).clamp(0.0, 1.0);

  static List<Achievement> defaults() => [
        Achievement(
          id: 'word_100',
          type: AchievementType.wordCount,
          title: '初识忍术',
          description: '累计学习 100 个单词',
          icon: '📖',
          target: 100,
        ),
        Achievement(
          id: 'word_500',
          type: AchievementType.wordCount,
          title: '忍术学徒',
          description: '累计学习 500 个单词',
          icon: '📚',
          target: 500,
        ),
        Achievement(
          id: 'word_1000',
          type: AchievementType.wordCount,
          title: '下忍出击',
          description: '累计学习 1000 个单词',
          icon: '⚔️',
          target: 1000,
        ),
        Achievement(
          id: 'streak_7',
          type: AchievementType.streak,
          title: '坚持不懈',
          description: '连续学习 7 天',
          icon: '🔥',
          target: 7,
        ),
        Achievement(
          id: 'streak_30',
          type: AchievementType.streak,
          title: '忍道',
          description: '连续学习 30 天',
          icon: '💪',
          target: 30,
        ),
        Achievement(
          id: 'streak_100',
          type: AchievementType.streak,
          title: '传奇忍者',
          description: '连续学习 100 天',
          icon: '🏆',
          target: 100,
        ),
        Achievement(
          id: 'reading_10',
          type: AchievementType.readingCount,
          title: '书虫',
          description: '阅读 10 篇文章',
          icon: '📄',
          target: 10,
        ),
        Achievement(
          id: 'level_20',
          type: AchievementType.level,
          title: '中忍',
          description: '达到 20 级',
          icon: '🎯',
          target: 20,
        ),
        Achievement(
          id: 'level_50',
          type: AchievementType.level,
          title: '忍者大师',
          description: '达到 50 级',
          icon: '👑',
          target: 50,
        ),
      ];
}
