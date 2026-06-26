import '../../data/datasource/vocabulary_local_datasource.dart';
import '../../data/datasource/vocabulary_remote_datasource.dart';
import '../../data/model/word.dart';
import '../../data/model/review.dart';
import '../../data/model/vocabulary_stats.dart';
import '../../domain/repository/vocabulary_repository.dart';
import 'package:uuid/uuid.dart';

/// 单词仓库实现（本地优先）
class VocabularyRepositoryImpl implements VocabularyRepository {
  final VocabularyLocalDataSource _local;
  final VocabularyRemoteDataSource _remote;
  final _uuid = const Uuid();

  VocabularyRepositoryImpl(this._local, this._remote);

  @override
  Future<List<Word>> getWords({int page = 1, int size = 20}) =>
      _local.getWords(page: page, size: size);

  @override
  Future<Word?> getWord(String id) => _local.getWord(id);

  @override
  Future<List<Word>> searchWords(String query) => _local.searchWords(query);

  @override
  Future<void> addWord(Word word) async {
    final newWord = word.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _local.saveWord(newWord);
  }

  @override
  Future<void> updateWord(Word word) async {
    await _local.saveWord(word.copyWith(updatedAt: DateTime.now()));
  }

  @override
  Future<void> deleteWord(String id) => _local.deleteWord(id);

  @override
  Future<List<Word>> getDueReviews() => _local.getDueReviews();

  @override
  Future<void> submitReview(String wordId, int score) async {
    // 记录复习前排定日期
    final word = await _local.getWord(wordId);
    final review = Review(
      id: _uuid.v4(),
      wordId: wordId,
      reviewTime: DateTime.now(),
      score: score,
      isCompleted: true,
      scheduledFor: word?.nextReviewDate,
    );
    await _local.saveReview(review);
  }

  @override
  Future<VocabularyStats> getStats() => _local.getStats();

  @override
  Future<void> syncWithRemote() async {
    final localWords = await _local.getWords();
    if (localWords.isEmpty) return;
    await _remote.syncWords(localWords);
  }
}
