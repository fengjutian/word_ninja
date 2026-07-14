import 'package:core/logger/logger.dart';

/// AI 标记的焦点词 — 需要重点强化学习的词汇
class FocusWord {
  /// 单词本身
  final String word;

  /// AI 给出的推荐原因
  final String reason;

  /// 重要性评分（0-100），由 AI 估计
  final int score;

  const FocusWord({
    required this.word,
    required this.reason,
    this.score = 50,
  });

  factory FocusWord.fromJson(Map<String, dynamic> json) {
    final word = json['word'] as String? ?? '';
    if (word.isEmpty) {
      log.w('FocusWord.fromJson: empty word field');
    }
    return FocusWord(
      word: word,
      reason: json['reason'] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'reason': reason,
        'score': score,
      };

  @override
  String toString() => 'FocusWord($word, score=$score)';
}
