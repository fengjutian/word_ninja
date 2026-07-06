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
      accentColor: AccentColor('normal', {
        'darkest': Color(0xFFAB000D),
        'darker': Color(0xFFC62828),
        'dark': Color(0xFFD32F2F),
        'normal': NinjaColors.primary,
        'light': NinjaColors.primaryLight,
        'lighter': Color(0xFFFF8A80),
        'lightest': Color(0xFFFFCDD2),
      }),
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
                isActive ? FluentIcons.view : FluentIcons.view,
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
      titleBar: _buildTitleBar(context, isDark),
      paneBodyBuilder: (item, body) {
        return mt.Theme(
          data: isDark ? NinjaTheme.dark : NinjaTheme.light,
          child: child,
        );
      },
      pane: NavigationPane(
        selected: _calcIndex(context),
        onChanged: (i) => _navigate(context, i),
        displayMode: PaneDisplayMode.compact,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.home),
            title: const Text('Home'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.bookmarks),
            title: const Text('Vocab'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.reading_mode),
            title: const Text('Reading'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.chat),
            title: const Text('AI Tutor'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('模型配置'),
            body: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Custom title bar with window controls (drag, min/max/close)
  Widget _buildTitleBar(BuildContext context, bool isDark) {
    return GestureDetector(
      onDoubleTap: () => windowManager.isMaximized().then(
            (m) => m ? windowManager.unmaximize() : windowManager.maximize(),
          ),
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 36,
        color: isDark ? NinjaColors.surfaceDark : NinjaColors.surface,
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(children: [
              const PaneToggleButton(),
              const SizedBox(width: 4),
              Text('\u{1F977}',
                  style: TextStyle(
                      fontSize: 18,
                      color: isDark
                          ? NinjaColors.textOnDark
                          : NinjaColors.textPrimary)),
              const SizedBox(width: 8),
              Text('Word Ninja',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? NinjaColors.textOnDark
                          : NinjaColors.textPrimary)),
            ]),
          ),
          const Spacer(),
          _WindowBtn(
              label: '\u{2014}', tooltip: 'Minimize',
              isDark: isDark,
              onTap: () => windowManager.minimize()),
          _WindowBtn(
              label: '\u{25A1}', tooltip: 'Maximize',
              isDark: isDark,
              onTap: () => windowManager
                  .isMaximized()
                  .then((m) => m
                      ? windowManager.unmaximize()
                      : windowManager.maximize())),
          _WindowBtn(
              label: '\u{2715}', tooltip: 'Close',
              isDark: isDark, isClose: true,
              onTap: () => windowManager.close()),
        ]),
      ),
    );
  }

  Widget _WindowBtn(
      {required String label,
      required String tooltip,
      required VoidCallback onTap,
      required bool isDark,
      bool isClose = false}) {
    return Tooltip(
      message: tooltip,
      child: mt.Material(
        color: mt.Colors.transparent,
        child: mt.InkWell(
          onTap: onTap,
          hoverColor:
              isClose ? NinjaColors.primary : NinjaColors.divider.withValues(alpha: 0.3),
          child: Container(
            width: 46,
            height: 36,
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? NinjaColors.textOnDark
                        : NinjaColors.textPrimary)),
          ),
        ),
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
