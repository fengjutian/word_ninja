import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/theme_data.dart';
import 'package:ui_kit/ui_kit.dart' show AppIcon;
import 'router.dart';

/// 应用主题配置
class AppThemeConfig {
  static ThemeData get light => AppTheme.light;
  static ThemeData get dark => AppTheme.dark;
}

/// 底部导航栏项
class _NavItem {
  final String label;
  final Widget Function({required double size, required Color color}) icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

final _navItems = [
  _NavItem(
      '网页',
      ({required double size, required Color color}) =>
          Icon(PhosphorIconsRegular.globe, size: size, color: color),
      AppRoutes.webReader),
  _NavItem(
      '学习',
      ({required double size, required Color color}) =>
          AppIcon.learning(size: size, color: color),
      AppRoutes.home),
  _NavItem(
      '单词',
      ({required double size, required Color color}) =>
          AppIcon.scroll(size: size, color: color),
      AppRoutes.vocabulary),
  _NavItem(
      'AI导师',
      ({required double size, required Color color}) =>
          AppIcon.chatBubble(size: size, color: color),
      AppRoutes.aiTutor),
  _NavItem(
      '阅读',
      ({required double size, required Color color}) =>
          AppIcon.scroll(size: size, color: color),
      AppRoutes.reading),
  _NavItem(
      '我的',
      ({required double size, required Color color}) =>
          AppIcon.profile(size: size, color: color),
      AppRoutes.profile),
];

/// 主页面框架（含底部导航）
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex =
        _navItems.indexWhere((i) => location.startsWith(i.route));
    final idx = selectedIndex >= 0 ? selectedIndex : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_navItems[i].route),
        animationDuration: const Duration(milliseconds: 300),
        destinations: List.generate(_navItems.length, (i) {
          final isSelected = i == idx;
          final color =
              isSelected ? AppColors.primary : AppColors.textSecondary;
          final item = _navItems[i];
          return NavigationDestination(
            icon: item.icon(size: 22, color: color),
            selectedIcon: item.icon(size: 24, color: AppColors.primary),
            label: item.label,
          );
        }),
      ),
    );
  }
}
