import 'package:flutter/material.dart';
import '../app_theme/app_theme.dart';

/// 学习者等级徽章组件
class LevelBadge extends StatelessWidget {
  final int level;
  final double size;

  const LevelBadge({
    super.key,
    required this.level,
    this.size = 48,
  });

  Color get _color {
    if (level >= 100) return AppColors.levelLegend;
    if (level >= 80) return AppColors.levelMaster;
    if (level >= 40) return AppColors.levelAdvanced;
    if (level >= 20) return AppColors.levelIntermediate;
    return AppColors.levelBeginner;
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
