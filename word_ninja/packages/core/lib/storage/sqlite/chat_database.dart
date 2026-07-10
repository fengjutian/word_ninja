
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite 聊天数据库 — 负责建表、连接、底层 CRUD
class ChatDatabase {
  static Database? _db;

  static Database get db {
    if (_db == null) throw StateError('ChatDatabase not initialized');
    return _db!;
  }

  static Future<void> open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'word_ninja_chat.sqlite');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat_sessions (
        id          TEXT PRIMARY KEY,
        title       TEXT NOT NULL DEFAULT '新会话',
        created_at  INTEGER NOT NULL,
        updated_at  INTEGER NOT NULL,
        message_count INTEGER NOT NULL DEFAULT 0,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id  TEXT NOT NULL,
        role        TEXT NOT NULL CHECK(role IN ('user','assistant','system')),
        content     TEXT NOT NULL,
        words_json  TEXT,
        created_at  INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES chat_sessions(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_msg_session_time ON chat_messages(session_id, created_at)');
    await db.execute('CREATE INDEX idx_msg_role ON chat_messages(role)');

    await db.execute('''
      CREATE TABLE word_stats (
        word         TEXT PRIMARY KEY,
        ask_count    INTEGER NOT NULL DEFAULT 0,
        first_ask    INTEGER NOT NULL,
        last_ask     INTEGER NOT NULL,
        session_count INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // ─── Sessions ──────────────────────────────────────────────

  static Future<void> upsertSession({
    required String id,
    String title = '新会话',
    required int createdAt,
  }) async {
    await db.execute(
      'INSERT INTO chat_sessions (id, title, created_at, updated_at) '
      'VALUES (?, ?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET '
      '  title = COALESCE(excluded.title, chat_sessions.title), '
      '  updated_at = excluded.updated_at',
      [id, title, createdAt, createdAt],
    );
  }

  /// 全量重写后更新 message_count 和 updated_at
  static Future<void> updateSessionStats(
      String id, int messageCount, int timestamp) async {
    await db.update('chat_sessions',
        {'message_count': messageCount, 'updated_at': timestamp},
        where: 'id = ?',
        whereArgs: [id]);
  }

  static Future<void> updateSessionTitle(String id, String title) async {
    await db.update('chat_sessions', {'title': title},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateSessionTimestamp(String id, int timestamp) async {
    await db.update('chat_sessions', {'updated_at': timestamp},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getAllSessions() async {
    return db.query('chat_sessions',
        where: 'is_archived = 0', orderBy: 'updated_at DESC');
  }

  static Future<Map<String, dynamic>?> getSession(String id) async {
    final rows =
        await db.query('chat_sessions', where: 'id = ?', whereArgs: [id]);
    return rows.isNotEmpty ? rows.first : null;
  }

  static Future<void> archiveSession(String id) async {
    await db.update('chat_sessions', {'is_archived': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteSession(String id) async {
    await db.delete('chat_sessions', where: 'id = ?', whereArgs: [id]);
  }

  /// 清空某会话的所有消息（用于全量重写场景）
  static Future<void> deleteSessionMessages(String sessionId) async {
    await db.delete('chat_messages',
        where: 'session_id = ?', whereArgs: [sessionId]);
  }

  // ─── Messages ──────────────────────────────────────────────

  static Future<int> insertMessage({
    required String sessionId,
    required String role,
    required String content,
    String? wordsJson,
    required int createdAt,
  }) async {
    return db.insert('chat_messages', {
      'session_id': sessionId,
      'role': role,
      'content': content,
      'words_json': wordsJson,
      'created_at': createdAt,
    });
  }

  static Future<List<Map<String, dynamic>>> getMessages(
    String sessionId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return db.query('chat_messages',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'created_at ASC',
        limit: limit,
        offset: offset);
  }

  static Future<int> sessionMessageCount(String sessionId) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM chat_messages WHERE session_id = ?',
      [sessionId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── Word Stats ────────────────────────────────────────────

  static Future<void> upsertWordStats({
    required String word,
    required int timestamp,
  }) async {
    await db.execute(
      'INSERT INTO word_stats (word, ask_count, first_ask, last_ask, session_count) '
      'VALUES (?, 1, ?, ?, 1) '
      'ON CONFLICT(word) DO UPDATE SET '
      '  ask_count = ask_count + 1, '
      '  first_ask = MIN(first_ask, excluded.first_ask), '
      '  last_ask = MAX(last_ask, excluded.last_ask), '
      '  session_count = session_count + 1',
      [word, timestamp, timestamp],
    );
  }

  static Future<List<Map<String, dynamic>>> topWords({int limit = 20}) async {
    return db.query('word_stats',
        orderBy: 'ask_count DESC', limit: limit);
  }

  static Future<List<Map<String, dynamic>>> wordsSince(
      int timestampMs) async {
    return db.query('word_stats',
        where: 'last_ask >= ?',
        whereArgs: [timestampMs],
        orderBy: 'ask_count DESC');
  }

  // ─── Analysis ──────────────────────────────────────────────

  /// 用户提问单词频率（从 words_json 实时提取）
  static Future<List<Map<String, dynamic>>> userWordFrequency({
    int days = 30,
    int limit = 50,
  }) async {
    final since = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    return db.rawQuery(
      'SELECT value AS word, COUNT(*) AS cnt '
      'FROM chat_messages, json_each(chat_messages.words_json) '
      'WHERE chat_messages.role = ? AND chat_messages.created_at >= ? '
      'GROUP BY value ORDER BY cnt DESC LIMIT ?',
      ['user', since, limit],
    );
  }
}
