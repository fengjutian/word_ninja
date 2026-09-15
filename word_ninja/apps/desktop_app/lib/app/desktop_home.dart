part of 'desktop_app.dart';

class _DesktopHome extends ConsumerWidget {
  const _DesktopHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final subColor = isDark
        ? AppColors.textOnDark.withValues(alpha: 0.6)
        : AppColors.textSecondary;

    // Try to load stats (may fail if vocabulary not yet initialized)
    final statsAsync = ref.watch(vocabularyStatsProvider);

    return ScaffoldPage(
      padding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                AppIcon.learning(size: 40, color: AppColors.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WordFlow',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '你的 AI 英语学习者学习之路',
                      style: TextStyle(fontSize: 13, color: subColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats cards
            statsAsync.when(
              data: (stats) => _buildStatsRow(stats, textColor, subColor),
              loading: () => const SizedBox.shrink(),
              error: (_, __) =>
                  const SizedBox.shrink(), // silently skip if not available
            ),
            const SizedBox(height: 20),

            // Quick actions
            Text(
              '快捷入口',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickCard(
                  icon: FluentIcons.bookmarks,
                  label: '单词本',
                  color: AppColors.secondary,
                  onTap: () => context.go(DesktopRoutes.vocabulary),
                ),
                _QuickCard(
                  icon: FluentIcons.reading_mode,
                  label: '阅读',
                  color: AppColors.success,
                  onTap: () => context.go(DesktopRoutes.reading),
                ),
                _QuickCard(
                  icon: FluentIcons.chat,
                  label: 'AI Tutor',
                  color: AppColors.accentPurple,
                  onTap: () => context.go(DesktopRoutes.aiTutor),
                ),
                _QuickCard(
                  icon: FluentIcons.design,
                  label: '写作',
                  color: AppColors.info,
                  onTap: () => context.go(DesktopRoutes.writing),
                ),
                _QuickCard(
                  icon: FluentIcons.task_list,
                  label: '学习计划',
                  color: AppColors.accentGold,
                  onTap: () => context.go(DesktopRoutes.studyPlan),
                ),
                _QuickCard(
                  icon: FluentIcons.headset,
                  label: '听力',
                  color: AppColors.levelAdvanced,
                  onTap: () => context.go(DesktopRoutes.listening),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(
    VocabularyStats stats,
    Color textColor,
    Color subColor,
  ) {
    final items = [
      _StatItem(stats.totalWords.toString(), '总词汇', AppColors.primary),
      _StatItem(stats.masteredWords.toString(), '已掌握', AppColors.success),
      _StatItem(stats.todayReview.toString(), '今日复习', AppColors.accentGold),
      _StatItem(stats.learningWords.toString(), '待复习', AppColors.warning),
    ];
    return Row(children: items.map((s) => Expanded(child: s)).toList());
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatItem(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Button(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
