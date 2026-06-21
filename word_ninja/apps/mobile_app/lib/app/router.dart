import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:auth/lib/presentation/login/login_page.dart';
import 'package:auth/lib/presentation/register/register_page.dart';
import 'package:auth/lib/presentation/forgot_password/forgot_password_page.dart';
import 'package:vocabulary/lib/presentation/pages/vocabulary_page.dart';
import 'package:vocabulary/lib/presentation/pages/word_detail_page.dart';
import 'package:vocabulary/lib/presentation/pages/add_word_page.dart';
import 'package:vocabulary/lib/presentation/pages/review_page.dart';
import 'package:vocabulary/lib/presentation/pages/word_test_page.dart';
import 'package:vocabulary/lib/data/model/word.dart';
import 'package:reading/lib/presentation/pages/reader_page.dart';
import 'package:listening/lib/presentation/pages/listening_page.dart';
import 'package:speaking/lib/presentation/pages/speaking_page.dart';
import 'package:writing/lib/presentation/pages/writing_page.dart';
import 'package:ai_tutor/lib/pages/tutor_chat_page.dart';
import 'package:study_plan/lib/pages/study_plan_page.dart';
import 'package:achievement/lib/pages/achievement_page.dart';
import 'package:shop/lib/pages/shop_page.dart';
import 'package:leaderboard/lib/pages/leaderboard_page.dart';
import 'package:profile/lib/pages/profile_page.dart';
import 'package:profile/lib/pages/settings_page.dart';
import 'package:profile/lib/pages/membership_page.dart';
import 'theme.dart';

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
  static const String listening = '/listening';
  static const String speaking = '/speaking';
  static const String writing = '/writing';
  static const String aiTutor = '/ai-tutor';
  static const String studyPlan = '/study-plan';
  static const String achievement = '/achievement';
  static const String shop = '/shop';
  static const String leaderboard = '/leaderboard';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String membership = '/membership';
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
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const ForgotPasswordPage(),
        ),
      ),

      // ─── 主页（带底部导航） ───
      ShellRoute(
        builder: (ctx, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const _HomeTab(),
            ),
          ),
          GoRoute(
            path: AppRoutes.vocabulary,
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const VocabularyPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.aiTutor,
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const TutorChatPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.reading,
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ReaderPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (ctx, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
          ),
        ],
      ),

      // ─── 全屏子页面 ───
      GoRoute(
        path: AppRoutes.wordDetail,
        builder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return WordDetailPage(word: Word(id: id, userId: '', word: '', meaning: ''));
        },
      ),
      GoRoute(
        path: AppRoutes.addWord,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const AddWordPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.review,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: ReviewPage(words: []),
        ),
      ),
      GoRoute(
        path: AppRoutes.wordTest,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: WordTestPage(words: []),
        ),
      ),
      GoRoute(
        path: AppRoutes.listening,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const ListeningPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.speaking,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const SpeakingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.writing,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const WritingPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.studyPlan,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const StudyPlanPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.achievement,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const AchievementPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.shop,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const ShopPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const LeaderboardPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (ctx, state) => NoTransitionPage(
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.membership,
        pageBuilder: (ctx, state) => NoTransitionPage(
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
      appBar: AppBar(
        title: const Text('🐢 Word Ninja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => context.push(AppRoutes.achievement),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.push(AppRoutes.leaderboard),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 等级卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text('等级', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Spacer(),
                      Text('Lv.18 · 下忍', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('1250 / 1500', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFFFB300))),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 1250 / 1500,
                      minHeight: 10,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 今日任务
          const Text('今日任务', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _TaskItem('📖 学习 20 个单词', AppRoutes.vocabulary, false),
          _TaskItem('📄 阅读 1 篇文章', AppRoutes.reading, false),
          _TaskItem('💬 AI 对话 10 分钟', AppRoutes.aiTutor, false),

          const SizedBox(height: 16),
          // 快捷入口
          const Text('忍者修炼', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickChip('单词', Icons.menu_book, AppRoutes.vocabulary),
              _QuickChip('阅读', Icons.auto_stories, AppRoutes.reading),
              _QuickChip('听力', Icons.hearing, AppRoutes.listening),
              _QuickChip('口语', Icons.record_voice_over, AppRoutes.speaking),
              _QuickChip('写作', Icons.edit, AppRoutes.writing),
              _QuickChip('AI导师', Icons.psychology, AppRoutes.aiTutor),
              _QuickChip('计划', Icons.calendar_today, AppRoutes.studyPlan),
              _QuickChip('商店', Icons.shopping_bag, AppRoutes.shop),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title;
  final String route;
  final bool done;

  const _TaskItem(this.title, this.route, this.done);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? Colors.green : Colors.grey),
        title: Text(title, style: TextStyle(decoration: done ? TextDecoration.lineThrough : null)),
        onTap: () => context.push(route),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;

  const _QuickChip(this.label, this.icon, this.route);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () => context.push(route),
    );
  }
}
