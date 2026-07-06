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

/// 聊天历史 Provider — 跨页面保持 + 磁盘持久化
class ChatHistoryNotifier extends StateNotifier<List<ChatMessage>> {
  static const _storageKey = 'ai_tutor_chat_history';
  static const _maxMessages = 200; // 最多保留 200 条
  bool _loaded = false;

  ChatHistoryNotifier() : super([_welcomeMessage]) {
    _load();
  }

  static const _welcomeMessage = ChatMessage(
    '你好！我是 Sensei Shell，你的英语忍者导师。\n有什么问题尽管问我！',
    isUser: false,
  );

  List<ChatMessage> _persistable() {
    return state.where((m) => !m.isLoading).toList();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        final loaded = list
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList();
        if (loaded.isNotEmpty) {
          state = loaded;
          _loaded = true;
          return;
        }
      }
    } catch (_) {}
    _loaded = true;
  }

  Future<void> _save() async {
    if (!_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _persistable();
      // 超出上限时裁剪旧的
      final toSave = data.length > _maxMessages
          ? data.sublist(data.length - _maxMessages)
          : data;
      await prefs.setString(_storageKey, jsonEncode(toSave));
    } catch (_) {}
  }

  void addMessage(ChatMessage msg) {
    state = [...state, msg];
    if (!msg.isLoading) _save();
  }

  void removeLast() {
    if (state.isEmpty) return;
    state = state.sublist(0, state.length - 1);
    _save();
  }

  void clear() {
    state = [_welcomeMessage];
    _save();
  }
}

final chatHistoryProvider =
    StateNotifierProvider<ChatHistoryNotifier, List<ChatMessage>>((ref) {
  return ChatHistoryNotifier();
});
