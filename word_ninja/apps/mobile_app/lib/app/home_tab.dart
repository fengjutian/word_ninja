part of 'router.dart';

/// 首页 Tab（Dashboard）
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(vocabularyStatsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('WordFlow'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // 等级卡片 — 带有渐变背景
          stats.when(
            data: (value) => _LearningOverviewCard(
              totalWords: value.totalWords,
              masteredWords: value.masteredWords,
              dueWords: value.dueReviewCount,
              todayReviews: value.todayReview,
            ),
            loading: () => const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.warningCircle,
                        color: AppColors.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text('统计加载失败：$error')),
                    TextButton(
                      onPressed: () => ref.invalidate(vocabularyStatsProvider),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 今日任务
          SectionHeader(
              title: '今日任务',
              icon: const Icon(PhosphorIconsRegular.checkSquare,
                  size: 18, color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          stats.when(
            data: (value) => value.totalWords == 0
                ? _TaskItem(
                    icon: AppIcon.scroll(size: 20, color: AppColors.primary),
                    title: '添加第一个单词',
                    route: AppRoutes.vocabulary,
                  )
                : _TaskItem(
                    icon: AppIcon.practice(size: 20, color: AppColors.primary),
                    title: value.dueReviewCount > 0
                        ? '复习 ${value.dueReviewCount} 个到期单词'
                        : '今日复习已完成',
                    route: value.dueReviewCount > 0
                        ? AppRoutes.review
                        : AppRoutes.vocabulary,
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // 快捷入口
          SectionHeader(
              title: '学习成长',
              icon: AppIcon.practice(size: 20, color: AppColors.primary)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _QuickChip(
                  '单词',
                  AppIcon.scroll(size: 16, color: AppColors.primary),
                  AppRoutes.vocabulary),
              _QuickChip(
                  '阅读',
                  AppIcon.scroll(size: 16, color: AppColors.primary),
                  AppRoutes.reading),
              _QuickChip(
                  '听力',
                  AppIcon.headphone(size: 16, color: AppColors.primary),
                  AppRoutes.listening),
              _QuickChip('口语', AppIcon.mic(size: 16, color: AppColors.primary),
                  AppRoutes.speaking),
              _QuickChip('写作', AppIcon.pen(size: 16, color: AppColors.primary),
                  AppRoutes.writing),
              _QuickChip(
                  'AI导师',
                  AppIcon.chatBubble(size: 16, color: AppColors.primary),
                  AppRoutes.aiTutor),
              _QuickChip(
                  '网页',
                  const Icon(PhosphorIconsRegular.globe,
                      size: 16, color: AppColors.primary),
                  AppRoutes.webReader),
              _QuickChip(
                  '计划',
                  AppIcon.calendar(size: 16, color: AppColors.primary),
                  AppRoutes.studyPlan),
            ],
          ),
        ],
      ),
    );
  }
}

/// 等级卡片 — 带渐变背景、动画经验条
class _LearningOverviewCard extends StatelessWidget {
  final int totalWords;
  final int masteredWords;
  final int dueWords;
  final int todayReviews;

  const _LearningOverviewCard({
    required this.totalWords,
    required this.masteredWords,
    required this.dueWords,
    required this.todayReviews,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalWords == 0 ? 0.0 : masteredWords / totalWords;
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.accentGold.withValues(alpha: 0.05),
              AppColors.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Row(
              children: [
                // 等级标识
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        AppColors.levelIntermediate,
                        AppColors.levelIntermediate,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColors.levelIntermediate.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$masteredWords',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // 等级信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '词汇学习进度',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '已掌握 $masteredWords / $totalWords · 待复习 $dueWords',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                AppIcon.mountain(
                    size: 32,
                    color: AppColors.accentGold.withValues(alpha: 0.3)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // 经验条
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.divider.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.accentGold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // EXP 数字
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(PhosphorIconsRegular.checkCircle,
                      size: 14, color: AppColors.accentGold),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '今日已复习 $todayReviews 次',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 分段标题组件
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget icon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTextStyles.heading3),
      ],
    );
  }
}

/// 任务项 — 带点击缩放动画
class _TaskItem extends StatefulWidget {
  final Widget icon;
  final String title;
  final String route;

  const _TaskItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  State<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<_TaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animController.forward(),
      onTapUp: (_) {
        _animController.reverse();
        context.push(widget.route);
      },
      onTapCancel: () => _animController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (ctx, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
          color: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.sm),
              ),
              child: Center(child: widget.icon),
            ),
            title: Text(widget.title, style: AppTextStyles.bodyMedium),
            trailing: const Icon(PhosphorIconsRegular.caretRight,
                size: 18, color: AppColors.textSecondary),
            onTap: () => context.push(widget.route),
          ),
        ),
      ),
    );
  }
}

/// 快捷入口 Chip
class _QuickChip extends StatelessWidget {
  final String label;
  final Widget icon;
  final String route;

  const _QuickChip(this.label, this.icon, this.route);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: icon,
      label: Text(label, style: AppTextStyles.bodySmall),
      onPressed: () => context.push(route),
      backgroundColor: AppColors.primary.withValues(alpha: 0.08),
      side: BorderSide.none,
    );
  }
}
