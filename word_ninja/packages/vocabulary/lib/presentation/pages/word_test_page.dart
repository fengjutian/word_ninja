import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import '../../data/model/word.dart';
import '../providers/word_provider.dart';

/// 单词测试页 — 选择题模式
class WordTestPage extends ConsumerStatefulWidget {
  final List<Word> words;

  const WordTestPage({super.key, required this.words});

  @override
  ConsumerState<WordTestPage> createState() => _WordTestPageState();
}

class _WordTestPageState extends ConsumerState<WordTestPage> {
  int _currentIndex = 0;
  int _correctCount = 0;
  int _totalAnswered = 0;
  String? _selectedAnswer;
  bool _showResult = false;
  late List<_TestQuestion> _questions;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuestions(widget.words);
  }

  List<_TestQuestion> _generateQuestions(List<Word> words) {
    if (words.length < 2) return [];
    return words.map((word) {
      final options = <String>{word.meaning};
      final others = words
          .where((w) => w.id != word.id)
          .toList()
        ..shuffle();
      for (var i = 0; i < 3 && i < others.length; i++) {
        options.add(others[i].meaning);
      }
      final optionList = options.toList()..shuffle();
      return _TestQuestion(
        word: word.word,
        wordId: word.id,
        correctAnswer: word.meaning,
        options: optionList,
      );
    }).toList();
  }

  void _selectAnswer(String answer) {
    if (_showResult) return;
    final question = _questions[_currentIndex];
    final isCorrect = answer == question.correctAnswer;
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _totalAnswered++;
      if (isCorrect) _correctCount++;
    });
    // 提交复习记录
    _submitReview(question.wordId, isCorrect ? 5 : 1);
  }

  Future<void> _submitReview(String wordId, int score) async {
    try {
      await ref.read(vocabularyRepositoryProvider).submitReview(wordId, score);
    } catch (_) {
      // 静默失败，不影响测验体验
    }
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    } else {
      _showSummary();
    }
  }

  Future<void> _saveResults() async {
    // 将测试结果持久化
    setState(() => _isSaving = true);
    try {
      final stats = await ref.read(vocabularyRepositoryProvider).getStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已同步 · 总词汇 ${stats.totalWords} · 掌握 ${stats.masteredWords}')),
        );
      }
    } catch (_) {
      // 静默失败
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSummary() {
    _saveResults();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('测试完成！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_correctCount / $_totalAnswered',
              style: NinjaTextStyles.displayLarge.copyWith(
                color: _correctCount >= _totalAnswered * 0.8
                    ? NinjaColors.success
                    : NinjaColors.warning,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _correctCount >= _totalAnswered * 0.8 ? '太棒了！继续加油！' : '再接再厉！',
              style: NinjaTextStyles.bodyLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('单词测试')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.quiz, size: 64, color: NinjaColors.textSecondary),
              SizedBox(height: 16),
              Text('需要至少 2 个单词才能开始测试', style: NinjaTextStyles.bodyLarge),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('测试 (${_currentIndex + 1}/${_questions.length})'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: NinjaColors.divider.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(NinjaColors.primary),
          ),
          const SizedBox(height: NinjaSpacing.xl),

          // 题目
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NinjaSpacing.xl),
            child: Text(
              '请选择 "${question.word}" 的中文释义：',
              style: NinjaTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: NinjaSpacing.xxl),

          // 选项
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: NinjaSpacing.xl),
              children: question.options.map((option) {
                final isCorrect = option == question.correctAnswer;
                final isSelected = option == _selectedAnswer;
                Color? bgColor;
                if (_showResult) {
                  if (isCorrect) bgColor = NinjaColors.success.withValues(alpha: 0.15);
                  else if (isSelected) bgColor = NinjaColors.error.withValues(alpha: 0.15);
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: NinjaSpacing.md),
                  child: Material(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
                    child: InkWell(
                      onTap: () => _selectAnswer(option),
                      borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(NinjaSpacing.lg),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
                          border: Border.all(
                            color: _showResult && isCorrect
                                ? NinjaColors.success
                                : isSelected
                                    ? NinjaColors.error
                                    : NinjaColors.divider,
                            width: _showResult && (isCorrect || isSelected) ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(option, style: NinjaTextStyles.bodyLarge),
                            ),
                            if (_showResult && isCorrect)
                              const Icon(Icons.check_circle, color: NinjaColors.success),
                            if (_showResult && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: NinjaColors.error),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 下一题按钮
          if (_showResult)
            Padding(
              padding: const EdgeInsets.all(NinjaSpacing.xl),
              child: ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(
                  _currentIndex < _questions.length - 1 ? '下一题' : '查看结果',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TestQuestion {
  final String word;
  final String wordId;
  final String correctAnswer;
  final List<String> options;

  const _TestQuestion({
    required this.word,
    required this.wordId,
    required this.correctAnswer,
    required this.options,
  });
}
