import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/foundation.dart';  
import 'package:flutter/material.dart'; 
import 'package:go_router/go_router.dart'; 
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ninja_theme/theme_data.dart'; 
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;
import 'package:vocabulary/presentation/pages/vocabulary_page.dart'; 
import 'package:reading/presentation/pages/reader_page.dart'; 
import '../debug_overlay.dart';
import 'package:window_manager/window_manager.dart';
  
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
        child: Icon(DebugOverlay.isActive ? PhosphorIconsRegular.eye : PhosphorIconsRegular.eyeSlash, size: 20),  
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
          child: Text('??', style: TextStyle(fontSize: 24)),  
        ), 
        destinations: const [  
          NavigationRailDestination(icon: Icon(PhosphorIconsRegular.house), selectedIcon: Icon(PhosphorIconsRegular.house), label: Text('Home')),  
          NavigationRailDestination(icon: Icon(PhosphorIconsRegular.bookOpen), selectedIcon: Icon(PhosphorIconsRegular.bookOpen), label: Text('Vocab')),  
          NavigationRailDestination(icon: Icon(PhosphorIconsRegular.books), selectedIcon: Icon(PhosphorIconsRegular.books), label: Text('Reading')),  
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
      child: InkWell(  
        onTap: onTap,  
        child: Container(width: 46, height: 36, alignment: Alignment.center, child: Icon(icon, size: 18, color: isDark ? NinjaColors.textOnDark : NinjaColors.textPrimary)),  
        hoverColor: isClose ? NinjaColors.primary : NinjaColors.divider.withValues(alpha: 0.3),  
      ),  
    );  
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
