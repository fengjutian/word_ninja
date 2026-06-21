import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ninja_theme/theme_data.dart';
import '../debug_overlay.dart';

/// App 根组件
class WordNinjaApp extends ConsumerWidget {
  final GoRouter router;

  const WordNinjaApp({super.key, required this.router});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

  /// 🔍 调试模式：右下角浮动按钮切换辅助线
  static Widget _debugBuilder(BuildContext context, Widget? child) {
    return Stack(
      children: [
        if (child != null) child,
        Positioned(
          right: 16,
          bottom: 40,
          child: FloatingActionButton.small(
            heroTag: '__debug_toggle__',
            backgroundColor: DebugOverlay.isActive
                ? Colors.lightGreen
                : Colors.grey.shade400,
            onPressed: DebugOverlay.toggleAll,
            child: Icon(
              DebugOverlay.isActive ? Icons.visibility : Icons.visibility_off,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
