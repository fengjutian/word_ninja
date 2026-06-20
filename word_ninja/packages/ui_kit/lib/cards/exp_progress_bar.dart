import 'package:flutter/material.dart';
import '../ninja_theme/ninja_theme.dart';

/// 经验条组件
class ExpProgressBar extends StatelessWidget {
  final int currentExp;
  final int maxExp;

  const ExpProgressBar({
    super.key,
    required this.currentExp,
    required this.maxExp,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentExp / maxExp).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${currentExp} / $maxExp EXP',
          style: NinjaTextStyles.caption,
        ),
        const SizedBox(height: NinjaSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: NinjaColors.divider.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(
              NinjaColors.accentGold,
            ),
          ),
        ),
      ],
    );
  }
}
