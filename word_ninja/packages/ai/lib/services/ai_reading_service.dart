import 'ai_chat_service.dart';

/// 阅读相关 AI 服务
class AiReadingService {
  final AiChatService _chat;

  AiReadingService(this._chat);

  /// 生成分级阅读文章
  Future<String> generateArticle({
    required String topic,
    required int level,
  }) async {
    final prompt = '''
请用英语写一篇关于 "$topic" 的短文。
难度等级：$level（1-5，1最简单）
长度：200-300词
在文后附上5个生词的中文注释。
''';
    return _chat.chat(message: prompt);
  }

  /// 解析选中文本
  Future<Map<String, dynamic>> analyzeSelection(String text) async {
    final prompt = '''
请分析以下英文文本，返回JSON格式：
{
  "translation": "中文翻译",
  "grammar_points": ["语法点1", "语法点2"],
  "key_vocabulary": [{"word": "单词", "meaning": "释义"}]
}
文本：$text
''';
    final response = await _chat.chat(message: prompt);
    final parsed = AiChatService.parseJsonMap(response, {
      'translation': '',
      'grammar_points': <String>[],
      'key_vocabulary': <Map<String, String>>[],
    });
    return {
      'translation': parsed['translation'] ?? '',
      'grammar_points': (parsed['grammar_points'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      'key_vocabulary': (parsed['key_vocabulary'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          <Map<String, String>>[],
    };
  }
}
