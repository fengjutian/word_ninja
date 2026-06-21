import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'router.dart';

/// 应用主题配置
class AppThemeConfig {
  static ThemeData get light => NinjaTheme.light;
  static ThemeData get dark => NinjaTheme.dark;
}

/// 底部导航栏项定义
const List<_NavItem> _navItems = [
  _NavItem('修炼', Icons.home_outlined, Icons.home, AppRoutes.home),
  _NavItem('单词', Icons.menu_book_outlined, Icons.menu_book, AppRoutes.vocabulary),
  _NavItem('AI导师', Icons.psychology_outlined, Icons.psychology, AppRoutes.aiTutor),
  _NavItem('阅读', Icons.auto_stories_outlined, Icons.auto_stories, AppRoutes.reading),
  _NavItem('我的', Icons.person_outline, Icons.person, AppRoutes.profile),
];

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  const _NavItem(this.label, this.icon, this.activeIcon, this.route);
}

/// 主页面框架（含底部导航）
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 通过当前路径匹配选中的 tab
    final location = GoRouterState.of(context).uri.toString();
    final index = _navItems.indexWhere((item) => location.startsWith(item.route));

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index >= 0 ? index : 0,
        onTap: (i) => context.go(_navItems[i].route),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: NinjaColors.primary,
        unselectedItemColor: NinjaColors.textSecondary,
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}
