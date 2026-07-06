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

  /// 流式聊天 — 逐字返回
  /// 普通聊天（非流式）
  Future<String> chat({
    required String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  }) async {
    final messages = <Map<String, dynamic>>[];
    if (systemPrompt != null) messages.add({'role': 'system', 'content': systemPrompt});
    if (history != null) messages.addAll(history);
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
      log.e('AI chat error: status=${e.response?.statusCode}, message=${e.message}');
      log.e('  Request URL: ${_dio.options.baseUrl}/chat/completions');
      log.e('  Model: $_modelName, Key length: ${_apiKey.length}');
      return _dioErrorToUserMessage(e);
    }
  }

  /// 流式聊天 — 逐字返回
  Stream<String> chatStream({
    required String message,
    String? systemPrompt,
    List<Map<String, String>>? history,
  }) async* {
    final messages = <Map<String, dynamic>>[];
    if (systemPrompt != null) messages.add({'role': 'system', 'content': systemPrompt});
    if (history != null) messages.addAll(history);
    messages.add({'role': 'user', 'content': message});
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': _modelName,
          'messages': messages,
          'temperature': _temperature,
          'max_tokens': _maxTokens,
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );
      final body = response.data as ResponseBody;
      String buffer = '';
      await for (final chunk in body.stream) {
        buffer += utf8.decode(chunk);
        while (buffer.contains('\n')) {
          final newlineIdx = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIdx).trim();
          buffer = buffer.substring(newlineIdx + 1);
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') continue;
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              final delta = json['choices']?[0]?['delta']?['content'];
              if (delta is String && delta.isNotEmpty) yield delta;
            } catch (_) {}
          }
        }
      }
    } on DioException catch (e) {
      log.e('AI stream error: status=${e.response?.statusCode}, message=${e.message}');
      log.e('  Request URL: ${_dio.options.baseUrl}/chat/completions');
      log.e('  Model: $_modelName, Key length: ${_apiKey.length}');
      yield _dioErrorToUserMessage(e);
    }
  }

  /// 将 Dio 异常转为用户可读的错误信息
  String _dioErrorToUserMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络或更换 Base URL。';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试。';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络。';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) {
          return 'API Key 无效或已过期，请检查密钥。';
        } else if (code == 429) {
          return '请求过于频繁，请稍后重试。';
        } else if (code == 404) {
          return 'API 端点不存在，请检查 Base URL。';
        } else if (code != null && code >= 500) {
          return 'AI 服务器异常($code)，请稍后重试。';
        }
        return '请求失败($code)，请检查模型配置。';
      case DioExceptionType.cancel:
        return '请求已取消。';
      default:
        return '抱歉，AI 暂时无法回复。${e.message ?? ""}';
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
