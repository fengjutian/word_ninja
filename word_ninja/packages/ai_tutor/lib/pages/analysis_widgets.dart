part of 'analysis_page.dart';

/// 一句话洞察卡片
class _InsightCard extends StatelessWidget {
  final String insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accentPurple],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.sparkle,
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(insight,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
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
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        _StatItem(
          icon: PhosphorIconsRegular.textAa,
          label: '查询词汇',
          value: '$wordCount',
          color: AppColors.accentPurple,
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
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsRegular.brain,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text('AI 分析报告',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              if (analysisCount > 1) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '第 $analysisCount 次',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.primary),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(PhosphorIconsRegular.warningCircle,
              color: AppColors.error, size: 28),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error, fontSize: 13)),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(PhosphorIconsRegular.chartBar,
              size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          const Text('点击「AI 分析」生成学习报告',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onGenerate,
            icon: const Icon(PhosphorIconsRegular.sparkle, size: 18),
            label: const Text('开始分析'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
  const _FocusWordCard({required this.focusWord});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.08),
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
                color:
                    focusWord.score >= 70 ? AppColors.error : AppColors.warning,
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
                      ? AppColors.error
                      : AppColors.warning,
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
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            PhosphorIconsRegular.lightning,
            size: 18,
            color: AppColors.warning.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
