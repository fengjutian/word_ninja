import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';
import '../models/achievement.dart';

/// 成就页面
class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = Achievement.defaults();

    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final total = achievements.length;

    return Scaffold(
      appBar: AppBar(title: const Text('成就')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          // 总览
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.xl),
              child: Column(
                children: [
                  Text(
                    '$unlocked / $total',
                    style: NinjaTextStyles.displayLarge.copyWith(
                      color: NinjaColors.accentGold,
                    ),
                  ),
                  const SizedBox(height: NinjaSpacing.sm),
                  Text('已解锁成就', style: NinjaTextStyles.bodyMedium),
                  const SizedBox(height: NinjaSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: unlocked / total,
                      minHeight: 8,
                      backgroundColor: NinjaColors.divider.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          NinjaColors.accentGold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NinjaSpacing.lg),

          // 成就列表
          ...achievements.map((a) => Card(
                margin: const EdgeInsets.only(bottom: NinjaSpacing.sm),
                child: ListTile(
                  leading: Text(a.icon, style: const TextStyle(fontSize: 32)),
                  title: Text(a.title, style: NinjaTextStyles.heading3),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.description,
                          style: NinjaTextStyles.bodySmall),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: a.progressPercent,
                        minHeight: 4,
                        backgroundColor: NinjaColors.divider.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          a.isUnlocked ? NinjaColors.success : NinjaColors.info,
                        ),
                      ),
                    ],
                  ),
                  trailing: a.isUnlocked
                      ? const Icon(Icons.check_circle, color: NinjaColors.success)
                      : Text('${a.progress}/${a.target}',
                          style: NinjaTextStyles.caption),
                ),
              )),
        ],
      ),
    );
  }
}
