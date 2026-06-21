import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// 页面分析调试开关
class DebugOverlay {
  DebugOverlay._();

  static const bool enabled = kDebugMode;

  static void showLayoutBounds({bool on = true}) {
    if (!enabled) return;
    debugPaintSizeEnabled = on;
  }

  static void showBaselines({bool on = true}) {
    if (!enabled) return;
    debugPaintBaselinesEnabled = on;
  }

  static void showRepaintRainbow({bool on = true}) {
    if (!enabled) return;
    debugRepaintRainbowEnabled = on;
  }

  static void showLayerBorders({bool on = true}) {
    if (!enabled) return;
    debugPaintLayerBordersEnabled = on;
  }

  static void showPointers({bool on = true}) {
    if (!enabled) return;
    debugPaintPointersEnabled = on;
  }

  static void enableAll() {
    if (!enabled) return;
    debugPaintSizeEnabled = true;
    debugPaintBaselinesEnabled = true;
    debugRepaintRainbowEnabled = true;
    debugPaintLayerBordersEnabled = true;
    debugPaintPointersEnabled = true;
  }

  static void disableAll() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugRepaintRainbowEnabled = false;
    debugPaintLayerBordersEnabled = false;
    debugPaintPointersEnabled = false;
  }

  static void toggleAll() {
    if (debugPaintSizeEnabled) {
      disableAll();
    } else {
      enableAll();
    }
  }

  static bool get isActive => debugPaintSizeEnabled;
}
