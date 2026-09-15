import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as mt;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/theme_data.dart';
import 'package:ui_kit/app_theme/design_tokens.dart';
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
    final themeMode = Preferences.getBool('dark_mode')
        ? mt.ThemeMode.dark
        : mt.ThemeMode.light;
    return mt.MaterialApp.router(
      title: 'WordFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(AppThemeCatalog.indigo, Brightness.light),
      darkTheme: AppTheme.build(AppThemeCatalog.indigo, Brightness.dark),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final brightness = mt.Theme.of(context).brightness;
        final content = FluentTheme(
          data: _appFluentTheme(AppThemeCatalog.indigo, brightness),
          child: child ?? const SizedBox.shrink(),
        );
        return kDebugMode ? _debugBuilder(context, content) : content;
      },
    );
  }

  /// Build a FluentThemeData from AppColors
  static FluentThemeData _appFluentTheme(
    AppThemePreset preset,
    Brightness brightness,
  ) {
    final isDark = brightness == Brightness.dark;
    final tokens = AppColorTokens.forPreset(preset, brightness);
    final accent = preset.seed;
    return FluentThemeData(
      brightness: brightness,
      accentColor: AccentColor('normal', {
        'darkest': Color.lerp(accent, const Color(0xFF000000), 0.45)!,
        'darker': Color.lerp(accent, const Color(0xFF000000), 0.30)!,
        'dark': Color.lerp(accent, const Color(0xFF000000), 0.15)!,
        'normal': accent,
        'light': Color.lerp(accent, const Color(0xFFFFFFFF), 0.18)!,
        'lighter': Color.lerp(accent, const Color(0xFFFFFFFF), 0.38)!,
        'lightest': Color.lerp(accent, const Color(0xFFFFFFFF), 0.72)!,
      }),
      scaffoldBackgroundColor: tokens.canvas,
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: tokens.sidebar,
        highlightColor: accent.withValues(alpha: isDark ? 0.18 : 0.10),
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
