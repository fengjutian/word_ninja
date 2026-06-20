import '../model/word.dart';
import '../model/review.dart';
import '../model/vocabulary_stats.dart';

/// 单词仓库接口
abstract class VocabularyRepository {
  Future<List<Word>> getWords({int page = 1, int size = 20});
  Future<Word?> getWord(String id);
  Future<List<Word>> searchWords(String query);
  Future<void> addWord(Word word);
  Future<void> updateWord(Word word);
  Future<void> deleteWord(String id);

  /// 艾宾浩斯复习
  Future<List<Word>> getDueReviews();
  Future<void> submitReview(String wordId, int score);

  /// 统计
  Future<VocabularyStats> getStats();

  /// 同步
  Future<void> syncWithRemote();
}
