/// 单词领域实体（简化，不含序列化依赖）
class WordEntity {
  final String id;
  final String word;
  final String meaning;
  final String phonetic;
  final String example;
  final int difficulty;
  final int mastery;
  final String source;
  final List<String> tags;

  const WordEntity({
    required this.id,
    required this.word,
    required this.meaning,
    this.phonetic = '',
    this.example = '',
    this.difficulty = 1,
    this.mastery = 0,
    this.source = 'manual',
    this.tags = const [],
  });

  /// 掌握度等级
  String get masteryLevel {
    if (mastery >= 85) return '已掌握';
    if (mastery >= 60) return '熟悉';
    if (mastery >= 30) return '学习中';
    return '陌生';
  }
}
