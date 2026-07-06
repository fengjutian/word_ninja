import 'dart:math';
import 'package:core/storage/isar/isar_service.dart';
import 'package:core/storage/isar/schemas/word_schema.dart';
import 'package:core/storage/isar/schemas/review_schema.dart';
import 'package:vocabulary/data/datasource/vocabulary_local_datasource.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/data/model/review.dart';
import 'package:vocabulary/data/model/vocabulary_stats.dart';
import 'package:isar/isar.dart';

/// Isar 本地持久化数据源
class IsarVocabularyLocalDataSource implements VocabularyLocalDataSource {
  Isar get _isar => IsarService.instance;

  /// 艾宾浩斯遗忘曲线间隔（天）
  static const List<int> _ebbinghausIntervals = [1, 2, 4, 7, 15, 30, 60, 120];

  // ─── Word ↔ WordSchema 转换 ───

  static Word _wordFromSchema(WordSchema s) => Word(
        id: s.wordId,
        userId: s.userId,
        word: s.word,
        meaning: s.meaning,
        phonetic: s.phonetic ?? '',
        example: s.example ?? '',
        difficulty: s.difficulty,
        mastery: s.mastery,
        source: s.source,
        tags: s.tags,
        createdAt: s.createdAt,
        updatedAt: s.updatedAt,
        nextReviewDate: s.nextReviewDate,
        reviewCount: s.reviewCount,
      );

  static WordSchema _wordToSchema(Word w) {
    final s = WordSchema()
      ..wordId = w.id
      ..userId = w.userId
      ..word = w.word
      ..meaning = w.meaning
      ..phonetic = w.phonetic
      ..example = w.example
      ..difficulty = w.difficulty
      ..mastery = w.mastery
      ..source = w.source
      ..tags = w.tags
      ..createdAt = w.createdAt ?? DateTime.now()
      ..updatedAt = w.updatedAt ?? DateTime.now()
      ..nextReviewDate = w.nextReviewDate
      ..reviewCount = w.reviewCount;
    return s;
  }

  // ─── Word CRUD ───

  @override
  Future<List<Word>> getWords({int page = 1, int size = 20}) async {
    final offset = (page - 1) * size;
    final schemas = await _isar.wordSchemas
        .where()
        .sortByUpdatedAtDesc()
        .offset(offset)
        .limit(size)
        .findAll();
    return schemas.map(_wordFromSchema).toList();
  }

  @override
  Future<Word?> getWord(String id) async {
    final s = await _isar.wordSchemas.where().wordIdEqualTo(id).findFirst();
    return s != null ? _wordFromSchema(s) : null;
  }

  @override
  Future<List<Word>> searchWords(String query) async {
    final q = query.toLowerCase();
    // Isar 不支持模糊搜索，用全量+内存过滤
    final all = await _isar.wordSchemas.where().findAll();
    return all
        .where((s) =>
            s.word.toLowerCase().contains(q) ||
            s.meaning.toLowerCase().contains(q))
        .map(_wordFromSchema)
        .toList();
  }

  @override
  Future<void> saveWord(Word word) async {
    final schema = _wordToSchema(word);
    // 查找现有记录（按 wordId 匹配以支持 upsert）
    final existing = await _isar.wordSchemas
        .where()
        .wordIdEqualTo(word.id)
        .findFirst();
    if (existing != null) {
      schema.id = existing.id; // 复用 Isar ID 实现 update
      await _isar.writeTxn(() => _isar.wordSchemas.put(schema));
    } else {
      await _isar.writeTxn(() => _isar.wordSchemas.put(schema));
    }
  }

  @override
  Future<void> saveWords(List<Word> words) async {
    final schemas = words.map(_wordToSchema).toList();
    await _isar.writeTxn(() => _isar.wordSchemas.putAll(schemas));
  }

  @override
  Future<void> deleteWord(String id) async {
    final existing = await _isar.wordSchemas
        .where()
        .wordIdEqualTo(id)
        .findFirst();
    if (existing != null) {
      await _isar.writeTxn(() => _isar.wordSchemas.delete(existing.id));
    }
  }

  // ─── Review ───

  @override
  Future<List<Word>> getDueReviews() async {
    final now = DateTime.now();
    // 到期：nextReviewDate 为 null 或 <= now
    final all = await _isar.wordSchemas.where().findAll();
    final due = all.where((s) {
      if (s.nextReviewDate == null) return true;
      return !s.nextReviewDate!.isAfter(now);
    }).toList()
      ..sort((a, b) {
        if (a.nextReviewDate == null && b.nextReviewDate != null) return -1;
        if (a.nextReviewDate != null && b.nextReviewDate == null) return 1;
        if (a.nextReviewDate == null && b.nextReviewDate == null) {
          return a.mastery.compareTo(b.mastery);
        }
        return a.nextReviewDate!.compareTo(b.nextReviewDate!);
      });
    return due.map(_wordFromSchema).toList();
  }

  @override
  Future<void> saveReview(Review review) async {
    // 保存复习记录
    final rs = ReviewSchema()
      ..reviewId = review.id
      ..wordId = review.wordId
      ..reviewTime = review.reviewTime
      ..score = review.score
      ..isCompleted = review.isCompleted
      ..createdAt = DateTime.now();
    await _isar.writeTxn(() => _isar.reviewSchemas.put(rs));

    // 更新单词的 mastery 和间隔
    final existing = await _isar.wordSchemas
        .where()
        .wordIdEqualTo(review.wordId)
        .findFirst();
    if (existing == null) return;

    final oldMastery = existing.mastery;
    final oldCount = existing.reviewCount;
    final gain = review.score * 5;
    final newMastery = (oldMastery + gain).clamp(0, 100);

    final currentLevel = oldCount.clamp(0, _ebbinghausIntervals.length - 1);
    final nextLevel = _nextEbbinghausLevel(currentLevel, review.score);
    final intervalDays = _ebbinghausIntervals[nextLevel];
    final newCount = review.score >= 5
        ? (oldCount + 1).clamp(1, _ebbinghausIntervals.length)
        : review.score >= 3
            ? oldCount
            : 1;

    existing.mastery = newMastery;
    existing.reviewCount = newCount;
    existing.nextReviewDate = DateTime.now().add(Duration(days: intervalDays));
    existing.updatedAt = DateTime.now();

    await _isar.writeTxn(() => _isar.wordSchemas.put(existing));
  }

  static int _nextEbbinghausLevel(int currentLevel, int score) {
    if (score >= 5) return (currentLevel + 1).clamp(0, _ebbinghausIntervals.length - 1);
    if (score >= 3) return currentLevel;
    return 0;
  }

  @override
  Future<List<Review>> getReviewsForWord(String wordId) async {
    final schemas = await _isar.reviewSchemas
        .filter()
        .wordIdEqualTo(wordId)
        .findAll();
    return schemas
        .map((s) => Review(
              id: s.reviewId,
              wordId: s.wordId,
              reviewTime: s.reviewTime,
              score: s.score,
              isCompleted: s.isCompleted,
            ))
        .toList();
  }

  @override
  Future<VocabularyStats> getStats() async {
    final words = await _isar.wordSchemas.where().findAll();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayReviews = await _isar.reviewSchemas
        .filter()
        .reviewTimeGreaterThan(todayStart)
        .count();
    final now = DateTime.now();
    final due = words.where((s) {
      if (s.nextReviewDate == null) return true;
      return !s.nextReviewDate!.isAfter(now);
    }).length;
    return VocabularyStats(
      totalWords: words.length,
      masteredWords: words.where((s) => s.mastery >= 80).length,
      todayReview: todayReviews,
      learningWords: due,
    );
  }
}
