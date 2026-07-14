import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ai/ai.dart';
import '../providers/analysis_provider.dart';

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
                color: NinjaColors.warning,
              ),
              label: Text(
                state.analysisCount > 0 ? '重新分析' : 'AI 分析',
                style: const TextStyle(color: NinjaColors.warning),
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
        padding: const EdgeInsets.all(NinjaSpacing.md),
        children: [
          // ─── 一句话洞察 ───
          if (state.quickInsight != null)
            _InsightCard(insight: state.quickInsight!),

          // ─── 基本统计 ───
          _StatsRow(
            sessionCount: state.sessionCount,
            wordCount: state.topWords.length,
          ),

          const SizedBox(height: NinjaSpacing.md),

          // ─── 高频词 TOP 10 ───
          if (state.topWords.isNotEmpty) ...[
            Text('高频询问词 TOP ${state.topWords.length > 10 ? 10 : state.topWords.length}',
                style: NinjaTextStyles.titleMedium),
            const SizedBox(height: NinjaSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: state.topWords.take(10).map((w) {
                return Chip(
                  avatar: CircleAvatar(
                    radius: 12,
                    backgroundColor: NinjaColors.primary.withValues(alpha: 0.15),
                    child: Text('${w.count}',
                        style: const TextStyle(fontSize: 10, color: NinjaColors.primary)),
                  ),
                  label: Text(w.word,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  backgroundColor: NinjaColors.surface,
                  side: BorderSide(color: NinjaColors.divider.withValues(alpha: 0.5)),
                );
              }).toList(),
            ),
          ],

          // ─── 🎯 重点强化词 ───
          if (state.focusWords.isNotEmpty) ...[
            const SizedBox(height: NinjaSpacing.lg),
            Row(
              children: [
                const Icon(PhosphorIconsRegular.target, size: 18, color: NinjaColors.warning),
                const SizedBox(width: 6),
                Text('🎯 重点强化词',
                    style: NinjaTextStyles.titleMedium.copyWith(color: NinjaColors.warning)),
              ],
            ),
            const SizedBox(height: 4),
            Text('AI 识别以下词汇需要更多复习（间隔自动缩短 50%）',
                style: const TextStyle(fontSize: 12, color: NinjaColors.textSecondary)),
            const SizedBox(height: NinjaSpacing.sm),
            ...state.focusWords.map((fw) => _FocusWordCard(focusWord: fw)),
          ],

          const SizedBox(height: NinjaSpacing.lg),

          // ─── AI 分析报告 ───
          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: NinjaColors.primary),
                    SizedBox(height: 12),
                    Text('AI 正在分析你的学习数据...',
                        style: TextStyle(color: NinjaColors.textSecondary)),
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

          if (state.report == null && !state.isLoading && state.error == null)
            _EmptyState(onGenerate: _generateReport),
        ],
      ),
        ],
      ),
    );
  }
}

/// 一句话洞察卡片
class _InsightCard extends StatelessWidget {
  final String insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      padding: const EdgeInsets.all(NinjaSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NinjaColors.primary, NinjaColors.accentPurple],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.sparkle, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(insight,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

/// 统计数字行
class _StatsRow extends StatelessWidget {
  final int sessionCount;
  final int wordCount;

  const _StatsRow({required this.sessionCount, required this.wordCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          icon: PhosphorIconsRegular.chatsCircle,
          label: '对话会话',
          value: '$sessionCount',
          color: NinjaColors.primary,
        ),
        const SizedBox(width: 12),
        _StatItem(
          icon: PhosphorIconsRegular.textAa,
          label: '查询词汇',
          value: '$wordCount',
          color: NinjaColors.accentPurple,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(NinjaSpacing.md),
        decoration: BoxDecoration(
          color: NinjaColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: NinjaColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                Text(label,
                    style: const TextStyle(fontSize: 12, color: NinjaColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// AI 分析报告卡片
class _ReportCard extends StatelessWidget {
  final String report;
  final int analysisCount;
  const _ReportCard({super.key, required this.report, this.analysisCount = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NinjaSpacing.md),
      decoration: BoxDecoration(
        color: NinjaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NinjaColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.brain, size: 20, color: NinjaColors.primary),
              const SizedBox(width: 6),
              const Text('AI 分析报告',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              if (analysisCount > 1) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: NinjaColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '第 $analysisCount 次',
                    style: const TextStyle(fontSize: 11, color: NinjaColors.primary),
                  ),
                ),
              ],
            ],
          ),
          const Divider(),
          MarkdownBody(
            data: report,
            styleSheet: MarkdownStyleSheet(
              h3: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              p: const TextStyle(fontSize: 14, height: 1.6),
              strong: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// 错误提示
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorCard({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(NinjaSpacing.md),
      decoration: BoxDecoration(
        color: NinjaColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NinjaColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(PhosphorIconsRegular.warningCircle, color: NinjaColors.error, size: 28),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: NinjaColors.error, fontSize: 13)),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(PhosphorIconsRegular.arrowsClockwise, size: 16),
              label: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 空状态 — 还没有 AI 分析
class _EmptyState extends StatelessWidget {
  final VoidCallback onGenerate;
  const _EmptyState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: NinjaColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NinjaColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.chartBar,
              size: 48, color: NinjaColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text('点击「AI 分析」生成学习报告',
              style: TextStyle(color: NinjaColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onGenerate,
            icon: const Icon(PhosphorIconsRegular.sparkle, size: 18),
            label: const Text('开始分析'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NinjaColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 重点强化词卡片
class _FocusWordCard extends StatelessWidget {
  final FocusWord focusWord;
  const _FocusWordCard({super.key, required this.focusWord});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NinjaColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: NinjaColors.warning.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: NinjaColors.warning.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 分数环
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: focusWord.score >= 70
                    ? NinjaColors.error
                    : NinjaColors.warning,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '${focusWord.score}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: focusWord.score >= 70
                      ? NinjaColors.error
                      : NinjaColors.warning,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  focusWord.word,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  focusWord.reason,
                  style: const TextStyle(
                    fontSize: 12,
                    color: NinjaColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            PhosphorIconsRegular.lightning,
            size: 18,
            color: NinjaColors.warning.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
