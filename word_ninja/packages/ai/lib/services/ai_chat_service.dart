import 'package:dio/dio.dart';
import 'package:core/logger/logger.dart';

/// OpenAI Chat 服务
class AiChatService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.openai.com/v1',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  final String _apiKey;

  AiChatService(this._apiKey) {
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
  }

  /// 发送聊天消息
  Future<String> chat({
    required String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  }) async {
    final messages = <Map<String, dynamic>>[];
    if (systemPrompt != null) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    if (history != null) {
      messages.addAll(history);
    }
    messages.add({'role': 'user', 'content': message});

    try {
      final res = await _dio.post('/chat/completions', data: {
        'model': 'gpt-4o-mini',
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1000,
      });
      return res.data['choices'][0]['message']['content'] as String;
    } on DioException catch (e) {
      log.e('AI chat error', e);
      return '抱歉，AI 暂时无法回复。请稍后再试。';
    }
  }

  /// 单词解释
  Future<Map<String, String>> explainWord(String word) async {
    final prompt = '''
你是一个英语单词专家。请用 JSON 格式解释单词 "$word"，包含：
- meaning: 中文释义
- phonetic: 音标
- example: 一个例句（含中文翻译）
- collocations: 常用搭配（逗号分隔）
不要包含其他文字，只返回 JSON。
''';
    final response = await chat(message: prompt, systemPrompt: '你是一个英语教学助手。');
    // 简单解析 JSON
    try {
      final cleaned = response.trim().replaceAll(RegExp(r'^```json|```$'), '');
      // 这里可以用 jsonDecode
      return {'meaning': '', 'phonetic': '', 'example': '', 'collocations': ''};
    } catch (_) {
      return {'meaning': '解析失败', 'phonetic': '', 'example': '', 'collocations': ''};
    }
  }
}
