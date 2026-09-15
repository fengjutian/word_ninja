import 'package:flutter/material.dart';

enum AppThemeId { indigo, forest }

@immutable
class AppThemePreset {
  const AppThemePreset({required this.id, required this.name, required this.seed, required this.lightBackground, required this.darkBackground});
  final AppThemeId id;
  final String name;
  final Color seed;
  final Color lightBackground;
  final Color darkBackground;
}

class AppThemeCatalog {
  AppThemeCatalog._();
  static const indigo = AppThemePreset(id: AppThemeId.indigo, name: '静谧靛蓝', seed: Color(0xFF5B5BD6), lightBackground: Color(0xFFF7F8FA), darkBackground: Color(0xFF111318));
  static const forest = AppThemePreset(id: AppThemeId.forest, name: '专注森林', seed: Color(0xFF287A5B), lightBackground: Color(0xFFF5F8F6), darkBackground: Color(0xFF101613));
  static const values = [indigo, forest];
  static AppThemePreset fromId(AppThemeId id) => values.firstWhere((item) => item.id == id);
}

@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({required this.canvas, required this.sidebar, required this.subtleSurface, required this.border, required this.mutedText, required this.success, required this.warning, required this.info});
  final Color canvas, sidebar, subtleSurface, border, mutedText, success, warning, info;

  static AppColorTokens forPreset(AppThemePreset preset, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return AppColorTokens(
      canvas: dark ? preset.darkBackground : preset.lightBackground,
      sidebar: dark ? const Color(0xFF17191F) : Colors.white,
      subtleSurface: dark ? const Color(0xFF20232B) : const Color(0xFFF1F3F6),
      border: dark ? const Color(0xFF30343D) : const Color(0xFFE5E7EB),
      mutedText: dark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
      success: dark ? const Color(0xFF59B887) : const Color(0xFF2E8B57),
      warning: dark ? const Color(0xFFD8A64B) : const Color(0xFFB7791F),
      info: dark ? const Color(0xFF70A9E8) : const Color(0xFF3178C6),
    );
  }

  @override
  AppColorTokens copyWith({Color? canvas, Color? sidebar, Color? subtleSurface, Color? border, Color? mutedText, Color? success, Color? warning, Color? info}) => AppColorTokens(canvas: canvas ?? this.canvas, sidebar: sidebar ?? this.sidebar, subtleSurface: subtleSurface ?? this.subtleSurface, border: border ?? this.border, mutedText: mutedText ?? this.mutedText, success: success ?? this.success, warning: warning ?? this.warning, info: info ?? this.info);

  @override
  AppColorTokens lerp(covariant AppColorTokens? other, double t) {
    if (other == null) return this;
    return AppColorTokens(canvas: Color.lerp(canvas, other.canvas, t)!, sidebar: Color.lerp(sidebar, other.sidebar, t)!, subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!, border: Color.lerp(border, other.border, t)!, mutedText: Color.lerp(mutedText, other.mutedText, t)!, success: Color.lerp(success, other.success, t)!, warning: Color.lerp(warning, other.warning, t)!, info: Color.lerp(info, other.info, t)!);
  }
}

extension AppThemeContext on BuildContext {
  AppColorTokens get appColors => Theme.of(this).extension<AppColorTokens>()!;
}
