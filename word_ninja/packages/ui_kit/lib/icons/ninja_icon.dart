import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 忍者应用自定义 SVG 图标系统
///
/// SVG 资产由消费方应用提供（打包在应用 assets/icons/ 目录下）。
/// 使用方法：
/// ```dart
/// NinjaIcon.shuriken(size: 24, color: NinjaColors.primary)
/// NinjaIcon.scroll(size: 20)
/// ```
class NinjaIcon extends StatelessWidget {
  final String _assetName;
  final double size;
  final Color? color;
  final BoxFit fit;

  const NinjaIcon._(
    this._assetName, {
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

  /// 钢笔 — 写作
  static const pen = _NinjaIconRef('pen');

  /// 日历 — 计划
  static const calendar = _NinjaIconRef('calendar');

  /// 每个忍者图标的 Material 回退图标（SVG 加载失败时使用）
  static IconData? _fallbackIcon(String name) {
    return switch (name) {
      'shuriken'    => PhosphorIconsRegular.star,
      'scroll'      => PhosphorIconsRegular.bookOpen,
      'ninja_head'  => PhosphorIconsRegular.user,
      'chat_bubble' => PhosphorIconsRegular.chats,
      'trophy'      => PhosphorIconsRegular.trophy,
      'coin'        => PhosphorIconsRegular.coin,
      'headphone'   => PhosphorIconsRegular.headphones,
      'mic'         => PhosphorIconsRegular.microphone,
      'mountain'    => PhosphorIconsRegular.mountains,
      'sword'       => PhosphorIconsRegular.barbell,
      'pen'         => PhosphorIconsRegular.pencilSimple,
      'calendar'    => PhosphorIconsRegular.calendar,
      _             => null,
    };
  }

  /// 将 Color 转成 #RRGGBB hex 字符串
  static String _colorToHex(Color c) {
    return '#'
        '${c.red.toRadixString(16).padLeft(2, '0')}'
        '${c.green.toRadixString(16).padLeft(2, '0')}'
        '${c.blue.toRadixString(16).padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Web 上 vector_graphics + colorFilter 组合存在渲染问题；
    // 这里改用 SvgPicture.string 并在加载时直接替换 SVG 内的 fill 颜色，
    // 同时保留 Material icon 回退以应对加载失败。
    if (color != null) {
      final hex = _colorToHex(color!);
      return FutureBuilder<String>(
        future: rootBundle.loadString('assets/icons/$_assetName.svg'),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            final fallback = _fallbackIcon(_assetName);
            if (fallback != null) {
              return Icon(fallback, size: size, color: color);
            }
            return SizedBox(width: size, height: size);
          }
          // 替换硬编码 fill 和 stroke 为指定颜色（保留 #FFFFFF 白色部分不变）
          final svg = snapshot.data!
              .replaceAll('fill="#000000"', 'fill="$hex"')
              .replaceAll('stroke="#000000"', 'stroke="$hex"');
          return SvgPicture.string(
            svg,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              final fallback = _fallbackIcon(_assetName);
              if (fallback != null) {
                return Icon(fallback, size: size, color: color);
              }
              return SizedBox(width: size, height: size);
            },
          );
        },
      );
    }

    // 无指定颜色时：直接渲染原始 SVG（黑色）
    return SvgPicture.asset(
      'assets/icons/$_assetName.svg',
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        final fallback = _fallbackIcon(_assetName);
        if (fallback != null) {
          return Icon(fallback, size: size, color: color);
        }
        return SizedBox(width: size, height: size);
      },
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
