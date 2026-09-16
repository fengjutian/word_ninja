import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai/providers/ai_providers.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/design_tokens.dart';

part 'writing_widgets.dart';

/// 写作训练页
class WritingPage extends ConsumerStatefulWidget {
  const WritingPage({super.key});

  @override
  ConsumerState<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends ConsumerState<WritingPage> {
  final _topicCtrl = TextEditingController();
  final _essayCtrl = TextEditingController();
  bool _isGenerating = false;
  bool _isCorrecting = false;
  bool _isScoring = false;
  String? _generatedComposition;
  String? _error;
  Map<String, dynamic>? _ieltsResult;

  @override
  void dispose() {
    _topicCtrl.dispose();
    _essayCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateComposition() async {
    final topic = _topicCtrl.text.trim();
    if (topic.isEmpty) return;
    setState(() {
      _isGenerating = true;
      _error = null;
    });
    try {
      final service = ref.read(aiWritingServiceProvider);
      final result = await service.generateComposition(topic);
      if (mounted) setState(() => _generatedComposition = result);
    } catch (e) {
      if (mounted) setState(() => _error = '生成失败: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _correctEssay() async {
    final text = _essayCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _isCorrecting = true;
      _error = null;
    });
    try {
      final service = ref.read(aiWritingServiceProvider);
      final result = await service.correct(text);
      if (mounted) {
        _showCorrectionDialog(result);
      }
    } catch (e) {
      if (mounted) setState(() => _error = '批改失败: $e');
    } finally {
      if (mounted) setState(() => _isCorrecting = false);
    }
  }

  Future<void> _ieltsScore() async {
    final text = _essayCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _isScoring = true;
      _error = null;
    });
    try {
      final service = ref.read(aiWritingServiceProvider);
      final result = await service.ieltsScore(text);
      if (mounted) setState(() => _ieltsResult = result);
    } catch (e) {
      if (mounted) setState(() => _error = '评分失败: $e');
    } finally {
      if (mounted) setState(() => _isScoring = false);
    }
  }

  void _showCorrectionDialog(Map<String, dynamic> result) {
    final errors = (result['grammar_errors'] as List?) ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollCtrl) => ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('批改结果', style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.md),
            Text('评分：${result['score'] ?? '?'} 分',
                style: AppTextStyles.heading3
                    .copyWith(color: AppColors.accentGold)),
            const SizedBox(height: AppSpacing.md),
            if (errors.isNotEmpty) ...[
              Text('语法错误 (${errors.length})', style: AppTextStyles.titleSmall),
              ...errors.map((e) => Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: ListTile(
                      title: Text('❌ ${e['error'] ?? ''}',
                          style: const TextStyle(color: AppColors.error)),
                      subtitle: Text(
                          '✅ ${e['correction'] ?? ''}\n${e['explanation'] ?? ''}'),
                    ),
                  )),
            ],
            Text('总评：${result['overall_comment'] ?? ''}',
                style: AppTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
            children: [
              Row(children: [
                Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12)),
                    child: Icon(PhosphorIconsRegular.penNib,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22)),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('写作训练',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 3),
                  Text('从构思、表达，到批改与评分的一站式写作助手',
                      style: TextStyle(fontSize: 13, color: colors.mutedText))
                ]),
              ]),
              const SizedBox(height: 30),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.error)),
                ),
              Text('灵感与范文', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('输入主题，生成一篇结构完整的参考范文',
                  style: TextStyle(fontSize: 12, color: colors.mutedText)),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextField(
                        controller: _topicCtrl,
                        decoration: const InputDecoration(
                          hintText: '输入作文主题...',
                          prefixIcon:
                              Icon(PhosphorIconsRegular.lightbulb, size: 18),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed:
                              _isGenerating ? null : _generateComposition,
                          icon: _isGenerating
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Icon(PhosphorIconsRegular.sparkle),
                          label: Text(_isGenerating ? '生成中...' : '生成范文'),
                        ),
                      ),
                      if (_generatedComposition != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.buttonRadius),
                          ),
                          child: Text(_generatedComposition!,
                              style: AppTextStyles.bodyMedium),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('批改与评分', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('粘贴你的英文作文，获得针对性的修改建议',
                  style: TextStyle(fontSize: 12, color: colors.mutedText)),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      TextField(
                        controller: _essayCtrl,
                        decoration: const InputDecoration(
                          hintText: '粘贴你的作文...',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isCorrecting ? null : _correctEssay,
                              icon: _isCorrecting
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(
                                      PhosphorIconsRegular.chatCircleText),
                              label: Text(_isCorrecting ? '批改中...' : 'AI批改'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isScoring ? null : _ieltsScore,
                              icon: _isScoring
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(
                                      PhosphorIconsRegular.graduationCap),
                              label: Text(_isScoring ? '评分中...' : 'IELTS评分'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_ieltsResult != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Text('IELTS 评分结果', style: AppTextStyles.heading2),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                            'Overall: ${((_ieltsResult!['overall_band'] as num?)?.toStringAsFixed(1) ?? '0.0')}',
                            style: AppTextStyles.displayMedium
                                .copyWith(color: AppColors.accentGold)),
                        const SizedBox(height: AppSpacing.md),
                        _IeltsBar('任务完成度', _ieltsResult!['task_achievement']),
                        _IeltsBar('连贯与衔接', _ieltsResult!['coherence']),
                        _IeltsBar('词汇资源', _ieltsResult!['lexical_resource']),
                        _IeltsBar('语法准确性', _ieltsResult!['grammatical_range']),
                        if (_ieltsResult!['comment']?.toString().isNotEmpty ==
                            true) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text('评语：${_ieltsResult!['comment']}',
                              style: AppTextStyles.bodyMedium),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
