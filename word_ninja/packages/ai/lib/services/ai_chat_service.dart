import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:core/logger/logger.dart';
import '../config/model_config.dart';

/// OpenAI / DeepSeek Chat 服务
class AiChatService {
  final Dio _dio;
  final String _apiKey;
  final String _modelName;
  final double _temperature;
  final int _maxTokens;

  AiChatService(this._apiKey, {ModelConfig? config})
      : _modelName = config?.modelName ?? 'gpt-4o-mini',
        _temperature = config?.temperature ?? 0.7,
        _maxTokens = config?.maxTokens ?? 1000,
        _dio = Dio(BaseOptions(
          baseUrl: config?.baseUrl ?? 'https://api.openai.com/v1',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        )) {
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
        'model': _modelName,
        'messages': messages,
        'temperature': _temperature,
        'max_tokens': _maxTokens,
      });
      return res.data['choices'][0]['message']['content'] as String;
    } on DioException catch (e) {
      log.e('AI chat error', e);
      return '抱歉，AI 暂时无法回复。请稍后再试。';
    }
  }

  /// 单词解释
  Future<Map<String, dynamic>> explainWord(String word) async {
    final prompt = '''
你是一个英语单词专家。请用 JSON 格式解释单词 "$word"，包含：
- meaning: 中文释义
- phonetic: 音标
- example: 一个例句（含中文翻译）
- collocations: 常用搭配（逗号分隔）
不要包含其他文字，只返回 JSON。
''';
    final response = await chat(message: prompt, systemPrompt: '你是一个英语教学助手。');
    return parseJsonMap(response, {
      'meaning': '解析失败',
      'phonetic': '',
      'example': '',
      'collocations': '',
    });
  }

  // ─── JSON 解析工具 ───

  /// 从 AI 返回文本中提取 JSON Map
  static Map<String, dynamic> parseJsonMap(String text, Map<String, dynamic> fallback) {
    try {
      final jsonStr = _extractJson(text);
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) return decoded;
      return fallback;
    } catch (e) {
      log.w('AI JSON parse failed: $e');
      return fallback;
    }
  }

  /// 从 AI 返回文本中提取 JSON List
  static List<dynamic> parseJsonList(String text, List<dynamic> fallback) {
    try {
      final jsonStr = _extractJson(text);
      final decoded = jsonDecode(jsonStr);
      if (decoded is List) return decoded;
      return fallback;
    } catch (e) {
      log.w('AI JSON parse failed: $e');
      return fallback;
    }
  }

  /// 从文本中提取 JSON 部分（处理 markdown 代码块包裹）
  static String _extractJson(String text) {
    // 尝试匹配 ```json ... ``` 代码块
    final blockMatch = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(text);
    if (blockMatch != null) return blockMatch.group(1)!.trim();

    // 尝试匹配 { ... } 或 [ ... ] 最外层
    final braceMatch = RegExp(r'(\{[\s\S]*\}|\[[\s\S]*\])').firstMatch(text);
    if (braceMatch != null) return braceMatch.group(1)!.trim();

    return text.trim();
  }
}
