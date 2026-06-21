import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ninja_theme/theme_data.dart';
import 'router.dart';

/// 应用主题配置
class AppThemeConfig {
  static ThemeData get light => NinjaTheme.light;
  static ThemeData get dark => NinjaTheme.dark;
}

/// 导航项配置
class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _NavItem(this.label, this.icon, this.activeIcon, this.route);
}

/// 底部导航栏项（Material Icons — SVG 图标在 NavigationBar 中须包裹为 Widget，暂用 Material 图标保证最佳兼容）
const List<_NavItem> _navItems = [
  _NavItem('修炼', Icons.home_outlined, Icons.home, AppRoutes.home),
  _NavItem('单词', Icons.menu_book_outlined, Icons.menu_book, AppRoutes.vocabulary),
  _NavItem('AI导师', Icons.psychology_outlined, Icons.psychology, AppRoutes.aiTutor),
  _NavItem('阅读', Icons.auto_stories_outlined, Icons.auto_stories, AppRoutes.reading),
  _NavItem('我的', Icons.person_outline, Icons.person, AppRoutes.profile),
];

/// 主页面框架（含底部导航）
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _navItems.indexWhere((item) => location.startsWith(item.route));

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index >= 0 ? index : 0,
        onDestinationSelected: (i) => context.go(_navItems[i].route),
        animationDuration: const Duration(milliseconds: 300),
        indicatorColor: NinjaColors.primary.withValues(alpha: 0.15),
        destinations: _navItems
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}
