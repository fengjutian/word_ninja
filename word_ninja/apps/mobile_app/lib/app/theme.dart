import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ninja_theme/theme_data.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;
import 'router.dart';

/// 应用主题配置
class AppThemeConfig {
  static ThemeData get light => NinjaTheme.light;
  static ThemeData get dark => NinjaTheme.dark;
}

/// 底部导航栏图标数据
class _NavIcon {
  final String assetName;
  const _NavIcon(this.assetName);

  Widget build({required double size, required Color color}) =>
      NinjaIcon._(assetName, size: size, color: color);
}

/// 底部导航栏项
class _NavItem {
  final String label;
  final _NavIcon icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

final _navItems = const [
  _NavItem('修炼', _NavIcon('sword'), AppRoutes.home),
  _NavItem('单词', _NavIcon('scroll'), AppRoutes.vocabulary),
  _NavItem('AI导师', _NavIcon('chat_bubble'), AppRoutes.aiTutor),
  _NavItem('阅读', _NavIcon('scroll'), AppRoutes.reading),
  _NavItem('我的', _NavIcon('ninja_head'), AppRoutes.profile),
];

/// 主页面框架（含底部导航）
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _navItems.indexWhere((i) => location.startsWith(i.route));
    final idx = selectedIndex >= 0 ? selectedIndex : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_navItems[i].route),
        animationDuration: const Duration(milliseconds: 300),
        destinations: List.generate(_navItems.length, (i) {
          final isSelected = i == idx;
          final color = isSelected ? NinjaColors.primary : NinjaColors.textSecondary;
          final item = _navItems[i];
          return NavigationDestination(
            icon: item.icon.build(size: 22, color: color),
            selectedIcon: item.icon.build(size: 24, color: NinjaColors.primary),
            label: item.label,
          );
        }),
      ),
    );
  }
}
