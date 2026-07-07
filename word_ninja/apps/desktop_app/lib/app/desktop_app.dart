import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ninja_theme/theme_data.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;
import 'package:vocabulary/presentation/pages/word_graph_page.dart';
import 'package:vocabulary/presentation/pages/vocabulary_page.dart';
import 'package:vocabulary/presentation/pages/word_detail_page.dart';
import 'package:vocabulary/presentation/pages/add_word_page.dart';
import 'package:vocabulary/presentation/pages/review_page.dart';
import 'package:vocabulary/presentation/pages/word_test_page.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/data/model/vocabulary_stats.dart';
import 'package:vocabulary/presentation/providers/word_provider.dart';
import 'package:reading/presentation/pages/reader_page.dart';
import 'package:ai_tutor/pages/tutor_chat_page.dart';
import 'package:ai/pages/model_config_page.dart';
import 'package:writing/presentation/pages/writing_page.dart';
import 'package:study_plan/pages/study_plan_page.dart';
import 'package:profile/pages/profile_page.dart';
import 'package:profile/pages/settings_page.dart';
import 'package:listening/presentation/pages/listening_page.dart';
import 'package:speaking/presentation/pages/speaking_page.dart';
import '../debug_overlay.dart';
import '../providers/wallpaper_provider.dart';
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
  static const String wordGraph = '/vocabulary/graph';
  static const String reading = '/reading';
  static const String aiTutor = '/ai-tutor';
  static const String modelConfig = '/model-config';
  static const String writing = '/writing';
  static const String studyPlan = '/study-plan';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String listening = '/listening';
  static const String speaking = '/speaking';
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
          GoRoute(
              path: DesktopRoutes.writing,
              builder: (ctx, state) => const WritingPage()),
          GoRoute(
              path: DesktopRoutes.studyPlan,
              builder: (ctx, state) => const StudyPlanPage()),
          GoRoute(
              path: DesktopRoutes.profile,
              builder: (ctx, state) => const ProfilePage()),
          GoRoute(
              path: DesktopRoutes.settings,
              builder: (ctx, state) => const SettingsPage()),
          GoRoute(
              path: DesktopRoutes.listening,
              builder: (ctx, state) => const ListeningPage()),
          GoRoute(
              path: DesktopRoutes.speaking,
              builder: (ctx, state) => const SpeakingPage()),
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
      GoRoute(
        path: DesktopRoutes.wordGraph,
        pageBuilder: (ctx, state) {
          final extra = state.extra;
          if (extra is List<Word>) {
            return mt.MaterialPage(
              key: state.pageKey,
              child: WordGraphPage(words: extra),
            );
          }
          return mt.MaterialPage(
            key: state.pageKey,
            child: WordGraphPage(words: []),
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
          child: Builder(
            builder: (ctx) => mt.Material(
              child: mt.ScaffoldMessenger(
                child: child,
              ),
            ),
          ),
        );
      },
      pane: NavigationPane(
        selected: _calcIndex(context),
        onChanged: (i) => _navigate(context, i),
        displayMode: PaneDisplayMode.compact,
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text('🥷',
              style: TextStyle(
                  fontSize: 28,
                  color: isDark
                      ? NinjaColors.textOnDark
                      : NinjaColors.textPrimary)),
        ),
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
            icon: const Icon(FluentIcons.headset),
            title: const Text('Listening'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.microphone),
            title: const Text('Speaking'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.chat),
            title: const Text('AI Tutor'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.design),
            title: const Text('Writing'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.task_list),
            title: const Text('Study Plan'),
            body: const SizedBox.shrink(),
          ),
        ],
        footerItems: [
          PaneItem(
            icon: const Icon(FluentIcons.settings),
            title: const Text('模型配置'),
            body: const SizedBox.shrink(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact),
            title: const Text('Profile'),
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
    if (uri.startsWith(DesktopRoutes.listening)) return 3;
    if (uri.startsWith(DesktopRoutes.speaking)) return 4;
    if (uri.startsWith(DesktopRoutes.aiTutor)) return 5;
    if (uri.startsWith(DesktopRoutes.writing)) return 6;
    if (uri.startsWith(DesktopRoutes.studyPlan)) return 7;
    if (uri.startsWith(DesktopRoutes.modelConfig)) return 8;
    if (uri.startsWith(DesktopRoutes.profile) ||
        uri.startsWith(DesktopRoutes.settings)) return 9;
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
        context.go(DesktopRoutes.listening);
      case 4:
        context.go(DesktopRoutes.speaking);
      case 5:
        context.go(DesktopRoutes.aiTutor);
      case 6:
        context.go(DesktopRoutes.writing);
      case 7:
        context.go(DesktopRoutes.studyPlan);
      case 8:
        context.go(DesktopRoutes.modelConfig);
      case 9:
        context.go(DesktopRoutes.profile);
    }
  }
}

class _DesktopHome extends ConsumerWidget {
  const _DesktopHome();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? NinjaColors.textOnDark : NinjaColors.textPrimary;
    final subColor = isDark
        ? NinjaColors.textOnDark.withValues(alpha: 0.6)
        : NinjaColors.textSecondary;

    // Try to load stats (may fail if vocabulary not yet initialized)
    final statsAsync = ref.watch(vocabularyStatsProvider);

    return ScaffoldPage(
      padding: const EdgeInsets.all(24),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              NinjaIcon.shuriken(size: 40, color: NinjaColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🥷 Word Ninja',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor)),
                  Text('你的 AI 英语忍者修炼之路',
                      style: TextStyle(fontSize: 13, color: subColor)),
                ],
              ),
            ]),
            const SizedBox(height: 24),

            // Stats cards
            statsAsync.when(
              data: (stats) => _buildStatsRow(stats, textColor, subColor),
              loading: () => const SizedBox.shrink(),
              error: (_, __) =>
                  const SizedBox.shrink(), // silently skip if not available
            ),
            const SizedBox(height: 20),

            // Wallpaper toggle
            Checkbox(
              content: const Text('桌面壁纸模式'),
              checked: ref.watch(wallpaperModeProvider),
              onChanged: (v) => ref.read(wallpaperModeProvider.notifier).state = v,
            ),
            Text('开启后按 Alt+W 或再次点击关闭',
                style: TextStyle(fontSize: 11, color: subColor)),

            // Quick actions
            Text('快捷入口',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _QuickCard(
                    icon: FluentIcons.bookmarks,
                    label: '单词本',
                    color: NinjaColors.secondary,
                    onTap: () => context.go(DesktopRoutes.vocabulary)),
                _QuickCard(
                    icon: FluentIcons.reading_mode,
                    label: '阅读',
                    color: NinjaColors.success,
                    onTap: () => context.go(DesktopRoutes.reading)),
                _QuickCard(
                    icon: FluentIcons.chat,
                    label: 'AI Tutor',
                    color: NinjaColors.accentPurple,
                    onTap: () => context.go(DesktopRoutes.aiTutor)),
                _QuickCard(
                    icon: FluentIcons.design,
                    label: '写作',
                    color: NinjaColors.info,
                    onTap: () => context.go(DesktopRoutes.writing)),
                _QuickCard(
                    icon: FluentIcons.task_list,
                    label: '学习计划',
                    color: NinjaColors.accentGold,
                    onTap: () => context.go(DesktopRoutes.studyPlan)),
                _QuickCard(
                    icon: FluentIcons.headset,
                    label: '听力',
                    color: NinjaColors.levelAdvanced,
                    onTap: () => context.go(DesktopRoutes.listening)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(VocabularyStats stats, Color textColor, Color subColor) {
    final items = [
      _StatItem(stats.totalWords.toString(), '总词汇', NinjaColors.primary),
      _StatItem(stats.masteredWords.toString(), '已掌握', NinjaColors.success),
      _StatItem(stats.todayReview.toString(), '今日复习', NinjaColors.accentGold),
      _StatItem(stats.learningWords.toString(), '待复习', NinjaColors.warning),
    ];
    return Row(
      children: items.map((s) => Expanded(child: s)).toList(),
    );
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
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: NinjaColors.textSecondary)),
        ]),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCard(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Button(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(fontSize: 13, color: color),
                textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
