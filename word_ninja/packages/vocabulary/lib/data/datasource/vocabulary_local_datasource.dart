import '../model/word.dart';
import '../model/review.dart';
import '../model/vocabulary_stats.dart';

/// 单词本地数据源
abstract class VocabularyLocalDataSource {
  Future<List<Word>> getWords({int page = 1, int size = 20});
  Future<Word?> getWord(String id);
  Future<List<Word>> searchWords(String query);
  Future<void> saveWord(Word word);
  Future<void> saveWords(List<Word> words);
  Future<void> deleteWord(String id);

  /// 获取待复习单词（艾宾浩斯）
  Future<List<Word>> getDueReviews();
  Future<void> saveReview(Review review);
  Future<List<Review>> getReviewsForWord(String wordId);
  Future<VocabularyStats> getStats();
}
