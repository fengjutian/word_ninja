// ═══════════════════════════════════════
//  Word Ninja — Ninja Theme
//  忍者主题 — 颜色 / 文字 / 间距 / 装饰
// ═══════════════════════════════════════

import 'package:flutter/material.dart';

// ─── 颜色系统 ───

class NinjaColors {
  NinjaColors._();

  // 主色调
  static const Color primary = Color(0xFFE53935);        // 忍者红
  static const Color primaryLight = Color(0xFFFF6F60);
  static const Color primaryDark = Color(0xFFAB000D);

  // 辅助色
  static const Color secondary = Color(0xFF1E88E5);      // 忍术蓝
  static const Color accentGold = Color(0xFFFFB300);     // 金币金
  static const Color accentPurple = Color(0xFF7B1FA2);   // 神秘紫

  // 等级色
  static const Color levelBeginner = Color(0xFF43A047);  // 学徒绿
  static const Color levelIntermediate = Color(0xFFFB8C00); // 中忍橙
  static const Color levelAdvanced = Color(0xFFE53935);  // 上忍红
  static const Color levelMaster = Color(0xFF7B1FA2);    // 影级紫
  static const Color levelLegend = Color(0xFFFFB300);    // 传说金

  // 功能色
  static const Color success = Color(0xFF43A047);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF1E88E5);

  // 中性色
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFBDBDBD);
}

// ─── 文字样式 ───

class NinjaTextStyles {
  NinjaTextStyles._();

  static const String _fontFamily = 'SawarabiGothic'; // 日系忍术感字体

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: NinjaColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: NinjaColors.textPrimary,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: NinjaColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: NinjaColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: NinjaColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: NinjaColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: NinjaColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: NinjaColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: NinjaColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: NinjaColors.textSecondary,
  );

  /// 经验值数字（带阴影）
  static const TextStyle expText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: NinjaColors.accentGold,
    shadows: [
      Shadow(
        color: Colors.black26,
        blurRadius: 4,
        offset: Offset(2, 2),
      ),
    ],
  );
}

// ─── 间距系统 ───

class NinjaSpacing {
  NinjaSpacing._();

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

class NinjaShadows {
  NinjaShadows._();

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
