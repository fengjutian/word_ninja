part of 'chat_history_provider.dart';

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
