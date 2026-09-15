// ═══════════════════════════════════════
//  WordFlow — App Theme
//  学习者主题 — 颜色 / 文字 / 间距 / 装饰
// ═══════════════════════════════════════

import 'package:flutter/material.dart';

// ─── 颜色系统 ───

class AppColors {
  AppColors._();

  // 主色调
  static const Color primary = Color(0xFF5B5BD6); // 静谧靛蓝
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4338CA);

  // 辅助色
  static const Color secondary = Color(0xFF3178C6);
  static const Color accentGold = Color(0xFFB7791F);
  static const Color accentPurple = Color(0xFF7C5CC4);

  // 等级色（与功能色/主色区分，形成完整渐变）
  static const Color levelBeginner = Color(0xFF388E3C); // 学徒绿
  static const Color levelIntermediate = Color(0xFFFB8C00); // 进阶橙
  static const Color levelAdvanced = Color(0xFFC62828); // 熟练红（略深于primary）
  static const Color levelMaster = Color(0xFF6A1B9A); // 专家紫
  static const Color levelLegend = Color(0xFFFFB300); // 传说金

  // 功能色
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFF8F00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF039BE5);

  // 中性色
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF111318);
  static const Color surfaceContainerDark = Color(0xFF1C1F26);
  static const Color textPrimary = Color(0xFF18181B);
  static const Color textSecondary = Color(0xFF71717A);
  static const Color textOnDark = Color(0xFFF4F4F5);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF30343D);
}

// ─── 文字样式 ───

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'SawarabiGothic'; // 清晰易读字体

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// 中等标题
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 小标题
  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// 中等标签
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  /// 经验值数字（带发光效果 — 亮色模式阴影/暗色模式发光）
  static TextStyle get expText => TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.accentGold,
        shadows: [
          Shadow(
            color: AppColors.accentGold.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: Offset(0, 0),
          ),
        ],
      );
}

// ─── 间距系统 ───

class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// 卡片圆角
  static const double cardRadius = 12;
  static const double buttonRadius = 8;
  static const double avatarRadius = 24;
}

// ─── 阴影 ───

class AppShadows {
  AppShadows._();

  static const BoxShadow cardShadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow elevatedShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const BoxShadow glowRed = BoxShadow(
    color: Color(0x33E53935),
    blurRadius: 16,
    spreadRadius: 2,
    offset: Offset(0, 0),
  );
}
