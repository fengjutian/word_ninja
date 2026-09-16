import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import '../../data/model/word.dart';
import '../providers/word_provider.dart';

/// 艾宾浩斯复习页 — 单词卡片翻转
class ReviewPage extends ConsumerStatefulWidget {
  final List<Word> words;

  const ReviewPage({super.key, this.words = const []});

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageCtrl;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;
  bool _showMeaning = false;
  int _currentIndex = 0;
  bool _isSubmitting = false;
  bool _isLoading = false;
  String? _loadError;
  List<Word> _words = [];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _flipCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut),
    );
    _initWords();
  }

  void _initWords() {
    if (widget.words.isNotEmpty) {
      _words = widget.words;
    } else {
      // 从 Provider 加载待复习单词
      _loadDueReviews();
    }
  }

  Future<void> _loadDueReviews() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final words = await ref.read(dueReviewProvider.future);
      if (mounted) setState(() => _words = words);
    } catch (e) {
      if (mounted) setState(() => _loadError = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _flipCtrl.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showMeaning) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    _showMeaning = !_showMeaning;
  }

  void _rateWord(int score) async {
    if (_isSubmitting) return;
    if (_words.isEmpty) return;
    final word = _words[_currentIndex];
    setState(() => _isSubmitting = true);
    try {
      await ref.read(vocabularyRepositoryProvider).submitReview(word.id, score);
      ref.invalidate(vocabularyStatsProvider);
      ref.invalidate(dueReviewProvider);
      await ref.read(wordListProvider.notifier).loadWords(refresh: true);
      if (!mounted) return;
      if (_currentIndex < _words.length - 1) {
        final nextIdx = _currentIndex + 1;
        _currentIndex = nextIdx;
        _pageCtrl.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
        _flipCtrl.reset();
        _showMeaning = false;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🎉 复习完成！')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('复习')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('复习')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('加载失败：$_loadError'),
              const SizedBox(height: 12),
              FilledButton(onPressed: _loadDueReviews, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    if (_words.isEmpty && widget.words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('复习')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsRegular.checkCircle,
                  size: 64, color: AppColors.success),
              SizedBox(height: 16),
              Text('暂无待复习单词', style: AppTextStyles.heading3),
            ],
          ),
        ),
      );
    }

    final word = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('复习 (${_currentIndex + 1}/${_words.length})'),
      ),
      body: Column(
        children: [
          // 进度条
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _words.length,
            backgroundColor: AppColors.divider.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          Expanded(
            child: GestureDetector(
              onTap: _flipCard,
              child: Center(
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (context, child) {
                    final angle = _flipAnim.value * pi;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: angle < pi / 2
                          ? _buildWordFront(word)
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(pi),
                              child: _buildWordBack(word),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 评分按钮
          if (_showMeaning)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: _isSubmitting
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _scoreBtn(PhosphorIconsRegular.smileySad, '不认识',
                            AppColors.error, () => _rateWord(1)),
                        _scoreBtn(PhosphorIconsRegular.smileyMeh, '模糊',
                            AppColors.warning, () => _rateWord(3)),
                        _scoreBtn(PhosphorIconsRegular.smiley, '认识',
                            AppColors.success, () => _rateWord(5)),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildWordFront(Word word) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.xl),
      child: Container(
        width: double.infinity,
        height: 280,
        alignment: Alignment.center,
        child: Text(word.word, style: AppTextStyles.displayLarge),
      ),
    );
  }

  Widget _buildWordBack(Word word) {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.xl),
      color: AppColors.primaryLight.withValues(alpha: 0.05),
      child: Container(
        width: double.infinity,
        height: 280,
        padding: const EdgeInsets.all(AppSpacing.xl),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(word.meaning, style: AppTextStyles.heading1),
            if (word.phonetic.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('/${word.phonetic}/', style: AppTextStyles.bodyLarge),
            ],
            if (word.example.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(word.example,
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  Widget _scoreBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}
