import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ai/ai.dart';
import '../providers/analysis_provider.dart';

part 'analysis_widgets.dart';

/// 学习分析报告页
class AnalysisPage extends ConsumerStatefulWidget {
  const AnalysisPage({super.key});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(analysisProvider.notifier).loadStats();
    });
  }

  void _generateReport() {
    if (!mounted) return;
    final aiService = ref.read(aiChatServiceProvider);
    ref
        .read(analysisProvider.notifier)
        .generateReport(AiAnalysisService(aiService));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('学习分析', style: TextStyle(color: Colors.white)),
        actions: [
          if (!state.isLoading)
            TextButton.icon(
              onPressed: _generateReport,
              icon: Icon(
                state.analysisCount > 0
                    ? PhosphorIconsRegular.arrowsClockwise
                    : PhosphorIconsRegular.sparkle,
                size: 18,
                color: AppColors.warning,
              ),
              label: Text(
                state.analysisCount > 0 ? '重新分析' : 'AI 分析',
                style: const TextStyle(color: AppColors.warning),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // 多色渐变背景（模拟 SVG 的彩色光晕）
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFCDD3D9), // 浅灰（SVG 底色）
                    Color(0xFF68BE8D), // 绿色光晕
                    Color(0xFF008899), // 青蓝色光晕
                    Color(0xFF274A78), // 深蓝光晕
                  ],
                  stops: [0.0, 0.25, 0.6, 1.0],
                ),
              ),
            ),
          ),
          // 半透明遮罩：保护文字可读性
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00FFFFFF),
                    Color(0x33FFFFFF),
                    Color(0x99FFFFFF),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // ─── 一句话洞察 ───
              if (state.quickInsight != null)
                _InsightCard(insight: state.quickInsight!),

              // ─── 基本统计 ───
              _StatsRow(
                sessionCount: state.sessionCount,
                wordCount: state.topWords.length,
              ),

              const SizedBox(height: AppSpacing.md),

              // ─── 高频词 TOP 10 ───
              if (state.topWords.isNotEmpty) ...[
                Text(
                    '高频询问词 TOP ${state.topWords.length > 10 ? 10 : state.topWords.length}',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: state.topWords.take(10).map((w) {
                    return Chip(
                      avatar: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        child: Text('${w.count}',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.primary)),
                      ),
                      label: Text(w.word,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                          color: AppColors.divider.withValues(alpha: 0.5)),
                    );
                  }).toList(),
                ),
              ],

              // ─── 🎯 重点强化词 ───
              if (state.focusWords.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Icon(PhosphorIconsRegular.target,
                        size: 18, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Text('🎯 重点强化词',
                        style: AppTextStyles.titleMedium
                            .copyWith(color: AppColors.warning)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('AI 识别以下词汇需要更多复习（间隔自动缩短 50%）',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                ...state.focusWords.map((fw) => _FocusWordCard(focusWord: fw)),
              ],

              const SizedBox(height: AppSpacing.lg),

              // ─── AI 分析报告 ───
              if (state.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 12),
                        Text('AI 正在分析你的学习数据...',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),

              if (state.error != null)
                _ErrorCard(
                  message: state.error!,
                  onRetry: state.isLoading ? null : _generateReport,
                ),

              if (state.report != null && !state.isLoading)
                _ReportCard(
                  key: ValueKey('report_${state.analysisCount}'),
                  report: state.report!,
                  analysisCount: state.analysisCount,
                ),

              if (state.report == null &&
                  !state.isLoading &&
                  state.error == null)
                _EmptyState(onGenerate: _generateReport),
            ],
          ),
        ],
      ),
    );
  }
}
