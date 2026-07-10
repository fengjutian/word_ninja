import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core/logger/logger.dart';
import 'package:core/storage/sqlite/sqlite_init.dart';
import 'package:core/storage/sqlite/chat_repository.dart';

/// 聊天消息模型（公开 API 不变）
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;
  final bool isError;

  const ChatMessage(
    this.text, {
    required this.isUser,
    this.isLoading = false,
    this.isError = false,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        json['text'] as String,
        isUser: json['isUser'] as bool,
      );
}

/// 会话模型（公开 API 不变）
class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final int createdAt;

  const ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt,
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        title: json['title'] as String? ?? '新会话',
        messages: (json['messages'] as List<dynamic>)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] as int? ?? 0,
      );
}

/// 会话列表 + 当前会话（公开 API 不变）
class ChatSessionsState {
  final List<ChatSession> sessions;
  final int currentIndex;

  const ChatSessionsState({
    required this.sessions,
    required this.currentIndex,
  });

  ChatSession get current => sessions[currentIndex];
}

/// 英语单词提取 — 过滤常见停用词
const _stopWords = {
  'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can',
  'her', 'was', 'one', 'our', 'out', 'has', 'have', 'been', 'some',
  'how', 'who', 'what', 'when', 'where', 'which', 'why', 'will',
  'with', 'from', 'this', 'that', 'than', 'then', 'them', 'they',
  'into', 'just', 'like', 'make', 'more', 'much', 'over', 'such',
  'take', 'very', 'your', 'also', 'does', 'said', 'know', 'think',
  'mean', 'means', 'about', 'after', 'before', 'could', 'other',
  'these', 'those', 'would', 'their', 'there', 'being', 'doing',
  'hello', 'thanks', 'please', 'really', 'right', 'still', 'thing',
  'word', 'words', 'english', 'language', 'using', 'people', 'many',
  'each', 'every', 'well', 'way', 'even', 'too', 'its', 'get', 'got',
  'had', 'did', 'say', 'use', 'used', 'good', 'need', 'help', 'any',
  'yes', 'ask', 'see', 'let', 'hi', 'hey',
};

List<String> _extractWords(String text) {
  final matches =
      RegExp(r'[a-zA-Z]{4,}(?:-[a-zA-Z]+)*').allMatches(text.toLowerCase());
  final seen = <String>{};
  final words = <String>[];
  for (final m in matches) {
    final w = m.group(0)!;
    if (!_stopWords.contains(w) && seen.add(w)) {
      words.add(w);
    }
  }
  return words;
}

/// 多会话管理 Provider
class ChatHistoryNotifier extends StateNotifier<ChatSessionsState> {
  static const _migrationDoneKey = 'ai_tutor_sqlite_migrated';
  bool _loaded = false;

  ChatHistoryNotifier()
      : super(const ChatSessionsState(sessions: [], currentIndex: 0)) {
    _load();
  }

  static ChatSession _newSession(String id, {String title = '新会话'}) {
    return ChatSession(
      id: id,
      title: title,
      messages: const [
        ChatMessage(
          '你好！我是 Sensei Shell，你的英语忍者导师。\n有什么问题尽管问我！',
          isUser: false,
        ),
      ],
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<ChatMessage> get messages => state.current.messages;

  // ─── 加载：SQLite 优先，回退迁移 ─────────────────────

  Future<void> _load() async {
    try {
      final repo = SqliteDb.repository;
      final sessions = await repo.getAllSessions();
      if (sessions.isNotEmpty) {
        final chatSessions = <ChatSession>[];
        for (final s in sessions) {
          final msgs = await repo.getMessages(s.id);
          chatSessions.add(ChatSession(
            id: s.id,
            title: s.title,
            messages: msgs
                .map((m) => ChatMessage(
                      m.content,
                      isUser: m.role == 'user',
                    ))
                .toList(),
            createdAt: s.createdAt,
          ));
        }
        state = ChatSessionsState(
          sessions: chatSessions,
          currentIndex: 0,
        );
        _loaded = true;
        return;
      }
    } catch (e) {
      log.w('SQLite load failed, trying migration', e);
    }

    // SQLite 为空 → 尝试从 SharedPreferences 迁移
    await _migrateFromSharedPreferences();
  }

  // ─── SharedPreferences → SQLite 迁移 ─────────────────

  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 检查是否已经迁移过
      if (prefs.getBool(_migrationDoneKey) == true) {
        // 已迁移，但 SQLite 为空 → 创建默认会话
        final s = _newSession('default');
        state = ChatSessionsState(sessions: [s], currentIndex: 0);
        _loaded = true;
        await _saveSessionToDb(s);
        return;
      }

      // 尝试读取新版多会话数据
      final jsonStr = prefs.getString('ai_tutor_sessions');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final sessionsJson =
            data['sessions'] as List<dynamic>;
        if (sessionsJson.isNotEmpty) {
          for (final sj in sessionsJson) {
            final s =
                ChatSession.fromJson(sj as Map<String, dynamic>);
            await _saveSessionToDb(s);
          }
          state = _buildStateFromJson(data);
          _loaded = true;
          await prefs.setBool(_migrationDoneKey, true);
          await prefs.remove('ai_tutor_sessions');
          await prefs.remove('ai_tutor_chat_history');
          log.i('Migrated ${sessionsJson.length} sessions to SQLite');
          return;
        }
      }

      // 尝试迁移旧版单会话数据
      final oldJson = prefs.getString('ai_tutor_chat_history');
      if (oldJson != null && oldJson.isNotEmpty) {
        final list = jsonDecode(oldJson) as List<dynamic>;
        final oldMessages = list
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        if (oldMessages.isNotEmpty) {
          final s = ChatSession(
            id: 'default',
            title: '历史会话',
            messages: oldMessages,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          );
          await _saveSessionToDb(s);
          state = ChatSessionsState(sessions: [s], currentIndex: 0);
          _loaded = true;
          await prefs.setBool(_migrationDoneKey, true);
          await prefs.remove('ai_tutor_sessions');
          await prefs.remove('ai_tutor_chat_history');
          log.i('Migrated old single-session data to SQLite');
          return;
        }
      }

      await prefs.setBool(_migrationDoneKey, true);
    } catch (e) {
      log.w('SharedPreferences migration failed', e);
    }

    // 兜底：新用户，没有旧数据
    final s = _newSession('default');
    state = ChatSessionsState(sessions: [s], currentIndex: 0);
    _loaded = true;
    try {
      await _saveSessionToDb(s);
    } catch (e) {
      log.w('Failed to save initial session to SQLite', e);
    }
  }

  ChatSessionsState _buildStateFromJson(Map<String, dynamic> data) {
    final sessions = (data['sessions'] as List<dynamic>)
        .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
        .toList();
    final idx = data['currentIndex'] as int? ?? 0;
    return ChatSessionsState(
      sessions: sessions,
      currentIndex: idx.clamp(0, sessions.length - 1),
    );
  }

  // ─── 持久化到 SQLite ─────────────────────────────────

  Future<void> _saveSessionToDb(ChatSession session) async {
    final repo = SqliteDb.repository;
    final now = DateTime.now().millisecondsSinceEpoch;

    await repo.upsertSession(
      id: session.id,
      title: session.title,
      createdAt: session.createdAt,
    );

    // 清空该会话旧消息再重写（避免 duplicate）
    await repo.clearSessionMessages(session.id);

    final realMessages = session.messages.where((m) => !m.isLoading).toList();
    for (final msg in realMessages) {
      final role = msg.isUser ? 'user' : 'assistant';
      final words = msg.isUser ? _extractWords(msg.text) : null;

      await repo.insertMessage(MessageData(
        sessionId: session.id,
        role: role,
        content: msg.text,
        words: words,
        createdAt: now,
      ));

      if (words != null) {
        for (final w in words) {
          await repo.upsertWordStats(word: w, timestamp: now);
        }
      }
    }

    // 更新 message_count 和 updated_at
    await repo.updateSessionStats(session.id, realMessages.length, now);
  }

  /// 单条保存用户消息到 SQLite（实时写入）
  Future<void> _saveMessage(ChatMessage msg, String sessionId) async {
    if (msg.isLoading) return;
    try {
      final repo = SqliteDb.repository;
      final role = msg.isUser ? 'user' : 'assistant';
      final words = msg.isUser ? _extractWords(msg.text) : null;
      final now = DateTime.now().millisecondsSinceEpoch;

      await repo.insertMessage(MessageData(
        sessionId: sessionId,
        role: role,
        content: msg.text,
        words: words,
        createdAt: now,
      ));

      if (words != null) {
        for (final w in words) {
          await repo.upsertWordStats(word: w, timestamp: now);
        }
      }
    } catch (e) {
      log.w('Save message to SQLite failed', e);
    }
  }

  // ─── 公开方法（API 完全不变）─────────────────────────

  void addMessage(ChatMessage msg) {
    if (!_loaded) return;
    final sessions = List<ChatSession>.from(state.sessions);
    final cur = sessions[state.currentIndex];
    final newMsgs = [...cur.messages, msg];
    var title = cur.title;
    if (title == '新会话' && msg.isUser) {
      title = msg.text.length > 30
          ? '${msg.text.substring(0, 30)}...'
          : msg.text;
    }
    sessions[state.currentIndex] = ChatSession(
      id: cur.id,
      title: title,
      messages: newMsgs,
      createdAt: cur.createdAt,
    );
    state = ChatSessionsState(
      sessions: sessions,
      currentIndex: state.currentIndex,
    );
    // 非 loading 消息：实时写入 SQLite
    if (!msg.isLoading) {
      _saveMessage(msg, cur.id);
      // 刷新会话排序
      try {
        SqliteDb.repository.updateSessionTimestamp(
            cur.id, DateTime.now().millisecondsSinceEpoch);
      } catch (_) {}
      // 标题变化时更新
      if (title != cur.title) {
        try {
          SqliteDb.repository.updateSessionTitle(cur.id, title);
        } catch (_) {}
      }
    }
  }

  /// 追加文本到最后一个消息（流式输出用）
  void appendToLastMessage(String chunk) {
    final sessions = List<ChatSession>.from(state.sessions);
    final cur = sessions[state.currentIndex];
    if (cur.messages.isEmpty) return;
    final allMsgs = [...cur.messages];
    final last = allMsgs.removeLast();
    final updated = ChatMessage(
        last.text + chunk, isUser: last.isUser, isError: last.isError);
    sessions[state.currentIndex] = ChatSession(
      id: cur.id,
      title: cur.title,
      messages: [...allMsgs, updated],
      createdAt: cur.createdAt,
    );
    state = ChatSessionsState(
      sessions: sessions,
      currentIndex: state.currentIndex,
    );
  }

  /// 流式结束后：保存最后一条完整消息到 SQLite
  void finishStream() {
    final cur = state.current;
    if (cur.messages.isNotEmpty) {
      final last = cur.messages.last;
      if (!last.isLoading) {
        _saveMessage(last, cur.id);
      }
    }
  }

  /// 删除指定索引的消息
  void deleteAt(int index) {
    final sessions = List<ChatSession>.from(state.sessions);
    final cur = sessions[state.currentIndex];
    if (index < 0 || index >= cur.messages.length) return;
    final msgs = [...cur.messages];
    final target = msgs[index];
    msgs.removeAt(index);
    if (target.isUser && index < msgs.length && !msgs[index].isUser) {
      msgs.removeAt(index);
    }
    sessions[state.currentIndex] = ChatSession(
      id: cur.id,
      title: cur.title,
      messages: msgs,
      createdAt: cur.createdAt,
    );
    state = ChatSessionsState(
      sessions: sessions,
      currentIndex: state.currentIndex,
    );
    // 删除后全量重写 session 到 SQLite
    _saveSessionToDb(sessions[state.currentIndex]);
  }

  void removeLast() {
    final sessions = List<ChatSession>.from(state.sessions);
    final cur = sessions[state.currentIndex];
    if (cur.messages.isEmpty) return;
    sessions[state.currentIndex] = ChatSession(
      id: cur.id,
      title: cur.title,
      messages: cur.messages.sublist(0, cur.messages.length - 1),
      createdAt: cur.createdAt,
    );
    state = ChatSessionsState(
      sessions: sessions,
      currentIndex: state.currentIndex,
    );
    _saveSessionToDb(sessions[state.currentIndex]);
  }

  void newSession() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final s = _newSession(id);
    state = ChatSessionsState(
      sessions: [...state.sessions, s],
      currentIndex: state.sessions.length,
    );
    _saveSessionToDb(s);
  }

  void switchToSession(int index) {
    if (index >= 0 && index < state.sessions.length) {
      state = ChatSessionsState(
        sessions: state.sessions,
        currentIndex: index,
      );
      try {
        SqliteDb.repository.updateSessionTimestamp(
          state.current.id,
          DateTime.now().millisecondsSinceEpoch,
        );
      } catch (_) {}
    }
  }

  void deleteSession(int index) {
    if (state.sessions.length <= 1) return;
    final sessions = List<ChatSession>.from(state.sessions);
    final removed = sessions.removeAt(index);
    final newIdx = state.currentIndex >= sessions.length
        ? sessions.length - 1
        : state.currentIndex;
    state = ChatSessionsState(
      sessions: sessions,
      currentIndex: newIdx,
    );
    try {
      SqliteDb.repository.deleteSession(removed.id);
    } catch (_) {}
  }
}

final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryNotifier, ChatSessionsState>((ref) {
  return ChatHistoryNotifier();
});

/// 便捷访问当前消息列表
final currentMessagesProvider = Provider<List<ChatMessage>>((ref) {
  return ref.watch(chatHistoryProvider).current.messages;
});
