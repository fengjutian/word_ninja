import 'package:vocabulary/data/datasource/vocabulary_local_datasource.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/data/model/review.dart';
import 'package:vocabulary/data/model/vocabulary_stats.dart';

/// 内存版本地数据源（开发/演示用，本地持久化后续可用 Isar 替换）
class InMemoryVocabularyLocalDataSource implements VocabularyLocalDataSource {
  final List<Word> _words = [];
  final List<Review> _reviews = [];

  @override
  Future<List<Word>> getWords({int page = 1, int size = 20}) async {
    final sorted = List<Word>.from(_words)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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

  /// 获取到期复习单词：mastery < 80 且最近24h未复习
  @override
  Future<List<Word>> getDueReviews() async {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
    final reviewedWordIds = _reviews
        .where((r) => r.reviewTime.isAfter(twentyFourHoursAgo))
        .map((r) => r.wordId)
        .toSet();
    return _words
        .where((w) => w.mastery < 80 && !reviewedWordIds.contains(w.id))
        .toList()
      ..sort((a, b) => a.mastery.compareTo(b.mastery)); // 低掌握度优先
  }

  /// 保存复习记录，同时更新单词掌握度（每次复习 +5~25 mastery，基于评分）
  @override
  Future<void> saveReview(Review review) async {
    _reviews.add(review);
    // 更新单词 mastery: 评分1-5，每次最多增加25
    final index = _words.indexWhere((w) => w.id == review.wordId);
    if (index >= 0) {
      final word = _words[index];
      final gain = review.score * 5;
      final newMastery = (word.mastery + gain).clamp(0, 100);
      _words[index] = word.copyWith(mastery: newMastery, updatedAt: DateTime.now());
    }
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
    return VocabularyStats(
      totalWords: _words.length,
      masteredWords: _words.where((w) => w.mastery >= 80).length,
      todayReview: todayReviews,
    );
  }
}
