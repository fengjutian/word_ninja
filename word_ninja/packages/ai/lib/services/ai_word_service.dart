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
    final parsed = AiChatService.parseJsonMap(response, {
      'word': word,
      'phonetic': '',
      'meaning': '',
      'example': '',
      'difficulty': 1,
      'tags': <String>[],
    });
    return {
      'word': word,
      'phonetic': parsed['phonetic'] ?? '',
      'meaning': parsed['meaning'] ?? '',
      'example': parsed['example'] ?? '',
      'difficulty': parsed['difficulty'] ?? 1,
      'tags': (parsed['tags'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    };
  }

  /// 生成单词测试（选择题）
  Future<List<Map<String, dynamic>>> generateQuiz(List<String> words) async {
    if (words.isEmpty) return [];
    final wordList = words.join(', ');
    final prompt = '''
请为以下英语单词生成选择题测验，返回JSON数组格式：
[
  {
    "word": "单词",
    "question": "题目描述（中文）",
    "options": ["选项A", "选项B", "选项C", "选项D"],
    "correct_index": 0,
    "explanation": "解析（中文）"
  }
]
单词列表：$wordList
只返回JSON数组。
''';
    final response = await _chat.chat(message: prompt);
    final list = AiChatService.parseJsonList(response, []);
    return list.cast<Map<String, dynamic>>();
  }
}
