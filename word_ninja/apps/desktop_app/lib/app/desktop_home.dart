part of 'desktop_app.dart';

class _DesktopHome extends ConsumerWidget {
  const _DesktopHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fluent = FluentTheme.of(context);
    final dark = fluent.brightness == Brightness.dark;
    final tokens = AppColorTokens.forPreset(
      AppThemeCatalog.indigo,
      dark ? Brightness.dark : Brightness.light,
    );
    final foreground = dark ? AppColors.textOnDark : AppColors.textPrimary;
    final stats = ref.watch(vocabularyStatsProvider);

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: ColoredBox(
        color: tokens.canvas,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(foreground: foreground, muted: tokens.mutedText),
                  const SizedBox(height: 28),
                  _ContinueCard(tokens: tokens, foreground: foreground),
                  const SizedBox(height: 24),
                  Text(
                    '学习概览',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  stats.when(
                    data: (value) => _StatsGrid(
                      stats: value,
                      tokens: tokens,
                      foreground: foreground,
                    ),
                    loading: () => const ProgressBar(),
                    error: (_, __) => _StatsGrid(
                      stats: const VocabularyStats(),
                      tokens: tokens,
                      foreground: foreground,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '开始学习',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionGrid(tokens: tokens, foreground: foreground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.foreground, required this.muted});
  final Color foreground, muted;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppThemeCatalog.indigo.seed,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Text(
          'W',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(width: 14),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '继续你的学习旅程',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '每天一点进步，让英语成为你的工具。',
            style: TextStyle(fontSize: 13, color: muted),
          ),
        ],
      ),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppThemeCatalog.indigo.seed.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              FluentIcons.calendar,
              size: 14,
              color: AppThemeCatalog.indigo.seed,
            ),
            const SizedBox(width: 7),
            Text(
              '今日学习',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppThemeCatalog.indigo.seed,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.tokens, required this.foreground});
  final AppColorTokens tokens;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppThemeCatalog.indigo.seed,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppThemeCatalog.indigo.seed.withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今日推荐',
                style: TextStyle(
                  color: Color(0xFFD9D9FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '复习今天到期的单词',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '利用间隔重复巩固记忆，预计用时 10 分钟',
                style: TextStyle(color: Color(0xFFE7E7FF), fontSize: 13),
              ),
            ],
          ),
        ),
        mt.FilledButton.icon(
          style: mt.FilledButton.styleFrom(
            backgroundColor: mt.Colors.white,
            foregroundColor: AppThemeCatalog.indigo.seed,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: () => context.go(DesktopRoutes.vocabulary),
          icon: const Icon(FluentIcons.play, size: 14),
          label: const Text('继续学习'),
        ),
      ],
    ),
  );
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.stats,
    required this.tokens,
    required this.foreground,
  });
  final VocabularyStats stats;
  final AppColorTokens tokens;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final values = [
      (
        '总词汇',
        stats.totalWords,
        FluentIcons.dictionary,
        AppThemeCatalog.indigo.seed,
      ),
      ('已掌握', stats.masteredWords, FluentIcons.accept, tokens.success),
      ('今日复习', stats.todayReview, FluentIcons.history, tokens.warning),
      ('学习中', stats.learningWords, FluentIcons.clock, tokens.info),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 36) / 4;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: values
              .map(
                (item) => Container(
                  width: width.clamp(210, constraints.maxWidth).toDouble(),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: tokens.sidebar,
                    border: Border.all(color: tokens.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: item.$4.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(item.$3, size: 17, color: item.$4),
                      ),
                      const SizedBox(width: 13),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.$2}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                          ),
                          Text(
                            item.$1,
                            style: TextStyle(
                              fontSize: 12,
                              color: tokens.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.tokens, required this.foreground});
  final AppColorTokens tokens;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('单词学习', '积累与复习核心词汇', FluentIcons.dictionary, DesktopRoutes.vocabulary),
      ('沉浸阅读', '在语境中理解表达', FluentIcons.reading_mode, DesktopRoutes.reading),
      ('AI 导师', '获得个性化学习反馈', FluentIcons.chat, DesktopRoutes.aiTutor),
      ('写作练习', '润色并改进英文写作', FluentIcons.edit, DesktopRoutes.writing),
      ('学习计划', '安排每日学习任务', FluentIcons.task_list, DesktopRoutes.studyPlan),
      ('听力训练', '精听、听写与跟读', FluentIcons.headset, DesktopRoutes.listening),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 800 ? 3 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions
              .map(
                (item) => HoverButton(
                  onPressed: () => context.go(item.$4),
                  builder: (context, states) => AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: width,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: states.isHovered
                          ? tokens.subtleSurface
                          : tokens.sidebar,
                      border: Border.all(
                        color: states.isHovered
                            ? AppThemeCatalog.indigo.seed.withValues(
                                alpha: 0.40,
                              )
                            : tokens.border,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppThemeCatalog.indigo.seed.withValues(
                              alpha: 0.09,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.$3,
                            size: 18,
                            color: AppThemeCatalog.indigo.seed,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$1,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.$2,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tokens.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          FluentIcons.chevron_right,
                          size: 11,
                          color: tokens.mutedText,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
