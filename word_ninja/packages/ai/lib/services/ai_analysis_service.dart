import 'package:core/storage/sqlite/chat_repository.dart';
import 'package:core/storage/sqlite/sqlite_init.dart';
import 'ai_chat_service.dart';

/// AI 学习分析服务 — 查询 SQLite 数据，喂给 LLM 生成洞察
class AiAnalysisService {
  final AiChatService _ai;

  AiAnalysisService(this._ai);

  ChatRepository get _repo => SqliteDb.repository;

  /// 生成学习分析报告
  Future<String> generateReport({int days = 30}) async {
    // 1. 收集数据
    final topWords = await _repo.userWordFrequency(days: days, limit: 30);
    final sessionCount = (await _repo.getAllSessions()).length;

    // 2. 构建 prompt
    final wordList = topWords
        .map((w) => '${w.word}(${w.count}次)')
        .join('、');

    final prompt = '''
你是英语学习分析专家。以下是用户近 $days 天的学习数据：

- 共 $sessionCount 个对话会话
- 高频询问词汇（按频率排序）：$wordList

请用友好的中文分析：
1. **学习偏好**：用户主要关注哪类词汇？（学术/日常/商务/考试等），从这些词汇判断
2. **学习瓶颈**：哪些词被反复提问，可能意味着用户记不住或理解不透
3. **重点推荐**：推荐 3-5 个用户应该重点掌握的词汇
4. **学习策略建议**：给用户 1-2 条具体的学习方法建议

用 Markdown 格式回复，控制在 300 字以内，语气轻松友好。''';

    return _ai.chat(message: prompt, systemPrompt: '你是友好的英语学习分析助手。');
  }

  /// 快速洞察：一句话总结
  Future<String> quickInsight() async {
    final tops = await _repo.topWords(limit: 5);
    if (tops.isEmpty) return '还没有足够的数据，快去跟 Sensei 聊聊天吧！';

    final prompt = '用户最近最常问的词是：${tops.map((w) => w.word).join('、')}。用一句话（15字以内）幽默地评价用户的学习偏好。';
    return _ai.chat(message: prompt, systemPrompt: '你是幽默的英语学习助手，回复极简。');
  }
}
