import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai/providers/ai_providers.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

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
  Map<String, dynamic>? _correctionResult;
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
    setState(() => _isGenerating = true);
    try {
      final service = ref.read(aiWritingServiceProvider);
      final result = await service.generateComposition(topic);
      setState(() => _generatedComposition = result);
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _correctEssay() async {
    final text = _essayCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isCorrecting = true);
    try {
      final service = ref.read(aiWritingServiceProvider);
      final result = await service.correct(text);
      setState(() => _correctionResult = result);
      _showCorrectionDialog(result);
    } finally {
      setState(() => _isCorrecting = false);
    }
  }

  Future<void> _ieltsScore() async {
    final text = _essayCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isScoring = true);
    try {
      final service = ref.read(aiWritingServiceProvider);
      final result = await service.ieltsScore(text);
      setState(() => _ieltsResult = result);
    } finally {
      setState(() => _isScoring = false);
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
          padding: const EdgeInsets.all(NinjaSpacing.lg),
          children: [
            Text('批改结果', style: NinjaTextStyles.heading2),
            const SizedBox(height: NinjaSpacing.md),
            Text('评分：${result['score']} 分',
                style: NinjaTextStyles.heading3.copyWith(color: NinjaColors.accentGold)),
            const SizedBox(height: NinjaSpacing.md),
            if (errors.isNotEmpty) ...[
              Text('语法错误 (${errors.length})', style: NinjaTextStyles.titleSmall),
              ...errors.map((e) => Card(
                    margin: const EdgeInsets.only(bottom: NinjaSpacing.sm),
                    child: ListTile(
                      title: Text('❌ ${e['error'] ?? ''}',
                          style: const TextStyle(color: NinjaColors.error)),
                      subtitle: Text('✅ ${e['correction'] ?? ''}\n${e['explanation'] ?? ''}'),
                    ),
                  )),
            ],
            Text('总评：${result['overall_comment'] ?? ''}',
                style: NinjaTextStyles.bodyLarge),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('写作训练')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Text('AI作文生成', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.lg),
              child: Column(
                children: [
                  TextField(
                    controller: _topicCtrl,
                    decoration: const InputDecoration(
                      hintText: '输入作文主题...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: NinjaSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateComposition,
                      icon: _isGenerating
                          ? const SizedBox.square(
                              dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isGenerating ? '生成中...' : '生成范文'),
                    ),
                  ),
                  if (_generatedComposition != null) ...[
                    const SizedBox(height: NinjaSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(NinjaSpacing.md),
                      decoration: BoxDecoration(
                        color: NinjaColors.background,
                        borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
                      ),
                      child: Text(_generatedComposition!, style: NinjaTextStyles.bodyMedium),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: NinjaSpacing.xl),
          Text('AI批改', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.lg),
              child: Column(
                children: [
                  TextField(
                    controller: _essayCtrl,
                    decoration: const InputDecoration(
                      hintText: '粘贴你的作文...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: NinjaSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isCorrecting ? null : _correctEssay,
                          icon: _isCorrecting
                              ? const SizedBox.square(
                                  dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.rate_review),
                          label: Text(_isCorrecting ? '批改中...' : 'AI批改'),
                        ),
                      ),
                      const SizedBox(width: NinjaSpacing.md),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isScoring ? null : _ieltsScore,
                          icon: _isScoring
                              ? const SizedBox.square(
                                  dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.school),
                          label: Text(_isScoring ? '评分中...' : 'IELTS评分'),
                          style: ElevatedButton.styleFrom(backgroundColor: NinjaColors.accentGold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_ieltsResult != null) ...[
            const SizedBox(height: NinjaSpacing.lg),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(NinjaSpacing.lg),
                child: Column(
                  children: [
                    Text('IELTS 评分结果', style: NinjaTextStyles.heading2),
                    const SizedBox(height: NinjaSpacing.md),
                    Text('Overall: ${(_ieltsResult!['overall_band'] as num?)?.toStringAsFixed(1) ?? '0.0'}',
                        style: NinjaTextStyles.displayMedium.copyWith(color: NinjaColors.accentGold)),
                    const SizedBox(height: NinjaSpacing.md),
                    _IeltsBar('任务完成度', _ieltsResult!['task_achievement'] ?? 0),
                    _IeltsBar('连贯与衔接', _ieltsResult!['coherence'] ?? 0),
                    _IeltsBar('词汇资源', _ieltsResult!['lexical_resource'] ?? 0),
                    _IeltsBar('语法准确性', _ieltsResult!['grammatical_range'] ?? 0),
                    if (_ieltsResult!['comment'] != null && _ieltsResult!['comment'].toString().isNotEmpty) ...[
                      const SizedBox(height: NinjaSpacing.md),
                      Text('评语：${_ieltsResult!['comment']}', style: NinjaTextStyles.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IeltsBar extends StatelessWidget {
  final String label;
  final dynamic value;
  const _IeltsBar(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final v = (value is num) ? value.toDouble() : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: NinjaSpacing.sm),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: NinjaTextStyles.bodySmall)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (v / 9).clamp(0.0, 1.0),
                minHeight: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  v >= 7 ? NinjaColors.success : v >= 5 ? NinjaColors.warning : NinjaColors.error,
                ),
              ),
            ),
          ),
          const SizedBox(width: NinjaSpacing.sm),
          SizedBox(width: 30, child: Text(v.toStringAsFixed(1), style: NinjaTextStyles.caption)),
        ],
      ),
    );
  }
}
