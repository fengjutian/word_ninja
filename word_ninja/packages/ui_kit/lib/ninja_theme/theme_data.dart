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
          titleLarge: NinjaTextStyles.heading3,
          titleMedium: NinjaTextStyles.titleMedium,
          titleSmall: NinjaTextStyles.titleSmall,
          bodyLarge: NinjaTextStyles.bodyLarge,
          bodyMedium: NinjaTextStyles.bodyMedium,
          bodySmall: NinjaTextStyles.bodySmall,
          labelLarge: NinjaTextStyles.label,
          labelMedium: NinjaTextStyles.labelMedium,
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

        // ─── Navigation Bar (M3) ───
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: NinjaColors.surface,
          indicatorColor: NinjaColors.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return NinjaTextStyles.labelMedium.copyWith(
                color: NinjaColors.primary,
                fontWeight: FontWeight.w600,
              );
            }
            return NinjaTextStyles.labelMedium.copyWith(
              color: NinjaColors.textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: NinjaColors.primary,
                size: 24,
              );
            }
            return const IconThemeData(
              color: NinjaColors.textSecondary,
              size: 22,
            );
          }),
          elevation: 2,
          height: 64,
        ),
      );

  /// 暗色模式（完整组件主题化）
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: NinjaColors.primary,
        scaffoldBackgroundColor: NinjaColors.surfaceDark,
        colorScheme: const ColorScheme.dark(
          primary: NinjaColors.primaryLight,
          secondary: NinjaColors.info,
          surface: NinjaColors.surfaceContainerDark,
          error: NinjaColors.error,
        ),

        // ─── 文字 ───
        textTheme: TextTheme(
          displayLarge: NinjaTextStyles.displayLarge.copyWith(color: NinjaColors.textOnDark),
          displayMedium: NinjaTextStyles.displayMedium.copyWith(color: NinjaColors.textOnDark),
          headlineLarge: NinjaTextStyles.heading1.copyWith(color: NinjaColors.textOnDark),
          headlineMedium: NinjaTextStyles.heading2.copyWith(color: NinjaColors.textOnDark),
          headlineSmall: NinjaTextStyles.heading3.copyWith(color: NinjaColors.textOnDark),
          titleLarge: NinjaTextStyles.heading3.copyWith(color: NinjaColors.textOnDark),
          titleMedium: NinjaTextStyles.titleMedium.copyWith(color: NinjaColors.textOnDark),
          titleSmall: NinjaTextStyles.titleSmall.copyWith(color: NinjaColors.textOnDark),
          bodyLarge: NinjaTextStyles.bodyLarge.copyWith(color: NinjaColors.textOnDark),
          bodyMedium: NinjaTextStyles.bodyMedium.copyWith(color: NinjaColors.textOnDark),
          bodySmall: NinjaTextStyles.bodySmall.copyWith(color: NinjaColors.textOnDark.withValues(alpha: 0.7)),
          labelLarge: NinjaTextStyles.label.copyWith(color: NinjaColors.textOnDark),
          labelMedium: NinjaTextStyles.labelMedium.copyWith(color: NinjaColors.textOnDark),
          labelSmall: NinjaTextStyles.caption.copyWith(color: NinjaColors.textOnDark.withValues(alpha: 0.7)),
        ),

        // ─── AppBar ───
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF252538),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        // ─── 卡片 ───
        cardTheme: CardTheme(
          elevation: 2,
          color: NinjaColors.surfaceContainerDark,
          shadowColor: Colors.black45,
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
            textStyle: NinjaTextStyles.label.copyWith(color: Colors.white),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: NinjaColors.primaryLight,
            side: const BorderSide(color: NinjaColors.primaryLight),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            ),
          ),
        ),

        // ─── 输入框 ───
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF3A3A4E),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: NinjaSpacing.lg,
            vertical: NinjaSpacing.md,
          ),
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            borderSide: const BorderSide(color: NinjaColors.dividerDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            borderSide: const BorderSide(color: NinjaColors.dividerDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            borderSide:
                const BorderSide(color: NinjaColors.primaryLight, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            borderSide: const BorderSide(color: NinjaColors.error),
          ),
        ),

        // ─── Chip ───
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF3A3A4E),
          selectedColor: NinjaColors.primaryLight.withValues(alpha: 0.2),
          labelStyle: NinjaTextStyles.bodySmall.copyWith(
            color: NinjaColors.textOnDark.withValues(alpha: 0.7),
          ),
          secondaryLabelStyle: NinjaTextStyles.bodySmall.copyWith(
            color: NinjaColors.textOnDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // ─── Bottom Nav ───
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF252538),
          selectedItemColor: NinjaColors.primaryLight,
          unselectedItemColor: Color(0xFF9E9E9E),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        // ─── Navigation Bar (M3) 暗色 ───
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF252538),
          indicatorColor: NinjaColors.primaryLight.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return NinjaTextStyles.labelMedium.copyWith(
                color: NinjaColors.primaryLight,
                fontWeight: FontWeight.w600,
              );
            }
            return NinjaTextStyles.caption.copyWith(
              color: NinjaColors.textOnDark.withValues(alpha: 0.7),
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: NinjaColors.primaryLight,
                size: 24,
              );
            }
            return IconThemeData(
              color: NinjaColors.textOnDark.withValues(alpha: 0.5),
              size: 22,
            );
          }),
          elevation: 2,
          height: 64,
        ),
      );
}
