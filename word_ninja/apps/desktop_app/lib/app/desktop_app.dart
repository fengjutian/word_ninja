import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mt;
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ninja_theme/theme_data.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;
import 'package:vocabulary/presentation/pages/vocabulary_page.dart';
import 'package:vocabulary/presentation/pages/word_detail_page.dart';
import 'package:vocabulary/presentation/pages/add_word_page.dart';
import 'package:vocabulary/presentation/pages/review_page.dart';
import 'package:vocabulary/presentation/pages/word_test_page.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:reading/presentation/pages/reader_page.dart';
import 'package:ai_tutor/pages/tutor_chat_page.dart';
import 'package:ai/pages/model_config_page.dart';
import '../debug_overlay.dart';
import 'package:window_manager/window_manager.dart';
import 'package:core/storage/preferences.dart';

/// Desktop app root widget — uses fluent_ui for native Windows look & feel
class WordNinjaDesktopApp extends StatelessWidget {
  final GoRouter router;
  const WordNinjaDesktopApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      title: 'Word Ninja',
      debugShowCheckedModeBanner: false,
      theme: _ninjaFluentTheme(Brightness.light),
      darkTheme: _ninjaFluentTheme(Brightness.dark),
      themeMode:
          Preferences.getBool('dark_mode') ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      builder: kDebugMode ? _debugBuilder : null,
    );
  }

  /// Build a FluentThemeData from NinjaColors
  static FluentThemeData _ninjaFluentTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return FluentThemeData(
      brightness: brightness,
      accentColor: const AccentColor(
        darkest: Color(0xFFAB000D),
        darker: Color(0xFFC62828),
        dark: Color(0xFFD32F2F),
        normal: NinjaColors.primary,
        light: NinjaColors.primaryLight,
        lighter: Color(0xFFFF8A80),
        lightest: Color(0xFFFFCDD2),
      ),
      scaffoldBackgroundColor:
          isDark ? NinjaColors.surfaceDark : NinjaColors.background,
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor:
            isDark ? NinjaColors.surfaceDark : NinjaColors.surface,
        highlightColor: NinjaColors.primary.withValues(alpha: 0.08),
      ),
    );
  }

  static Widget _debugBuilder(BuildContext context, Widget? child) {
    final bool isActive = DebugOverlay.isActive;
    return Stack(children: [
      if (child != null) child,
      Positioned(
        right: 16,
        bottom: 40,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? mt.Colors.lightGreen : mt.Colors.grey.shade400,
            boxShadow: [
              BoxShadow(
                color: mt.Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: GestureDetector(
            onTap: DebugOverlay.toggleAll,
            child: Center(
              child: Icon(
                isActive ? FluentIcons.eye : FluentIcons.eye_hide,
                size: 18,
                color: mt.Colors.white,
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// Desktop route paths
class DesktopRoutes {
  static const String home = '/';
  static const String vocabulary = '/vocabulary';
  static const String wordDetail = '/vocabulary/detail/:id';
  static const String addWord = '/vocabulary/add';
  static const String review = '/vocabulary/review';
  static const String wordTest = '/vocabulary/test';
  static const String reading = '/reading';
  static const String aiTutor = '/ai-tutor';
  static const String modelConfig = '/model-config';
}

GoRouter createDesktopRouter() {
  return GoRouter(
    initialLocation: DesktopRoutes.home,
    routes: [
      ShellRoute(
        builder: (ctx, state, child) => DesktopShell(child: child),
        routes: [
          GoRoute(
              path: DesktopRoutes.home,
              builder: (ctx, state) => const _DesktopHome()),
          GoRoute(
              path: DesktopRoutes.vocabulary,
              builder: (ctx, state) => const VocabularyPage()),
          GoRoute(
              path: DesktopRoutes.reading,
              builder: (ctx, state) => const ReaderPage()),
          GoRoute(
              path: DesktopRoutes.aiTutor,
              builder: (ctx, state) => const TutorChatPage()),
          GoRoute(
              path: DesktopRoutes.modelConfig,
              builder: (ctx, state) => const ModelConfigPage()),
        ],
      ),
      // ─── 全屏子页面 ───
      GoRoute(
        path: DesktopRoutes.wordDetail,
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return mt.MaterialPage(
            key: state.pageKey,
            child: WordDetailPage(
                word: Word(id: id, userId: '', word: '', meaning: '')),
          );
        },
      ),
      GoRoute(
        path: DesktopRoutes.addWord,
        pageBuilder: (ctx, state) => mt.MaterialPage(
          key: state.pageKey,
          child: const AddWordPage(),
        ),
      ),
      GoRoute(
        path: DesktopRoutes.review,
        pageBuilder: (ctx, state) {
          final extra = state.extra;
          if (extra is List<Word> && extra.isNotEmpty) {
            return mt.MaterialPage(
              key: state.pageKey,
              child: ReviewPage(words: extra),
            );
          }
          return mt.MaterialPage(
            key: state.pageKey,
            child: ReviewPage(words: []),
          );
        },
      ),
      GoRoute(
        path: DesktopRoutes.wordTest,
        pageBuilder: (ctx, state) {
          final extra = state.extra;
          if (extra is List<Word> && extra.length >= 2) {
            return mt.MaterialPage(
              key: state.pageKey,
              child: WordTestPage(words: extra),
            );
          }
          return mt.MaterialPage(
            key: state.pageKey,
            child: WordTestPage(words: []),
          );
        },
      ),
    ],
  );
}

/// Desktop shell — fluent_ui NavigationView replaces old NavigationRail
class DesktopShell extends StatelessWidget {
  final Widget child;
  const DesktopShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    return NavigationView(
      paneBodyBuilder: (item, body) {
        // Wrap child pages in Material Theme so shared Material widgets
        // (from vocabulary, reading, ai_tutor, etc.) work inside FluentApp
        return mt.Theme(
          data: isDark ? NinjaTheme.dark : NinjaTheme.light,
          child: child,
        );
      },
      pane: NavigationPane(
        selected: _calcIndex(context),
        onChanged: (i) => _navigate(context, i),
        displayMode: PaneDisplayMode.expanded,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Home'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.library),
            title: const Text('Vocab'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.reading_mode),
            title: const Text('Reading'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.chat_bubbles_question),
            title: const Text('AI Tutor'),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('模型配置'),
          ),
        ],
      ),
    );
  }

  int _calcIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith(DesktopRoutes.vocabulary)) return 1;
    if (uri.startsWith(DesktopRoutes.reading)) return 2;
    if (uri.startsWith(DesktopRoutes.aiTutor)) return 3;
    if (uri.startsWith(DesktopRoutes.modelConfig)) return 4;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(DesktopRoutes.home);
      case 1:
        context.go(DesktopRoutes.vocabulary);
      case 2:
        context.go(DesktopRoutes.reading);
      case 3:
        context.go(DesktopRoutes.aiTutor);
      case 4:
        context.go(DesktopRoutes.modelConfig);
    }
  }
}

class _DesktopHome extends StatelessWidget {
  const _DesktopHome();

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    return ScaffoldPage(
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NinjaIcon.shuriken(size: 64, color: NinjaColors.primary),
            const SizedBox(height: NinjaSpacing.lg),
            Text(
              'Word Ninja',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? NinjaColors.textOnDark : NinjaColors.textPrimary,
              ),
            ),
            const SizedBox(height: NinjaSpacing.sm),
            Text(
              '你的 AI 英语忍者修炼之路',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? NinjaColors.textOnDark.withValues(alpha: 0.7)
                    : NinjaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
