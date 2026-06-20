/// 单词本统计
class VocabularyStats {
  final int totalWords;
  final int masteredWords;
  final int learningWords;
  final int todayNew;
  final int todayReview;

  const VocabularyStats({
    this.totalWords = 0,
    this.masteredWords = 0,
    this.learningWords = 0,
    this.todayNew = 0,
    this.todayReview = 0,
  });

  /// 掌握率
  double get masteryRate =>
      totalWords > 0 ? masteredWords / totalWords : 0.0;

  /// 待复习数
  int get dueReviewCount => todayReview;

  factory VocabularyStats.fromJson(Map<String, dynamic> json) =>
      VocabularyStats(
        totalWords: (json['total_words'] as num?)?.toInt() ?? 0,
        masteredWords: (json['mastered_words'] as num?)?.toInt() ?? 0,
        learningWords: (json['learning_words'] as num?)?.toInt() ?? 0,
        todayNew: (json['today_new'] as num?)?.toInt() ?? 0,
        todayReview: (json['today_review'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'total_words': totalWords,
        'mastered_words': masteredWords,
        'learning_words': learningWords,
        'today_new': todayNew,
        'today_review': todayReview,
      };
}
