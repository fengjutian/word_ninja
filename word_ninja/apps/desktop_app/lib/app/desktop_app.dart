import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/theme_data.dart';
import 'package:ui_kit/ui_kit.dart' show AppIcon;
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
import 'package:ai_tutor/pages/analysis_page.dart';
import 'package:ai/pages/model_config_page.dart';
import 'package:writing/presentation/pages/writing_page.dart';
import 'package:study_plan/pages/study_plan_page.dart';
import 'package:profile/pages/profile_page.dart';
import 'package:profile/pages/settings_page.dart';
import 'package:listening/presentation/pages/listening_page.dart';
import 'package:speaking/presentation/pages/speaking_page.dart';
import '../debug_overlay.dart';
import 'package:window_manager/window_manager.dart';
import 'package:core/storage/preferences.dart';

part 'desktop_routes.dart';
part 'desktop_shell.dart';
part 'desktop_home.dart';

/// Desktop app root widget — uses fluent_ui for native Windows look & feel
class WordFlowDesktopApp extends StatelessWidget {
  final GoRouter router;
  const WordFlowDesktopApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      title: 'WordFlow',
      debugShowCheckedModeBanner: false,
      theme: _appFluentTheme(Brightness.light),
      darkTheme: _appFluentTheme(Brightness.dark),
      themeMode: Preferences.getBool('dark_mode')
          ? ThemeMode.dark
          : ThemeMode.light,
      routerConfig: router,
      builder: kDebugMode ? _debugBuilder : null,
    );
  }

  /// Build a FluentThemeData from AppColors
  static FluentThemeData _appFluentTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return FluentThemeData(
      brightness: brightness,
      accentColor: AccentColor('normal', {
        'darkest': Color(0xFFAB000D),
        'darker': Color(0xFFC62828),
        'dark': Color(0xFFD32F2F),
        'normal': AppColors.primary,
        'light': AppColors.primaryLight,
        'lighter': Color(0xFFFF8A80),
        'lightest': Color(0xFFFFCDD2),
      }),
      scaffoldBackgroundColor: isDark
          ? AppColors.surfaceDark
          : AppColors.background,
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        highlightColor: AppColors.primary.withValues(alpha: 0.08),
      ),
    );
  }

  static Widget _debugBuilder(BuildContext context, Widget? child) {
    final bool isActive = DebugOverlay.isActive;
    return Stack(
      children: [
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
      ],
    );
  }
}
