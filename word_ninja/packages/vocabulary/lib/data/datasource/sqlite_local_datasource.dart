import 'dart:convert';

import 'package:core/storage/sqlite/chat_database.dart';
import 'package:sqflite/sqflite.dart';

import '../model/review.dart';
import '../model/vocabulary_stats.dart';
import '../model/word.dart';
import 'vocabulary_local_datasource.dart';

/// SQLite-backed vocabulary storage. Every multi-row mutation is transactional.
class SqliteVocabularyLocalDataSource implements VocabularyLocalDataSource {
  Database get _db => ChatDatabase.db;

  static const _intervals = [1, 2, 4, 7, 15, 30, 60, 120];

  /// Copies legacy data in one transaction. Existing SQLite records are never
  /// overwritten, so this operation is safe to retry after an interrupted run.
  Future<void> importLegacy(VocabularyLocalDataSource legacy) async {
    final words = <Word>[];
    for (var page = 1;; page++) {
      final batch = await legacy.getWords(page: page, size: 200);
      words.addAll(batch);
      if (batch.length < 200) break;
    }
    if (words.isEmpty) return;

    final reviews = <Review>[];
    for (final word in words) {
      reviews.addAll(await legacy.getReviewsForWord(word.id));
    }
    await _db.transaction((txn) async {
      for (final word in words) {
        await txn.insert('words', _wordToRow(word),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      for (final review in reviews) {
        await txn.insert('word_reviews', _reviewToRow(review),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  @override
  Future<List<Word>> getWords({int page = 1, int size = 20}) async {
    final rows = await _db.query('words',
        orderBy: 'updated_at DESC, rowid DESC',
        limit: size,
        offset: (page - 1) * size);
    return rows.map(_wordFromRow).toList();
  }

  @override
  Future<Word?> getWord(String id) async {
    final rows = await _db.query('words', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : _wordFromRow(rows.first);
  }

  @override
  Future<List<Word>> searchWords(String query) async {
    final escaped = query
        .toLowerCase()
        .replaceAll(r'\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    final rows = await _db.query('words',
        where:
            "normalized_word LIKE ? ESCAPE '\\' OR lower(meaning) LIKE ? ESCAPE '\\'",
        whereArgs: ['%$escaped%', '%$escaped%'],
        orderBy: 'updated_at DESC');
    return rows.map(_wordFromRow).toList();
  }

  @override
  Future<void> saveWord(Word word) async {
    await _db.transaction((txn) async {
      final byId = await txn.query('words',
          columns: ['id'], where: 'id = ?', whereArgs: [word.id], limit: 1);
      if (byId.isNotEmpty) {
        await txn.update('words', _wordToRow(word),
            where: 'id = ?', whereArgs: [word.id]);
        return;
      }

      // A word may already exist outside the currently loaded UI page. Update
      // it in place so its ID and review-history foreign keys remain intact.
      final normalized = word.word.trim().toLowerCase();
      final duplicate = await txn.query('words',
          columns: ['id', 'created_at'],
          where: 'normalized_word = ?',
          whereArgs: [normalized],
          limit: 1);
      if (duplicate.isNotEmpty) {
        final existingId = duplicate.first['id']! as String;
        final values = _wordToRow(word)
          ..remove('id')
          ..['created_at'] = duplicate.first['created_at'];
        await txn.update('words', values,
            where: 'id = ?', whereArgs: [existingId]);
        return;
      }
      await txn.insert('words', _wordToRow(word),
          conflictAlgorithm: ConflictAlgorithm.abort);
    });
  }

  @override
  Future<void> saveWords(List<Word> words) async {
    await _db.transaction((txn) async {
      for (final word in words) {
        // Migration is deliberately non-destructive: an existing SQLite row wins.
        await txn.insert('words', _wordToRow(word),
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  @override
  Future<void> deleteWord(String id) async {
    await _db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Word>> getDueReviews() async {
    final rows = await _db.query('words',
        where: 'next_review_date IS NULL OR next_review_date <= ?',
        whereArgs: [DateTime.now().millisecondsSinceEpoch],
        orderBy: 'focus_score DESC, mastery ASC, next_review_date ASC');
    return rows.map(_wordFromRow).toList();
  }

  @override
  Future<void> saveReview(Review review) async {
    await _db.transaction((txn) async {
      final rows = await txn.query('words',
          where: 'id = ?', whereArgs: [review.wordId], limit: 1);
      if (rows.isEmpty) {
        throw StateError(
            'Cannot save a review for missing word ${review.wordId}');
      }
      final word = _wordFromRow(rows.first);
      final level = word.reviewCount.clamp(0, _intervals.length - 1);
      final nextLevel = review.score >= 5
          ? (level + 1).clamp(0, _intervals.length - 1)
          : review.score >= 3
              ? level
              : 0;
      var days = _intervals[nextLevel];
      if (word.focusScore > 0) days = (days ~/ 2).clamp(1, 120);
      final now = DateTime.now();
      final updated = word.copyWith(
        mastery: (word.mastery + review.score * 5).clamp(0, 100),
        reviewCount: review.score >= 5
            ? (word.reviewCount + 1).clamp(1, _intervals.length)
            : review.score >= 3
                ? word.reviewCount
                : 1,
        nextReviewDate: now.add(Duration(days: days)),
        updatedAt: now,
      );
      await txn.insert('word_reviews', _reviewToRow(review),
          conflictAlgorithm: ConflictAlgorithm.ignore);
      await txn.update('words', _wordToRow(updated),
          where: 'id = ?', whereArgs: [word.id]);
    });
  }

  @override
  Future<List<Review>> getReviewsForWord(String wordId) async {
    final rows = await _db.query('word_reviews',
        where: 'word_id = ?', whereArgs: [wordId], orderBy: 'review_time DESC');
    return rows.map(_reviewFromRow).toList();
  }

  @override
  Future<VocabularyStats> getStats() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    Future<int> count(String table,
        {String? where, List<Object?>? args}) async {
      final result = await _db.rawQuery(
          'SELECT COUNT(*) AS count FROM $table${where == null ? '' : ' WHERE $where'}',
          args);
      return Sqflite.firstIntValue(result) ?? 0;
    }

    return VocabularyStats(
      totalWords: await count('words'),
      masteredWords: await count('words', where: 'mastery >= 80'),
      todayReview:
          await count('word_reviews', where: 'review_time >= ?', args: [start]),
      todayNew: await count('words', where: 'created_at >= ?', args: [start]),
      learningWords: await count('words',
          where: 'next_review_date IS NULL OR next_review_date <= ?',
          args: [now.millisecondsSinceEpoch]),
    );
  }

  static Map<String, Object?> _wordToRow(Word word) => {
        'id': word.id,
        'user_id': word.userId,
        'word': word.word,
        'normalized_word': word.word.trim().toLowerCase(),
        'meaning': word.meaning,
        'phonetic': word.phonetic,
        'example': word.example,
        'difficulty': word.difficulty,
        'mastery': word.mastery,
        'source': word.source,
        'tags_json': jsonEncode(word.tags),
        'created_at': word.createdAt?.millisecondsSinceEpoch,
        'updated_at': word.updatedAt?.millisecondsSinceEpoch,
        'next_review_date': word.nextReviewDate?.millisecondsSinceEpoch,
        'review_count': word.reviewCount,
        'focus_score': word.focusScore,
      };

  static Map<String, Object?> _reviewToRow(Review review) => {
        'id': review.id,
        'word_id': review.wordId,
        'review_time': review.reviewTime.millisecondsSinceEpoch,
        'score': review.score,
        'is_completed': review.isCompleted ? 1 : 0,
        'interval_days': review.interval,
        'scheduled_for': review.scheduledFor?.millisecondsSinceEpoch,
      };

  static Word _wordFromRow(Map<String, Object?> row) => Word(
        id: row['id']! as String,
        userId: row['user_id']! as String,
        word: row['word']! as String,
        meaning: row['meaning']! as String,
        phonetic: row['phonetic']! as String,
        example: row['example']! as String,
        difficulty: row['difficulty']! as int,
        mastery: row['mastery']! as int,
        source: row['source']! as String,
        tags: (jsonDecode(row['tags_json']! as String) as List).cast<String>(),
        createdAt: _date(row['created_at']),
        updatedAt: _date(row['updated_at']),
        nextReviewDate: _date(row['next_review_date']),
        reviewCount: row['review_count']! as int,
        focusScore: row['focus_score']! as int,
      );

  static Review _reviewFromRow(Map<String, Object?> row) => Review(
        id: row['id']! as String,
        wordId: row['word_id']! as String,
        reviewTime: _date(row['review_time'])!,
        score: row['score']! as int,
        isCompleted: row['is_completed'] == 1,
        interval: row['interval_days']! as int,
        scheduledFor: _date(row['scheduled_for']),
      );

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.fromMillisecondsSinceEpoch(value as int);
}
