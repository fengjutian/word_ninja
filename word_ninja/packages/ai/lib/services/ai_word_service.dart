import 'ai_chat_service.dart';

/// 单词相关 AI 服务
class AiWordService {
  final AiChatService _chat;

  AiWordService(this._chat);

  /// AI 补全单词信息
  Future<Map<String, dynamic>> completeWord(String word) async {
    final prompt = '''
请为英语单词 "$word" 提供以下信息（JSON格式）：
{
  "phonetic": "音标",
  "meaning": "中文释义",
  "example": "例句（含中文翻译）",
  "difficulty": 难度等级1-5,
  "tags": ["标签1", "标签2"]
}
只返回 JSON。
''';
    final response = await _chat.chat(message: prompt);
    // 实际项目中用 jsonDecode
    return {
      'word': word,
      'phonetic': '',
      'meaning': '',
      'example': '',
      'difficulty': 1,
      'tags': <String>[],
    };
  }

  /// 生成单词测试
  Future<List<Map<String, dynamic>>> generateQuiz(List<String> words) async {
    // TODO 生成选择题/填空题
    return [];
  }
}
