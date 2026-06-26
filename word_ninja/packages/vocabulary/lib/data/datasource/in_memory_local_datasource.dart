import 'package:vocabulary/data/datasource/vocabulary_local_datasource.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/data/model/review.dart';
import 'package:vocabulary/data/model/vocabulary_stats.dart';

/// 内存版本地数据源（开发/演示用，本地持久化后续可用 Isar 替换）
class InMemoryVocabularyLocalDataSource implements VocabularyLocalDataSource {
  final List<Word> _words = [];
  final List<Review> _reviews = [];

  /// 艾宾浩斯遗忘曲线间隔（天）
  static const List<int> _ebbinghausIntervals = [1, 2, 4, 7, 15, 30, 60, 120];

  @override
  Future<List<Word>> getWords({int page = 1, int size = 20}) async {
    final sorted = List<Word>.from(_words)..sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
    final start = (page - 1) * size;
    if (start >= sorted.length) return [];
    return sorted.skip(start).take(size).toList();
  }

  @override
  Future<Word?> getWord(String id) async {
    try {
      return _words.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Word>> searchWords(String query) async {
    final q = query.toLowerCase();
    return _words
        .where((w) => w.word.toLowerCase().contains(q) || w.meaning.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<void> saveWord(Word word) async {
    final index = _words.indexWhere((w) => w.id == word.id);
    if (index >= 0) {
      _words[index] = word;
    } else {
      _words.add(word);
    }
  }

  @override
  Future<void> saveWords(List<Word> words) async {
    for (final word in words) {
      await saveWord(word);
    }
  }

  @override
  Future<void> deleteWord(String id) async {
    _words.removeWhere((w) => w.id == id);
  }

  /// 获取到期复习单词（艾宾浩斯）
  /// nextReviewDate 为 null（从未复习）或已到期（<= 当前时间）
  @override
  Future<List<Word>> getDueReviews() async {
    final now = DateTime.now();
    return _words
        .where((w) => w.nextReviewDate == null || w.nextReviewDate!.isBefore(now) || w.nextReviewDate!.isAtSameMomentAs(now))
        .toList()
      ..sort((a, b) {
        // null nextReviewDate（从未复习）排最前面
        if (a.nextReviewDate == null && b.nextReviewDate != null) return -1;
        if (a.nextReviewDate != null && b.nextReviewDate == null) return 1;
        if (a.nextReviewDate == null && b.nextReviewDate == null) {
          return a.mastery.compareTo(b.mastery);
        }
        return a.nextReviewDate!.compareTo(b.nextReviewDate!);
      });
  }

  /// 保存复习记录，同时应用艾宾浩斯间隔算法更新单词的 mastery 和 nextReviewDate
  @override
  Future<void> saveReview(Review review) async {
    _reviews.add(review);
    final index = _words.indexWhere((w) => w.id == review.wordId);
    if (index < 0) return;

    final word = _words[index];
    final now = DateTime.now();

    // 计算 mastery 增益
    final gain = review.score * 5;
    final newMastery = (word.mastery + gain).clamp(0, 100);

    // 艾宾浩斯间隔计算
    final currentLevel = word.reviewCount.clamp(0, _ebbinghausIntervals.length - 1);
    final nextLevel = _nextEbbinghausLevel(currentLevel, review.score);
    final intervalDays = _ebbinghausIntervals[nextLevel];
    final nextReview = now.add(Duration(days: intervalDays));
    // reviewCount 追踪间隔等级：score>=5 递增，score>=3 保持，score<3 重置为1
    final newReviewCount = review.score >= 5
        ? (word.reviewCount + 1).clamp(1, _ebbinghausIntervals.length)
        : review.score >= 3
            ? word.reviewCount
            : 1;

    _words[index] = word.copyWith(
      mastery: newMastery,
      reviewCount: newReviewCount,
      nextReviewDate: nextReview,
      updatedAt: now,
    );
  }

  /// 根据评分计算下一个艾宾浩斯间隔等级
  /// score >= 5: 进阶到下一级
  /// score >= 3: 保持当前等级
  /// score < 3:  重置到第一级
  static int _nextEbbinghausLevel(int currentLevel, int score) {
    if (score >= 5) return (currentLevel + 1).clamp(0, _ebbinghausIntervals.length - 1);
    if (score >= 3) return currentLevel;
    return 0;
  }

  @override
  Future<List<Review>> getReviewsForWord(String wordId) async {
    return _reviews.where((r) => r.wordId == wordId).toList();
  }

  /// mastery 为 0-100 整数，>=80 视为已掌握
  @override
  Future<VocabularyStats> getStats() async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayReviews = _reviews.where((r) => r.reviewTime.isAfter(todayStart)).length;
    final now = DateTime.now();
    final dueCount = _words.where((w) =>
        w.nextReviewDate == null ||
        w.nextReviewDate!.isBefore(now) ||
        w.nextReviewDate!.isAtSameMomentAs(now)).length;
    return VocabularyStats(
      totalWords: _words.length,
      masteredWords: _words.where((w) => w.mastery >= 80).length,
      todayReview: todayReviews,
      learningWords: dueCount,
    );
  }
}
