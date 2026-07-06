import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/foundation.dart';  
import 'package:flutter/material.dart'; 
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
  
/// Desktop app root widget 
class WordNinjaDesktopApp extends StatelessWidget { 
  final GoRouter router; 
  const WordNinjaDesktopApp({super.key, required this.router}); 
  
  @override  
  Widget build(BuildContext context) { 
    return MaterialApp.router(  
      title: 'Word Ninja',  
      debugShowCheckedModeBanner: false,  
      theme: NinjaTheme.light,  
      darkTheme: NinjaTheme.dark,  
      themeMode: Preferences.getBool('dark_mode') ? ThemeMode.dark : ThemeMode.light,  
      routerConfig: router,  
      builder: kDebugMode ? _debugBuilder : null,  
    );  
  } 
  
  static Widget _debugBuilder(BuildContext context, Widget? child) {  
    // Use Material+InkWell (self-contained) instead of FloatingActionButton to avoid
    // requiring Scaffold/Material ancestor context in MaterialApp.router's builder
    final bool isActive = DebugOverlay.isActive;
    return Stack(children: [  
      if (child != null) child,  
      Positioned(
        right: 16, bottom: 40,
        child: Material(
          elevation: 4,
          shape: const CircleBorder(),
          color: isActive ? Colors.lightGreen : Colors.grey.shade400,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: DebugOverlay.toggleAll,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(isActive ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash, size: 20, color: Colors.white),
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
          GoRoute(path: DesktopRoutes.home, builder: (ctx, state) => const _DesktopHome()),  
          GoRoute(path: DesktopRoutes.vocabulary, builder: (ctx, state) => const VocabularyPage()),  
          GoRoute(path: DesktopRoutes.reading, builder: (ctx, state) => const ReaderPage()), 
          GoRoute(path: DesktopRoutes.aiTutor, builder: (ctx, state) => const TutorChatPage()), 
          GoRoute(path: DesktopRoutes.modelConfig, builder: (ctx, state) => const ModelConfigPage()),
        ],  
      ),  
      // ─── 全屏子页面 ───
      GoRoute(
        path: DesktopRoutes.wordDetail,
        pageBuilder: (ctx, state) {
          final id = state.pathParameters['id'] ?? '';
          return MaterialPage(
            key: state.pageKey,
            child: WordDetailPage(word: Word(id: id, userId: '', word: '', meaning: '')),
          );
        },
      ),
      GoRoute(
        path: DesktopRoutes.addWord,
        pageBuilder: (ctx, state) => MaterialPage(
          key: state.pageKey,
          child: const AddWordPage(),
        ),
      ),
      GoRoute(
        path: DesktopRoutes.review,
        pageBuilder: (ctx, state) {
          final extra = state.extra;
          if (extra is List<Word> && extra.isNotEmpty) {
            return MaterialPage(
              key: state.pageKey,
              child: ReviewPage(words: extra),
            );
          }
          return MaterialPage(
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
            return MaterialPage(
              key: state.pageKey,
              child: WordTestPage(words: extra),
            );
          }
          return MaterialPage(
            key: state.pageKey,
            child: WordTestPage(words: []),
          );
        },
      ),
    ],  
  );  
} 
  
/// Desktop shell with left navigation rail and custom title bar
class DesktopShell extends StatelessWidget {  
  final Widget child;  
  const DesktopShell({super.key, required this.child});  
  
  @override  
  Widget build(BuildContext context) {  
    return Column(children: [  
      _buildTitleBar(context),  
      Expanded(child: Row(children: [  
      NavigationRail(  
        selectedIndex: _calcIndex(context),  
        onDestinationSelected: (i) => _navigate(context, i), 
        labelType: NavigationRailLabelType.all,  
        leading: const Padding(  
          padding: EdgeInsets.symmetric(vertical: 8),  
          child: Text('忍者', style: TextStyle(fontSize: 24)),  
        ), 
        destinations: const [  
          NavigationRailDestination(icon: Icon(PhosphorIconsRegular.house), selectedIcon: Icon(PhosphorIconsRegular.house), label: Text('Home')),  
          NavigationRailDestination(icon: Icon(PhosphorIconsRegular.bookOpen), selectedIcon: Icon(PhosphorIconsRegular.bookOpen), label: Text('Vocab')),  
          NavigationRailDestination(icon: Icon(PhosphorIconsRegular.books), selectedIcon: Icon(PhosphorIconsRegular.books), label: Text('Reading')),  
          NavigationRailDestination(icon: Icon(PhosphorIconsRegular.chatTeardrop), selectedIcon: Icon(PhosphorIconsRegular.chatTeardrop), label: Text('AI Tutor')),  
          NavigationRailDestination(icon: Icon(PhosphorIconsRegular.gear), selectedIcon: Icon(PhosphorIconsRegular.gear), label: Text('模型配置')),  
        ], 
      ),  
      const VerticalDivider(width: 1),  
      Expanded(child: child),  
    ])),  
    ]);  
  }  
  // --- Ninja Title Bar ---  
  Widget _buildTitleBar(BuildContext context) {  
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            padding: EdgeInsets.only(left: 12),  
            child: Row(children: [  
              Text('\u{1F977}', style: TextStyle(fontSize: 18, color: isDark ? NinjaColors.textOnDark : NinjaColors.textPrimary)),  
              SizedBox(width: 8),  
              Text('Word Ninja', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? NinjaColors.textOnDark : NinjaColors.textPrimary)),  
            ]),  
          ), 
          const Spacer(),  
          _WindowBtn(icon: Icons.visibility_off_outlined, tooltip: 'Hide', isDark: isDark, onTap: () => windowManager.hide()),  
          _WindowBtn(icon: Icons.minimize_rounded, tooltip: 'Minimize', isDark: isDark, onTap: () => windowManager.minimize()),  
          _WindowBtn(icon: Icons.crop_square_rounded, tooltip: 'Maximize', isDark: isDark, onTap: () => windowManager.isMaximized().then((m) => m ? windowManager.unmaximize() : windowManager.maximize())),  
          _WindowBtn(icon: Icons.close_rounded, tooltip: 'Close', isDark: isDark, isClose: true, onTap: () => windowManager.close()),  
        ]),  
      ),  
    );  
  } 
  
  Widget _WindowBtn({required IconData icon, required String tooltip, required VoidCallback onTap, required bool isDark, bool isClose = false}) {  
    return Tooltip(  
      message: tooltip,  
      child: Material(  
        color: Colors.transparent,  
        child: InkWell(  
          onTap: onTap,  
          child: Container(width: 46, height: 36, alignment: Alignment.center, child: Icon(icon, size: 18, color: isDark ? NinjaColors.textOnDark : NinjaColors.textPrimary)),  
          hoverColor: isClose ? NinjaColors.primary : NinjaColors.divider.withValues(alpha: 0.3),  
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
      case 0: context.go(DesktopRoutes.home);  
      case 1: context.go(DesktopRoutes.vocabulary);  
      case 2: context.go(DesktopRoutes.reading);  
      case 3: context.go(DesktopRoutes.aiTutor);  
      case 4: context.go(DesktopRoutes.modelConfig);  
    }  
  }  
} 
  
class _DesktopHome extends StatelessWidget {  
  const _DesktopHome();  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(
      backgroundColor: NinjaColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NinjaIcon.shuriken(size: 64, color: NinjaColors.primary),
            const SizedBox(height: NinjaSpacing.lg),
            Text('Word Ninja', style: NinjaTextStyles.displayMedium),
            const SizedBox(height: NinjaSpacing.sm),
            Text('你的 AI 英语忍者修炼之路', style: NinjaTextStyles.bodyLarge),
          ],
        ),
      ),
    );  
  }  
} 
