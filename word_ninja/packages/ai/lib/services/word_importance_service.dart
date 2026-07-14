import 'package:core/storage/sqlite/chat_repository.dart';
import 'package:core/storage/sqlite/sqlite_init.dart';

/// 单词重要性评分服务 — 综合多维度信号计算每词的强化学习优先级
///
/// 评分因子（归一化到 0-100）：
/// - 查询频率（来自 AI 对话中用户对单词的查询次数）
/// - 难度系数（词汇本身的 1-5 难度评级）
/// - 掌握度倒数（低掌握 = 更需要复习）
/// - 逾期紧急性（超过预定复习日期越久越紧急）
class WordImportanceService {
  final ChatRepository _chatRepo;

  WordImportanceService({ChatRepository? chatRepo})
      : _chatRepo = chatRepo ?? SqliteDb.repository;

  // ─── 权重配置 ──────────────────────────────────────────────

  /// 查询频率权重（高频词更应重点学）
  static const double _freqWeight = 0.30;

  /// 难度权重（高难度词需要更多关注）
  static const double _difficultyWeight = 0.20;

  /// 掌握度倒数权重（没掌握的才是重点）
  static const double _masteryInverseWeight = 0.35;

  /// 逾期紧急性权重（拖得越久越危险）
  static const double _urgencyWeight = 0.15;

  // ─── 公开 API ──────────────────────────────────────────────

  /// 批量加载词汇重要性分数
  ///
  /// [words]：单词原文列表
  /// [difficultyMap]：word → difficulty (1-5)，缺失默认为 1
  /// [masteryMap]：word → mastery (0-100)，缺失默认为 0
  Future<Map<String, int>> batchImportanceScores(
    List<String> words, {
    int days = 30,
    Map<String, int> difficultyMap = const {},
    Map<String, int> masteryMap = const {},
  }) async {
    final freqList = await _chatRepo.userWordFrequency(days: days, limit: 200);
    final freqMap = <String, int>{};
    for (final f in freqList) {
      freqMap[f.word.toLowerCase()] = f.count;
    }

    final maxFreq =
        freqMap.values.fold<int>(1, (a, b) => a > b ? a : b);

    final scores = <String, int>{};
    for (final w in words) {
      final freq = freqMap[w.toLowerCase()] ?? 0;
      final diff = difficultyMap[w] ?? difficultyMap[w.toLowerCase()] ?? 1;
      final mast = masteryMap[w] ?? masteryMap[w.toLowerCase()] ?? 0;
      // daysOverdue cannot be passed per-word here, default to 0
      scores[w] = _computeRawScore(freq, maxFreq,
          difficulty: diff, mastery: mast, daysOverdue: 0);
    }
    return scores;
  }

  /// 计算单个单词的重要性得分（0-100）
  ///
  /// 需要提供：
  /// - [queryFrequency]：该词在对话中被查询的次数
  /// - [maxFrequency]：全局最高查询次数（用于归一化）
  /// - [difficulty]：1-5 难度评级
  /// - [mastery]：0-100 当前掌握度
  /// - [daysOverdue]：超过复习日期的天数（0 表示未逾期）
  int computeImportance({
    required int queryFrequency,
    required int maxFrequency,
    required int difficulty,
    required int mastery,
    int daysOverdue = 0,
  }) {
    return _computeRawScore(
      queryFrequency,
      maxFrequency,
      difficulty: difficulty,
      mastery: mastery,
      daysOverdue: daysOverdue,
    );
  }

  // ─── 内部实现 ──────────────────────────────────────────────

  int _computeRawScore(
    int queryFrequency,
    int maxFrequency, {
    required int difficulty,
    required int mastery,
    int daysOverdue = 0,
  }) {
    // 1. 查询频率得分（归一化到 0-100，min 归一化：log 压缩避免极端值）
    final freqScore = maxFrequency > 0
        ? ((queryFrequency / maxFrequency) * 100).clamp(0, 100).toInt()
        : 0;

    // 2. 难度得分：1→20, 3→60, 5→100
    final difficultyScore = (difficulty * 20).clamp(0, 100);

    // 3. 掌握度倒数：mastery 0→100, mastery 100→0
    final masteryInverse = (100 - mastery).clamp(0, 100);

    // 4. 逾期紧急性：每逾期 1 天 +3 分，封顶 100
    final urgencyScore = (daysOverdue * 3).clamp(0, 100);

    // 加权求和
    final raw = freqScore * _freqWeight +
        difficultyScore * _difficultyWeight +
        masteryInverse * _masteryInverseWeight +
        urgencyScore * _urgencyWeight;

    return raw.round().clamp(0, 100);
  }
}
