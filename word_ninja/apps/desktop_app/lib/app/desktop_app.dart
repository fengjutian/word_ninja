import 'package:flutter/foundation.dart';  
import 'package:flutter/material.dart'; 
import 'package:go_router/go_router.dart'; 
import 'package:ui_kit/ninja_theme/theme_data.dart'; 
import 'package:vocabulary/presentation/pages/vocabulary_page.dart'; 
import 'package:reading/presentation/pages/reader_page.dart'; 
import '../debug_overlay.dart'; 
  
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
      themeMode: ThemeMode.light,  
      routerConfig: router,  
      builder: kDebugMode ? _debugBuilder : null,  
    );  
  } 
  
  static Widget _debugBuilder(BuildContext context, Widget? child) {  
    return Stack(children: [  
      if (child != null) child,  
      Positioned(right: 16, bottom: 40, child: FloatingActionButton.small(  
        heroTag: '__debug_toggle__',  
        backgroundColor: DebugOverlay.isActive ? Colors.lightGreen : Colors.grey.shade400,  
        onPressed: DebugOverlay.toggleAll,  
        child: Icon(DebugOverlay.isActive ? Icons.visibility : Icons.visibility_off, size: 20),  
      )),  
    ]);  
  }  
} 
  
/// Desktop route paths  
class DesktopRoutes {  
  static const String home = '/';  
  static const String vocabulary = '/vocabulary';  
  static const String reading = '/reading';  
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
        ],  
      ),  
    ],  
  );  
} 
  
/// Desktop shell with left navigation rail  
class DesktopShell extends StatelessWidget {  
  final Widget child;  
  const DesktopShell({super.key, required this.child});  
  
  @override  
  Widget build(BuildContext context) {  
    return Row(children: [  
      NavigationRail(  
        selectedIndex: _calcIndex(context),  
        onDestinationSelected: (i) => _navigate(context, i), 
        labelType: NavigationRailLabelType.all,  
        leading: const Padding(  
          padding: EdgeInsets.symmetric(vertical: 8),  
          child: Text('??', style: TextStyle(fontSize: 24)),  
        ), 
        destinations: const [  
          NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),  
          NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: Text('Vocab')),  
          NavigationRailDestination(icon: Icon(Icons.auto_stories_outlined), selectedIcon: Icon(Icons.auto_stories), label: Text('Reading')),  
        ], 
      ),  
      const VerticalDivider(width: 1),  
      Expanded(child: child),  
    ]);  
  } 
  
  int _calcIndex(BuildContext context) {  
    final uri = GoRouterState.of(context).uri.toString();  
    if (uri.startsWith(DesktopRoutes.vocabulary)) return 1;  
    if (uri.startsWith(DesktopRoutes.reading)) return 2;  
    return 0;  
  } 
  
  void _navigate(BuildContext context, int index) {  
    switch (index) {  
      case 0: context.go(DesktopRoutes.home);  
      case 1: context.go(DesktopRoutes.vocabulary);  
      case 2: context.go(DesktopRoutes.reading);  
    }  
  }  
} 
  
class _DesktopHome extends StatelessWidget {  
  const _DesktopHome();  
  @override  
  Widget build(BuildContext context) {  
    return const Center(child: Text('Word Ninja Desktop', style: TextStyle(fontSize: 24)));  
  }  
} 
