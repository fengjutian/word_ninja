import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'design_tokens.dart';

/// 生成 WordFlow 完整 ThemeData（浅色模式）
class AppTheme {
  static ThemeData get light => build(AppThemeCatalog.indigo, Brightness.light);
  static ThemeData get dark => build(AppThemeCatalog.indigo, Brightness.dark);

  static ThemeData build(AppThemePreset preset, Brightness brightness) {
    final base = brightness == Brightness.dark ? _dark : _light;
    final tokens = AppColorTokens.forPreset(preset, brightness);
    final generatedScheme = ColorScheme.fromSeed(
      seedColor: preset.seed,
      brightness: brightness,
      surface: base.colorScheme.surface,
      error: base.colorScheme.error,
    );
    final scheme = generatedScheme.copyWith(
      surface: tokens.sidebar,
      surfaceContainerLowest: tokens.sidebar,
      surfaceContainerLow: tokens.canvas,
      surfaceContainer: tokens.subtleSurface,
      surfaceContainerHigh: tokens.subtleSurface,
      outline: tokens.border,
      outlineVariant: tokens.border,
    );
    return base.copyWith(
      colorScheme: scheme,
      primaryColor: preset.seed,
      scaffoldBackgroundColor: tokens.canvas,
      extensions: [tokens],
      cardTheme: base.cardTheme.copyWith(
        color: tokens.sidebar,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          side: BorderSide(color: tokens.border),
        ),
      ),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: tokens.canvas,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(color: tokens.border, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 42),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: BorderSide(color: tokens.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get _light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),

        // ─── 文字 ───
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.heading1,
          headlineMedium: AppTextStyles.heading2,
          headlineSmall: AppTextStyles.heading3,
          titleLarge: AppTextStyles.heading3,
          titleMedium: AppTextStyles.titleMedium,
          titleSmall: AppTextStyles.titleSmall,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.label,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.caption,
        ),

        // ─── AppBar ───
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        // ─── 卡片 ───
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),

        // ─── 按钮 ───
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            textStyle: AppTextStyles.label,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
        ),

        // ─── 输入框 ───
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),

        // ─── Chip ───
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.background,
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          labelStyle: AppTextStyles.bodySmall,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // ─── Bottom Nav ───
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        // ─── Navigation Bar (M3) ───
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.primary,
                size: 24,
              );
            }
            return const IconThemeData(
              color: AppColors.textSecondary,
              size: 22,
            );
          }),
          elevation: 2,
          height: 64,
        ),
      );

  /// 暗色模式（完整组件主题化）
  static ThemeData get _dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.surfaceDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          secondary: AppColors.info,
          surface: AppColors.surfaceContainerDark,
          error: AppColors.error,
        ),

        // ─── 文字 ───
        textTheme: TextTheme(
          displayLarge:
              AppTextStyles.displayLarge.copyWith(color: AppColors.textOnDark),
          displayMedium:
              AppTextStyles.displayMedium.copyWith(color: AppColors.textOnDark),
          headlineLarge:
              AppTextStyles.heading1.copyWith(color: AppColors.textOnDark),
          headlineMedium:
              AppTextStyles.heading2.copyWith(color: AppColors.textOnDark),
          headlineSmall:
              AppTextStyles.heading3.copyWith(color: AppColors.textOnDark),
          titleLarge:
              AppTextStyles.heading3.copyWith(color: AppColors.textOnDark),
          titleMedium:
              AppTextStyles.titleMedium.copyWith(color: AppColors.textOnDark),
          titleSmall:
              AppTextStyles.titleSmall.copyWith(color: AppColors.textOnDark),
          bodyLarge:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.textOnDark),
          bodyMedium:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnDark),
          bodySmall: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textOnDark.withValues(alpha: 0.7)),
          labelLarge: AppTextStyles.label.copyWith(color: AppColors.textOnDark),
          labelMedium:
              AppTextStyles.labelMedium.copyWith(color: AppColors.textOnDark),
          labelSmall: AppTextStyles.caption
              .copyWith(color: AppColors.textOnDark.withValues(alpha: 0.7)),
        ),

        // ─── AppBar ───
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF252538),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        // ─── 卡片 ───
        cardTheme: CardThemeData(
          elevation: 2,
          color: AppColors.surfaceContainerDark,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),

        // ─── 按钮 ───
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            textStyle: AppTextStyles.label.copyWith(color: Colors.white),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            side: const BorderSide(color: AppColors.primaryLight),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
        ),

        // ─── 输入框 ───
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF3A3A4E),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            borderSide: const BorderSide(color: AppColors.dividerDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            borderSide: const BorderSide(color: AppColors.dividerDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            borderSide:
                const BorderSide(color: AppColors.primaryLight, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),

        // ─── Chip ───
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF3A3A4E),
          selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textOnDark.withValues(alpha: 0.7),
          ),
          secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textOnDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        // ─── Bottom Nav ───
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF252538),
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: Color(0xFF9E9E9E),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),

        // ─── Navigation Bar (M3) 暗色 ───
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF252538),
          indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.labelMedium.copyWith(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              );
            }
            return AppTextStyles.caption.copyWith(
              color: AppColors.textOnDark.withValues(alpha: 0.7),
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.primaryLight,
                size: 24,
              );
            }
            return IconThemeData(
              color: AppColors.textOnDark.withValues(alpha: 0.5),
              size: 22,
            );
          }),
          elevation: 2,
          height: 64,
        ),
      );
}
