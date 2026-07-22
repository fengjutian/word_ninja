import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auth/presentation/login/login_page.dart';
import 'package:auth/presentation/register/register_page.dart';
import 'package:auth/presentation/forgot_password/forgot_password_page.dart';
import 'package:vocabulary/presentation/pages/vocabulary_page.dart';
import 'package:vocabulary/presentation/pages/word_detail_page.dart';
import 'package:vocabulary/presentation/pages/add_word_page.dart';
import 'package:vocabulary/presentation/pages/review_page.dart';
import 'package:vocabulary/presentation/pages/word_test_page.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:reading/presentation/pages/reader_page.dart';
import 'package:web_reader/pages/web_reader_page.dart';
import 'package:listening/presentation/pages/listening_page.dart';
import 'package:speaking/presentation/pages/speaking_page.dart';
import 'package:writing/presentation/pages/writing_page.dart';
import 'package:ai_tutor/pages/tutor_chat_page.dart';
import 'package:study_plan/pages/study_plan_page.dart';
import 'package:shop/pages/shop_page.dart';
import 'package:leaderboard/pages/leaderboard_page.dart';
import 'package:profile/pages/profile_page.dart';
import 'package:profile/pages/settings_page.dart';
import 'package:profile/pages/membership_page.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;

/// 路由路径常量
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/';
  static const String vocabulary = '/vocabulary';
  static const String wordDetail = '/vocabulary/detail/:id';
  static const String addWord = '/vocabulary/add';
  static const String review = '/vocabulary/review';
  static const String wordTest = '/vocabulary/test';
  static const String reading = '/reading';
  static const String webReader = '/web-reader';
  static const String listening = '/listening';
  static const String speaking = '/speaking';
  static const String writing = '/writing';
  static const String aiTutor = '/ai-tutor';
  static const String studyPlan = '/study-plan';
  static const String shop = '/shop';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String membership = '/membership';
}

// ─── 过渡动画辅助函数 ───

/// 从右滑入（标准页面导航）
Page<T> _slideInFromRight<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0.35, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      return SlideTransition(position: offset, child: child);
    },
  );
}

/// 从下滑入（Tab 切换）
Page<T> _slideInFromBottom<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
      final offset = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ));
      return SlideTransition(
        position: offset,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

/// 创建 GoRouter 实例
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      // ─── 认证 ───
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (ctx, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (ctx, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (ctx, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
          transitionsBuilder: (ctx, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const ForgotPasswordPage(),
        ),
      ),

      // ─── 主页（带底部导航） ───
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (ctx, state) => _slideInFromBottom(
              key: state.pageKey,
              child: const _HomeTab(),
            ),
          ),
          GoRoute(
            path: AppRoutes.vocabulary,
            pageBuilder: (ctx, state) => _slideInFromBottom(
              key: state.pageKey,
              child: const VocabularyPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.aiTutor,
            pageBuilder: (ctx, state) => _slideInFromBottom(
              key: state.pageKey,
              child: const TutorChatPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.reading,
            pageBuilder: (ctx, state) => _slideInFromBottom(
              key: state.pageKey,
              child: const ReaderPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.webReader,
            pageBuilder: (ctx, state) => _slideInFromBottom(
              key: state.pageKey,
              child: const WebReaderPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (ctx, state) => _slideInFromBottom(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
          ),
        ],
      ),

      // ─── 全屏子页面 ───
      GoRoute(
        path: AppRoutes.wordDetail,
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return _slideInFromRight(
            key: state.pageKey,
            child: WordDetailPage(word: Word(id: id, userId: '', word: '', meaning: '')),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addWord,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const AddWordPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.review,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: ReviewPage(words: []),
        ),
      ),
      GoRoute(
        path: AppRoutes.wordTest,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: WordTestPage(words: []),
        ),
      ),
      GoRoute(
        path: AppRoutes.listening,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const ListeningPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.speaking,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const SpeakingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.writing,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const WritingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.studyPlan,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const StudyPlanPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.shop,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const ShopPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const LeaderboardPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.membership,
        pageBuilder: (ctx, state) => _slideInFromRight(
          key: state.pageKey,
          child: const MembershipPage(),
        ),
      ),
    ],
  );
}

/// 首页 Tab（Dashboard）
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NinjaColors.background,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Word Ninja'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.medal),
            tooltip: '排行榜',
            onPressed: () => context.push(AppRoutes.leaderboard),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          // 等级卡片 — 带有渐变背景
          _LevelCard(),
          const SizedBox(height: NinjaSpacing.lg),

          // 今日任务
          SectionHeader(title: '今日任务', icon: const Icon(PhosphorIconsRegular.checkSquare, size: 18, color: NinjaColors.primary)),
          const SizedBox(height: NinjaSpacing.sm),
          _TaskItem(
            icon: NinjaIcon.scroll(size: 20, color: NinjaColors.primary),
            title: '学习 20 个单词',
            route: AppRoutes.vocabulary,
          ),
          _TaskItem(
            icon: NinjaIcon.scroll(size: 20, color: NinjaColors.primary),
            title: '阅读 1 篇文章',
            route: AppRoutes.reading,
          ),
          _TaskItem(
            icon: NinjaIcon.chatBubble(size: 20, color: NinjaColors.primary),
            title: 'AI 对话 10 分钟',
            route: AppRoutes.aiTutor,
          ),

          const SizedBox(height: NinjaSpacing.lg),

          // 快捷入口
          SectionHeader(title: '忍者修炼', icon: NinjaIcon.sword(size: 20, color: NinjaColors.primary)),
          const SizedBox(height: NinjaSpacing.sm),
          Wrap(
            spacing: NinjaSpacing.sm,
            runSpacing: NinjaSpacing.sm,
            children: [
              _QuickChip('单词', NinjaIcon.scroll(size: 16, color: NinjaColors.primary), AppRoutes.vocabulary),
              _QuickChip('阅读', NinjaIcon.scroll(size: 16, color: NinjaColors.primary), AppRoutes.reading),
              _QuickChip('听力', NinjaIcon.headphone(size: 16, color: NinjaColors.primary), AppRoutes.listening),
              _QuickChip('口语', NinjaIcon.mic(size: 16, color: NinjaColors.primary), AppRoutes.speaking),
              _QuickChip('写作', NinjaIcon.pen(size: 16, color: NinjaColors.primary), AppRoutes.writing),
              _QuickChip('AI导师', NinjaIcon.chatBubble(size: 16, color: NinjaColors.primary), AppRoutes.aiTutor),
              _QuickChip('网页', const Icon(PhosphorIconsRegular.globe, size: 16, color: NinjaColors.primary), AppRoutes.webReader),
              _QuickChip('计划', NinjaIcon.calendar(size: 16, color: NinjaColors.primary), AppRoutes.studyPlan),
              _QuickChip('商店', NinjaIcon.coin(size: 16, color: NinjaColors.primary), AppRoutes.shop),
            ],
          ),
        ],
      ),
    );
  }
}

/// 等级卡片 — 带渐变背景、动画经验条
class _LevelCard extends StatelessWidget {
  // 模拟数据，后续接入真实数据
  static const _level = 18;
  static const _rank = '下忍';
  static const _currentExp = 1250;
  static const _maxExp = 1500;

  @override
  Widget build(BuildContext context) {
    final progress = _currentExp / _maxExp;
    return Card(
      margin: EdgeInsets.zero,
      color: NinjaColors.surface,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              NinjaColors.primary.withValues(alpha: 0.08),
              NinjaColors.accentGold.withValues(alpha: 0.05),
              NinjaColors.surface,
            ],
          ),
        ),
        padding: const EdgeInsets.all(NinjaSpacing.xl),
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
                        NinjaColors.levelIntermediate,
                        NinjaColors.levelIntermediate,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: NinjaColors.levelIntermediate.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '$_level',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: NinjaSpacing.md),
                // 等级信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lv.$_level · $_rank',
                        style: NinjaTextStyles.titleMedium,
                      ),
                      const SizedBox(height: NinjaSpacing.xxs),
                      Text(
                        '距离升级还需 ${_maxExp - _currentExp} EXP',
                        style: NinjaTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                NinjaIcon.mountain(size: 32, color: NinjaColors.accentGold.withValues(alpha: 0.3)),
              ],
            ),
            const SizedBox(height: NinjaSpacing.md),
            // 经验条
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: NinjaColors.divider.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  NinjaColors.accentGold,
                ),
              ),
            ),
            const SizedBox(height: NinjaSpacing.sm),
            // EXP 数字
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NinjaIcon.coin(size: 14, color: NinjaColors.accentGold),
                  const SizedBox(width: NinjaSpacing.xxs),
                  Text(
                    '$_currentExp / $_maxExp',
                    style: NinjaTextStyles.caption.copyWith(
                      color: NinjaColors.accentGold,
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
        const SizedBox(width: NinjaSpacing.sm),
        Text(title, style: NinjaTextStyles.heading3),
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

class _TaskItemState extends State<_TaskItem> with SingleTickerProviderStateMixin {
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
          margin: const EdgeInsets.only(bottom: NinjaSpacing.xs),
          color: NinjaColors.surface,
          surfaceTintColor: Colors.transparent,
          child: ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: NinjaColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(NinjaSpacing.sm),
              ),
              child: Center(child: widget.icon),
            ),
            title: Text(widget.title, style: NinjaTextStyles.bodyMedium),
            trailing: const Icon(PhosphorIconsRegular.caretRight, size: 18, color: NinjaColors.textSecondary),
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
      label: Text(label, style: NinjaTextStyles.bodySmall),
      onPressed: () => context.push(route),
      backgroundColor: NinjaColors.primary.withValues(alpha: 0.08),
      side: BorderSide.none,
    );
  }
}
