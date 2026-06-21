import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 忍者应用自定义 SVG 图标系统
///
/// 使用方法：
/// ```dart
/// NinjaIcon.shuriken(size: 24, color: NinjaColors.primary)
/// NinjaIcon.scroll(size: 20)
/// ```
class NinjaIcon extends StatelessWidget {
  final String _assetPath;
  final double size;
  final Color? color;
  final BoxFit fit;

  const NinjaIcon._(
    this._assetPath, {
    super.key,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
  });

  // ─── 图标目录 ───

  /// 手里剑 — 核心品牌图标
  static const shuriken = _NinjaIconRef('shuriken');

  /// 卷轴 — 单词/阅读
  static const scroll = _NinjaIconRef('scroll');

  /// 忍者头像 — 个人中心
  static const ninjaHead = _NinjaIconRef('ninja_head');

  /// 对话气泡 — AI 导师
  static const chatBubble = _NinjaIconRef('chat_bubble');

  /// 奖杯 — 成就
  static const trophy = _NinjaIconRef('trophy');

  /// 金币 — 商店
  static const coin = _NinjaIconRef('coin');

  /// 耳机 — 听力
  static const headphone = _NinjaIconRef('headphone');

  /// 麦克风 — 口语
  static const mic = _NinjaIconRef('mic');

  /// 山峰 — 等级/进度
  static const mountain = _NinjaIconRef('mountain');

  /// 剑 — 修炼/训练
  static const sword = _NinjaIconRef('sword');

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'packages/ui_kit/assets/icons/$_assetPath.svg',
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      fit: fit,
    );
  }
}

/// 图标引用 — 用于声明式调用，如 `NinjaIcon.shuriken`
class _NinjaIconRef {
  final String _name;
  const _NinjaIconRef(this._name);

  /// 创建带参数的图标实例
  NinjaIcon call({
    double size = 24,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return NinjaIcon._(
      _name,
      size: size,
      color: color,
      fit: fit,
    );
  }
}
