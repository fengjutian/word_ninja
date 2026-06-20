import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';
import 'package:vocabulary/lib/presentation/pages/vocabulary_page.dart';
import 'package:ai_tutor/lib/pages/tutor_chat_page.dart';
import 'package:reading/lib/presentation/pages/reader_page.dart';

/// 桌面端路由
class DesktopRoutes {
  static const String home = '/';
  static const String vocabulary = '/vocabulary';
  static const String aiTutor = '/ai-tutor';
  static const String reading = '/reading';
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
            builder: (ctx, state) => const _DesktopHome(),
          ),
          GoRoute(
            path: DesktopRoutes.vocabulary,
            builder: (ctx, state) => const VocabularyPage(),
          ),
          GoRoute(
            path: DesktopRoutes.aiTutor,
            builder: (ctx, state) => const TutorChatPage(),
          ),
          GoRoute(
            path: DesktopRoutes.reading,
            builder: (ctx, state) => const ReaderPage(),
          ),
        ],
      ),
    ],
  );
}

/// 桌面端主框架（左侧导航 + 多窗口布局）
class DesktopShell extends StatelessWidget {
  final Widget child;
  const DesktopShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _calcIndex(context),
          onDestinationSelected: (i) => _navigate(context, i),
          labelType: NavigationRailLabelType.all,
          leading: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('🐢', style: TextStyle(fontSize: 24)),
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: Text('首页'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: Text('单词'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.psychology_outlined),
              selectedIcon: Icon(Icons.psychology),
              label: Text('AI导师'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories),
              label: Text('阅读'),
            ),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(child: child),
      ],
    );
  }

  int _calcIndex(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith(DesktopRoutes.vocabulary)) return 1;
    if (uri.startsWith(DesktopRoutes.aiTutor)) return 2;
    if (uri.startsWith(DesktopRoutes.reading)) return 3;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(DesktopRoutes.home);
      case 1: context.go(DesktopRoutes.vocabulary);
      case 2: context.go(DesktopRoutes.aiTutor);
      case 3: context.go(DesktopRoutes.reading);
    }
  }
}

class _DesktopHome extends StatelessWidget {
  const _DesktopHome();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Word Ninja Desktop', style: TextStyle(fontSize: 24)),
    );
  }
}
