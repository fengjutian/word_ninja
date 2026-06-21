import 'ai_chat_service.dart';

/// 学习计划 AI 服务
class AiPlanService {
  final AiChatService _chat;

  AiPlanService(this._chat);

  /// 生成个性化学习计划
  Future<List<Map<String, dynamic>>> generatePlan({
    required String goal,
    required int dailyMinutes,
    required int currentLevel,
  }) async {
    final prompt = '''
用户目标：$goal
每日可学习时间：$dailyMinutes分钟
当前英语等级：$currentLevel级（1-100）

请生成一份7天的学习计划，返回JSON数组格式：
[
  {
    "day": 1,
    "tasks": [
      {"type": "vocabulary", "description": "学习20个单词", "duration_min": 15},
      {"type": "reading", "description": "阅读1篇文章", "duration_min": 20}
    ]
  }
]
''';
    final response = await _chat.chat(message: prompt);
    final list = AiChatService.parseJsonList(response, []);
    return list.cast<Map<String, dynamic>>();
  }
}
