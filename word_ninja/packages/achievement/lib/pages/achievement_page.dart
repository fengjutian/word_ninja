import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    NinjaColors.accentGold.withValues(alpha: 0.08),
                    NinjaColors.surface,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(NinjaSpacing.xl),
              child: Column(
                children: [
                  NinjaIcon.trophy(size: 40, color: NinjaColors.accentGold),
                  const SizedBox(height: NinjaSpacing.md),
                  Text(
                    '$unlocked / $total',
                    style: NinjaTextStyles.displayLarge.copyWith(
                      color: NinjaColors.accentGold,
                    ),
                  ),
                  const SizedBox(height: NinjaSpacing.xs),
                  Text('已解锁成就', style: NinjaTextStyles.bodyMedium),
                  const SizedBox(height: NinjaSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: total > 0 ? unlocked / total : 0,
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
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: a.isUnlocked
                          ? NinjaColors.success.withValues(alpha: 0.1)
                          : NinjaColors.divider.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(NinjaSpacing.sm),
                    ),
                    child: Center(
                      child: Text(a.icon,
                          style: TextStyle(
                            fontSize: 22,
                            color: a.isUnlocked ? null : NinjaColors.textSecondary,
                          )),
                    ),
                  ),
                  title: Text(a.title, style: NinjaTextStyles.titleSmall),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(a.description,
                          style: NinjaTextStyles.bodySmall),
                      const SizedBox(height: 6),
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
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: NinjaColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check, size: 12, color: NinjaColors.success),
                              const SizedBox(width: 2),
                              Text('已完成',
                                  style: TextStyle(fontSize: 10, color: NinjaColors.success, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        )
                      : Text('${a.progress}/${a.target}',
                          style: NinjaTextStyles.caption),
                ),
              )),
        ],
      ),
    );
  }
}
