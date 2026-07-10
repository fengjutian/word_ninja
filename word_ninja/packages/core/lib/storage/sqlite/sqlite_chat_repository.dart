import 'dart:convert';

import 'package:core/logger/logger.dart';

import 'chat_database.dart';
import 'chat_repository.dart';

/// SQLite 实现的 ChatRepository
class SqliteChatRepository implements ChatRepository {
  // ─── Sessions ──────────────────────────────────────────────

  @override
  Future<void> upsertSession({
    required String id,
    String title = '新会话',
    required int createdAt,
  }) async {
    await ChatDatabase.upsertSession(
        id: id, title: title, createdAt: createdAt);
  }

  @override
  Future<void> updateSessionTitle(String id, String title) async {
    await ChatDatabase.updateSessionTitle(id, title);
  }

  @override
  Future<void> updateSessionTimestamp(String id, int timestamp) async {
    await ChatDatabase.updateSessionTimestamp(id, timestamp);
  }

  @override
  Future<List<SessionData>> getAllSessions() async {
    final rows = await ChatDatabase.getAllSessions();
    return rows.map(_rowToSession).toList();
  }

  @override
  Future<SessionData?> getSession(String id) async {
    final row = await ChatDatabase.getSession(id);
    if (row == null) return null;
    return _rowToSession(row);
  }

  @override
  Future<void> archiveSession(String id) async {
    await ChatDatabase.archiveSession(id);
  }

  @override
  Future<void> deleteSession(String id) async {
    await ChatDatabase.deleteSession(id);
  }

  @override
  Future<void> clearSessionMessages(String sessionId) async {
    await ChatDatabase.deleteSessionMessages(sessionId);
  }

  @override
  Future<void> updateSessionStats(
      String id, int messageCount, int timestamp) async {
    await ChatDatabase.updateSessionStats(id, messageCount, timestamp);
  }

  // ─── Messages ──────────────────────────────────────────────

  @override
  Future<int> insertMessage(MessageData message) async {
    return ChatDatabase.insertMessage(
      sessionId: message.sessionId,
      role: message.role,
      content: message.content,
      wordsJson:
          message.words != null && message.words!.isNotEmpty
              ? jsonEncode(message.words)
              : null,
      createdAt: message.createdAt,
    );
  }

  @override
  Future<List<MessageData>> getMessages(String sessionId,
      {int limit = 50, int offset = 0}) async {
    final rows = await ChatDatabase.getMessages(sessionId,
        limit: limit, offset: offset);
    return rows.map(_rowToMessage).toList();
  }

  @override
  Future<int> sessionMessageCount(String sessionId) async {
    return ChatDatabase.sessionMessageCount(sessionId);
  }

  // ─── Word Stats ────────────────────────────────────────────

  @override
  Future<void> upsertWordStats(
      {required String word, required int timestamp}) async {
    await ChatDatabase.upsertWordStats(word: word, timestamp: timestamp);
  }

  @override
  Future<List<WordFrequency>> topWords({int limit = 20}) async {
    final rows = await ChatDatabase.topWords(limit: limit);
    return rows
        .map((r) =>
            WordFrequency(word: r['word'] as String, count: r['ask_count'] as int))
        .toList();
  }

  @override
  Future<List<WordFrequency>> wordsSince(int timestampMs) async {
    final rows = await ChatDatabase.wordsSince(timestampMs);
    return rows
        .map((r) =>
            WordFrequency(word: r['word'] as String, count: r['ask_count'] as int))
        .toList();
  }

  @override
  Future<List<WordFrequency>> userWordFrequency(
      {int days = 30, int limit = 50}) async {
    final rows =
        await ChatDatabase.userWordFrequency(days: days, limit: limit);
    return rows
        .map((r) =>
            WordFrequency(word: r['word'] as String, count: r['cnt'] as int))
        .toList();
  }

  // ─── Row mappers ───────────────────────────────────────────

  SessionData _rowToSession(Map<String, dynamic> row) {
    return SessionData(
      id: row['id'] as String,
      title: row['title'] as String,
      createdAt: row['created_at'] as int,
      updatedAt: row['updated_at'] as int,
      messageCount: row['message_count'] as int? ?? 0,
      isArchived: (row['is_archived'] as int? ?? 0) == 1,
    );
  }

  MessageData _rowToMessage(Map<String, dynamic> row) {
    List<String>? words;
    final wj = row['words_json'] as String?;
    if (wj != null && wj.isNotEmpty) {
      try {
        words = (jsonDecode(wj) as List).cast<String>();
      } catch (e) {
        log.w('Failed to decode words_json', e);
      }
    }
    return MessageData(
      id: row['id'] as int?,
      sessionId: row['session_id'] as String,
      role: row['role'] as String,
      content: row['content'] as String,
      words: words,
      createdAt: row['created_at'] as int,
    );
  }
}
