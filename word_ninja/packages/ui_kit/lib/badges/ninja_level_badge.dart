import 'package:flutter/material.dart';
import '../ninja_theme/ninja_theme.dart';

/// 忍者等级徽章组件
class NinjaLevelBadge extends StatelessWidget {
  final int level;
  final double size;

  const NinjaLevelBadge({
    super.key,
    required this.level,
    this.size = 48,
  });

  String get _rank {
    if (level >= 100) return 'legend';
    if (level >= 80) return 'kage';
    if (level >= 50) return 'master';
    if (level >= 40) return 'elite';
    if (level >= 30) return 'jonin';
    if (level >= 20) return 'chunin';
    if (level >= 10) return 'genin';
    return 'apprentice';
  }

  Color get _color {
    if (level >= 100) return NinjaColors.levelLegend;
    if (level >= 80) return NinjaColors.levelMaster;
    if (level >= 40) return NinjaColors.levelAdvanced;
    if (level >= 20) return NinjaColors.levelIntermediate;
    return NinjaColors.levelBeginner;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [_color, _color.withValues(alpha: 0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$level',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w900,
            shadows: const [
              Shadow(color: Colors.black26, blurRadius: 2),
            ],
          ),
        ),
      ),
    );
  }
}
