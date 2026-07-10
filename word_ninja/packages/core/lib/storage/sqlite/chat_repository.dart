/// 会话数据模型（与存储无关）
class SessionData {
  final String id;
  final String title;
  final int createdAt;
  final int updatedAt;
  final int messageCount;
  final bool isArchived;

  const SessionData({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.isArchived = false,
  });
}

/// 消息数据模型（与存储无关）
class MessageData {
  final int? id;
  final String sessionId;
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final List<String>? words;
  final int createdAt;

  const MessageData({
    this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.words,
    required this.createdAt,
  });
}

/// 单词频率统计
class WordFrequency {
  final String word;
  final int count;

  const WordFrequency({required this.word, required this.count});
}

/// 对话存储抽象接口
/// 实现者：SqliteChatRepository（本地）、RemoteChatRepository（服务端同步-未来）
abstract class ChatRepository {
  // ─── Sessions ──────────────────────────────────────────────

  Future<void> upsertSession({
    required String id,
    String title,
    required int createdAt,
  });

  Future<void> updateSessionTitle(String id, String title);
  Future<void> updateSessionTimestamp(String id, int timestamp);
  Future<List<SessionData>> getAllSessions();
  Future<SessionData?> getSession(String id);
  Future<void> archiveSession(String id);
  Future<void> deleteSession(String id);
  Future<void> clearSessionMessages(String sessionId);
  Future<void> updateSessionStats(String id, int messageCount, int timestamp);

  // ─── Messages ──────────────────────────────────────────────

  Future<int> insertMessage(MessageData message);
  Future<List<MessageData>> getMessages(String sessionId,
      {int limit = 50, int offset = 0});
  Future<int> sessionMessageCount(String sessionId);

  // ─── Word Stats ────────────────────────────────────────────

  Future<void> upsertWordStats({required String word, required int timestamp});
  Future<List<WordFrequency>> topWords({int limit = 20});
  Future<List<WordFrequency>> wordsSince(int timestampMs);
  Future<List<WordFrequency>> userWordFrequency({int days = 30, int limit = 50});
}
