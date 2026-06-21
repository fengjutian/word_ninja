import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// 页面分析调试开关
///
/// 用法：
/// 1. 设置下方 [enabled] 为 true 开启所有可视化调试
/// 2. 也可以在运行时通过代码切换各项开关
/// 3. 发布时把 [enabled] 改为 false 即可一键关闭
class DebugOverlay {
  DebugOverlay._();

  /// 总开关：设为 false 则所有调试都不生效（release 默认关闭）
  static const bool enabled = kDebugMode;

  // ── 布局分析 ──

  /// 显示 Widget 边界线（不同颜色 = 不同层级）
  /// 🟦 Padding  🟨 约束  🟪 对齐
  static void showLayoutBounds({bool on = true}) {
    if (!enabled) return;
    debugPaintSizeEnabled = on;
  }

  /// 显示基线辅助线（文字基线对齐）
  static void showBaselines({bool on = true}) {
    if (!enabled) return;
    debugPaintBaselinesEnabled = on;
  }

  /// 高亮重绘区域（闪烁 = 不必要的重绘 → 性能问题）
  static void showRepaintRainbow({bool on = true}) {
    if (!enabled) return;
    debugRepaintRainbowEnabled = on;
  }

  /// 显示图层边界
  static void showLayerBorders({bool on = true}) {
    if (!enabled) return;
    debugPaintLayerBordersEnabled = on;
  }

  /// 显示指针/点击位置
  static void showPointers({bool on = true}) {
    if (!enabled) return;
    debugPaintPointersEnabled = on;
  }

  // ── 一键开关 ──

  /// 一键开启所有
  static void enableAll() {
    if (!enabled) return;
    debugPaintSizeEnabled = true;
    debugPaintBaselinesEnabled = true;
    debugRepaintRainbowEnabled = true;
    debugPaintLayerBordersEnabled = true;
    debugPaintPointersEnabled = true;
  }

  /// 一键关闭所有
  static void disableAll() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugRepaintRainbowEnabled = false;
    debugPaintLayerBordersEnabled = false;
    debugPaintPointersEnabled = false;
  }

  /// 切换所有
  static void toggleAll() {
    if (debugPaintSizeEnabled) {
      disableAll();
    } else {
      enableAll();
    }
  }

  /// 当前状态（供 UI 显示）
  static bool get isActive => debugPaintSizeEnabled;
}
