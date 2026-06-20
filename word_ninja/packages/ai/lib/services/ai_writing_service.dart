import 'ai_chat_service.dart';

/// 写作相关 AI 服务
class AiWritingService {
  final AiChatService _chat;

  AiWritingService(this._chat);

  /// 生成范文
  Future<String> generateComposition(String topic) async {
    final prompt = '''
请写一篇关于 "$topic" 的英语短文。
要求：结构完整（开头-主体-结尾），用词丰富，长度200-300词。
''';
    return _chat.chat(message: prompt);
  }

  /// 批改作文
  Future<Map<String, dynamic>> correct(String text) async {
    final prompt = '''
请批改以下英语作文，返回JSON格式：
{
  "score": 百分制评分,
  "grammar_errors": [{"error": "错误", "correction": "改正", "explanation": "说明"}],
  "vocabulary_suggestions": [{"word": "原词", "suggestion": "建议替换"}],
  "overall_comment": "总体评价（中文）"
}
作文：
$text
''';
    return {
      'score': 0,
      'grammar_errors': <Map<String, String>>[],
      'vocabulary_suggestions': <Map<String, String>>[],
      'overall_comment': '',
    };
  }

  /// IELTS 评分
  Future<Map<String, dynamic>> ieltsScore(String text) async {
    return {
      'overall_band': 0.0,
      'task_achievement': 0.0,
      'coherence': 0.0,
      'lexical_resource': 0.0,
      'grammatical_range': 0.0,
    };
  }
}
