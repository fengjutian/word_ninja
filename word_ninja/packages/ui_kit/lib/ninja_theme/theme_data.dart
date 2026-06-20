import 'package:flutter/material.dart';
import 'ninja_theme.dart';

/// 生成 Word Ninja 完整 ThemeData（浅色模式）
class NinjaTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: NinjaColors.primary,
        scaffoldBackgroundColor: NinjaColors.background,
        colorScheme: const ColorScheme.light(
          primary: NinjaColors.primary,
          secondary: NinjaColors.secondary,
          surface: NinjaColors.surface,
          error: NinjaColors.error,
        ),

        // ─── 文字 ───
        textTheme: const TextTheme(
          displayLarge: NinjaTextStyles.displayLarge,
          displayMedium: NinjaTextStyles.displayMedium,
          headlineLarge: NinjaTextStyles.heading1,
          headlineMedium: NinjaTextStyles.heading2,
          headlineSmall: NinjaTextStyles.heading3,
          bodyLarge: NinjaTextStyles.bodyLarge,
          bodyMedium: NinjaTextStyles.bodyMedium,
          bodySmall: NinjaTextStyles.bodySmall,
          labelLarge: NinjaTextStyles.label,
          labelSmall: NinjaTextStyles.caption,
        ),

        // ─── AppBar ───
        appBarTheme: const AppBarTheme(
          backgroundColor: NinjaColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        // ─── 卡片 ───
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: NinjaSpacing.lg,
            vertical: NinjaSpacing.sm,
          ),
        ),

        // ─── 按钮 ───
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NinjaColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            ),
            textStyle: NinjaTextStyles.label,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: NinjaColors.primary,
            side: const BorderSide(color: NinjaColors.primary),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            ),
          ),
        ),

        // ─── 输入框 ───
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: NinjaSpacing.lg,
            vertical: NinjaSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            borderSide: const BorderSide(color: NinjaColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            borderSide: const BorderSide(color: NinjaColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            borderSide:
                const BorderSide(color: NinjaColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            borderSide: const BorderSide(color: NinjaColors.error),
          ),
        ),

        // ─── Chip ───
        chipTheme: ChipThemeData(
          backgroundColor: NinjaColors.background,
          selectedColor: NinjaColors.primary.withValues(alpha: 0.15),
          labelStyle: NinjaTextStyles.bodySmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // ─── Bottom Nav ───
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: NinjaColors.primary,
          unselectedItemColor: NinjaColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );

  /// 暗色模式
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: NinjaColors.primaryLight,
        scaffoldBackgroundColor: NinjaColors.surfaceDark,
        colorScheme: const ColorScheme.dark(
          primary: NinjaColors.primaryLight,
          secondary: NinjaColors.secondary,
          surface: Color(0xFF2A2A3E),
          error: NinjaColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2A2A3E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );
}
