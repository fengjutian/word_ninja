import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_chat_service.dart';
import '../services/ai_word_service.dart';
import '../services/ai_reading_service.dart';
import '../services/ai_writing_service.dart';
import '../services/ai_plan_service.dart';

/// AI 聊天服务 Provider
final aiChatServiceProvider = Provider<AiChatService>((ref) {
  const apiKey = String.fromEnvironment('OPENAI_API_KEY');
  return AiChatService(apiKey);
});

/// AI 单词服务 Provider
final aiWordServiceProvider = Provider<AiWordService>((ref) {
  final chat = ref.watch(aiChatServiceProvider);
  return AiWordService(chat);
});

/// AI 阅读服务 Provider
final aiReadingServiceProvider = Provider<AiReadingService>((ref) {
  final chat = ref.watch(aiChatServiceProvider);
  return AiReadingService(chat);
});

/// AI 写作服务 Provider
final aiWritingServiceProvider = Provider<AiWritingService>((ref) {
  final chat = ref.watch(aiChatServiceProvider);
  return AiWritingService(chat);
});

/// AI 计划服务 Provider
final aiPlanServiceProvider = Provider<AiPlanService>((ref) {
  final chat = ref.watch(aiChatServiceProvider);
  return AiPlanService(chat);
});
