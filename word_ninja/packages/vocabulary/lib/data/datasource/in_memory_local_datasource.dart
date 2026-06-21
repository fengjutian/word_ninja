import 'package:vocabulary/data/datasource/vocabulary_local_datasource.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/data/model/review.dart';
import 'package:vocabulary/data/model/vocabulary_stats.dart';

/// 内存版本地数据源（开发/演示用）
class InMemoryVocabularyLocalDataSource
    implements VocabularyLocalDataSource {
  final List<Word> _words = [];
  final List<Review> _reviews = [];

  @override
  Future<List<Word>> getWords({int page = 1, int size = 20}) async {
    final start = (page - 1) * size;
    if (start >= _words.length) return [];
    return _words.skip(start).take(size).toList();
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
        .where((w) =>
            w.word.toLowerCase().contains(q) ||
            w.meaning.toLowerCase().contains(q))
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

  @override
  Future<List<Word>> getDueReviews() async {
    // 默认没有待复习单词
    return [];
  }

  @override
  Future<void> saveReview(Review review) async {
    _reviews.add(review);
  }

  @override
  Future<List<Review>> getReviewsForWord(String wordId) async {
    return _reviews.where((r) => r.wordId == wordId).toList();
  }

  @override
  Future<VocabularyStats> getStats() async {
    final totalWords = _words.length;
    return VocabularyStats(
      totalWords: totalWords,
      masteredWords: _words.where((w) => w.mastery >= 0.8).length,
      todayReview: 0,
    );
  }
}
