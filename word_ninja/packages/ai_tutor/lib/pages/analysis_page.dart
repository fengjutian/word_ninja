import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      ref.read(analysisProvider.notifier).loadStats();
    });
  }

  void _generateReport() {
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
          if (state.report == null && !state.isLoading)
            TextButton.icon(
              onPressed: _generateReport,
              icon: const Icon(PhosphorIconsRegular.sparkle, size: 18, color: NinjaColors.warning),
              label: const Text('AI 分析', style: TextStyle(color: NinjaColors.warning)),
            ),
        ],
      ),
      body: Stack(
        children: [
          // SVG 渐变背景
          Positioned.fill(
            child: ClipRect(
              child: SvgPicture.asset(
                'assets/analysis_bg.svg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 渐变遮罩：顶部透明，底部微遮提高可读性
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00FFFFFF), // 顶部：完全透明
                    Color(0x66FFFFFF), // 中部：微微白
                    Color(0xCCFFFFFF), // 底部：较强白，保证文字可读
                  ],
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
            _ReportCard(report: state.report!),

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
  const _ReportCard({required this.report});

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
