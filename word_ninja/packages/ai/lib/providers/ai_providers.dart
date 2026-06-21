import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_chat_service.dart';

/// AI 聊天服务 Provider（默认实现，app 层可 override）
final aiChatServiceProvider = Provider<AiChatService>((ref) {
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  return AiChatService(apiKey);
});
