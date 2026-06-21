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
只返回JSON。
''';
    final response = await _chat.chat(message: prompt);
    final parsed = AiChatService.parseJsonMap(response, {
      'score': 0,
      'grammar_errors': <Map<String, String>>[],
      'vocabulary_suggestions': <Map<String, String>>[],
      'overall_comment': '',
    });
    return {
      'score': parsed['score'] ?? 0,
      'grammar_errors': (parsed['grammar_errors'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          <Map<String, String>>[],
      'vocabulary_suggestions': (parsed['vocabulary_suggestions'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          <Map<String, String>>[],
      'overall_comment': parsed['overall_comment'] ?? '',
    };
  }

  /// IELTS 评分
  Future<Map<String, dynamic>> ieltsScore(String text) async {
    final prompt = '''
请按照雅思写作评分标准批改以下英语作文，返回JSON格式：
{
  "overall_band": 总分（如6.5）,
  "task_achievement": 任务完成度（0-9）,
  "coherence": 连贯与衔接（0-9）,
  "lexical_resource": 词汇资源（0-9）,
  "grammatical_range": 语法范围与准确性（0-9）,
  "comment": "总体评价（中文）"
}
作文：
$text
只返回JSON。
''';
    final response = await _chat.chat(message: prompt);
    final parsed = AiChatService.parseJsonMap(response, {
      'overall_band': 0.0,
      'task_achievement': 0.0,
      'coherence': 0.0,
      'lexical_resource': 0.0,
      'grammatical_range': 0.0,
      'comment': '',
    });
    return {
      'overall_band': (parsed['overall_band'] as num?)?.toDouble() ?? 0.0,
      'task_achievement': (parsed['task_achievement'] as num?)?.toDouble() ?? 0.0,
      'coherence': (parsed['coherence'] as num?)?.toDouble() ?? 0.0,
      'lexical_resource': (parsed['lexical_resource'] as num?)?.toDouble() ?? 0.0,
      'grammatical_range': (parsed['grammatical_range'] as num?)?.toDouble() ?? 0.0,
      'comment': parsed['comment'] ?? '',
    };
  }
}
