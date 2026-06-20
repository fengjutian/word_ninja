import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/model/word.dart';
import '../data/model/vocabulary_stats.dart';
import '../domain/repository/vocabulary_repository.dart';

/// 单词列表状态
class WordListState {
  final List<Word> words;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  const WordListState({
    this.words = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  WordListState copyWith({
    List<Word>? words,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) =>
      WordListState(
        words: words ?? this.words,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        hasMore: hasMore ?? this.hasMore,
      );
}

/// 单词仓库 Provider（需在 app DI 中 override）
final vocabularyRepositoryProvider = Provider<VocabularyRepository>((ref) {
  throw UnimplementedError('vocabularyRepositoryProvider must be overridden in app DI');
});

/// 单词 Provider
final wordListProvider =
    StateNotifierProvider<WordListNotifier, WordListState>((ref) {
  final repo = ref.read(vocabularyRepositoryProvider);
  return WordListNotifier(repo);
});

/// 单词统计 Provider
final vocabularyStatsProvider = FutureProvider<VocabularyStats>((ref) async {
  final repo = ref.read(vocabularyRepositoryProvider);
  return repo.getStats();
});

/// 待复习单词 Provider
final dueReviewProvider = FutureProvider<List<Word>>((ref) async {
  final repo = ref.read(vocabularyRepositoryProvider);
  return repo.getDueReviews();
});

class WordListNotifier extends StateNotifier<WordListState> {
  final VocabularyRepository _repo;

  WordListNotifier(this._repo) : super(const WordListState());

  int _page = 1;

  Future<void> loadWords({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      state = state.copyWith(isLoading: true, error: null);
    } else if (state.isLoading) return;

    try {
      final words = await _repo.getWords(page: _page);
      state = state.copyWith(
        words: refresh ? words : [...state.words, ...words],
        isLoading: false,
        hasMore: words.length >= 20,
      );
      _page++;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addWord(Word word) async {
    await _repo.addWord(word);
    await loadWords(refresh: true);
  }

  Future<void> deleteWord(String id) async {
    await _repo.deleteWord(id);
    state = state.copyWith(
      words: state.words.where((w) => w.id != id).toList(),
    );
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      await loadWords(refresh: true);
      return;
    }
    state = state.copyWith(isLoading: true);
    final results = await _repo.searchWords(query);
    state = WordListState(words: results, hasMore: false);
  }
}
