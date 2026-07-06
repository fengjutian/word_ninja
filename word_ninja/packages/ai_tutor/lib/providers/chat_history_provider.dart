import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 聊天消息模型
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

/// 会话模型
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

/// 会话列表 + 当前会话
class ChatSessionsState {
  final List<ChatSession> sessions;
  final int currentIndex;

  const ChatSessionsState({
    required this.sessions,
    required this.currentIndex,
  });

  ChatSession get current => sessions[currentIndex];
}

/// 多会话管理 Provider
class ChatHistoryNotifier extends StateNotifier<ChatSessionsState> {
  static const _storageKey = 'ai_tutor_sessions';
  static const _maxMessages = 200;

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

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final sessions = (data['sessions'] as List<dynamic>)
            .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
            .toList();
        final idx = data['currentIndex'] as int? ?? 0;
        if (sessions.isNotEmpty) {
          state = ChatSessionsState(
            sessions: sessions,
            currentIndex: idx.clamp(0, sessions.length - 1),
          );
          return;
        }
      }
      // 迁移旧版单会话数据
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
          state = ChatSessionsState(sessions: [s], currentIndex: 0);
          await prefs.remove('ai_tutor_chat_history'); // 清除旧数据
          _save();
          return;
        }
      }
    } catch (_) {}
    final s = _newSession('default');
    state = ChatSessionsState(sessions: [s], currentIndex: 0);
    _save();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 只保存非 loading 消息，裁剪超量
      final sessions = state.sessions.map((s) {
        var msgs = s.messages.where((m) => !m.isLoading).toList();
        if (msgs.length > _maxMessages) {
          msgs = msgs.sublist(msgs.length - _maxMessages);
        }
        return ChatSession(
          id: s.id,
          title: s.title,
          messages: msgs,
          createdAt: s.createdAt,
        );
      }).toList();
      await prefs.setString(
        _storageKey,
        jsonEncode({
          'sessions': sessions.map((s) => s.toJson()).toList(),
          'currentIndex': state.currentIndex,
        }),
      );
    } catch (_) {}
  }

  void addMessage(ChatMessage msg) {
    final sessions = List<ChatSession>.from(state.sessions);
    final cur = sessions[state.currentIndex];
    final newMsgs = [...cur.messages, msg];
    // 首条用户消息作为会话标题
    var title = cur.title;
    if (title == '新会话' && msg.isUser) {
      title = msg.text.length > 30 ? '${msg.text.substring(0, 30)}...' : msg.text;
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
    if (!msg.isLoading) _save();
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
    _save();
  }

  void newSession() {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final s = _newSession(id);
    state = ChatSessionsState(
      sessions: [...state.sessions, s],
      currentIndex: state.sessions.length,
    );
    _save();
  }

  void switchToSession(int index) {
    if (index >= 0 && index < state.sessions.length) {
      state = ChatSessionsState(
        sessions: state.sessions,
        currentIndex: index,
      );
      _save();
    }
  }

  void deleteSession(int index) {
    if (state.sessions.length <= 1) return;
    final sessions = List<ChatSession>.from(state.sessions);
    sessions.removeAt(index);
    final newIdx = state.currentIndex >= sessions.length
        ? sessions.length - 1
        : state.currentIndex;
    state = ChatSessionsState(
      sessions: sessions,
      currentIndex: newIdx,
    );
    _save();
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
