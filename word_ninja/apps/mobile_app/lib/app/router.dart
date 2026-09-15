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
import 'package:profile/pages/profile_page.dart';
import 'package:profile/pages/settings_page.dart';
import 'package:profile/pages/membership_page.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/ui_kit.dart' show AppIcon;
import 'theme.dart';

part 'home_tab.dart';

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
            child: WordDetailPage(
                word: Word(id: id, userId: '', word: '', meaning: '')),
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
