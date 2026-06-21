import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;
import '../models/achievement.dart';

/// 成就追踪 Provider
final achievementListProvider = StateProvider<List<Achievement>>((ref) {
  return Achievement.defaults();
});

/// 成就统计 Provider
final achievementStatsProvider = Provider<({int unlocked, int total, double percent})>((ref) {
  final list = ref.watch(achievementListProvider);
  final unlocked = list.where((a) => a.isUnlocked).length;
  final total = list.length;
  return (unlocked: unlocked, total: total, percent: total > 0 ? unlocked / total : 0);
});

/// 更新成就进度的便捷方法
void updateAchievement(WidgetRef ref, AchievementType type, int progress) {
  final list = ref.read(achievementListProvider);
  final newList = list.map((a) {
    if (a.type == type && !a.isUnlocked) {
      final newProgress = (a.progress + progress).clamp(0, a.target);
      final unlocked = newProgress >= a.target;
      return Achievement(
        id: a.id, type: a.type, title: a.title, description: a.description,
        icon: a.icon, target: a.target, progress: newProgress, isUnlocked: unlocked,
      );
    }
    return a;
  }).toList();
  ref.read(achievementListProvider.notifier).state = newList;
}

/// 成就页面
class AchievementPage extends ConsumerWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementListProvider);
    final stats = ref.watch(achievementStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('成就')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          // 总览卡片
          Card(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [NinjaColors.accentGold.withValues(alpha: 0.08), NinjaColors.surface],
                ),
              ),
              padding: const EdgeInsets.all(NinjaSpacing.xl),
              child: Column(
                children: [
                  NinjaIcon.trophy(size: 40, color: NinjaColors.accentGold),
                  const SizedBox(height: NinjaSpacing.md),
                  Text('${stats.unlocked} / ${stats.total}',
                      style: NinjaTextStyles.displayLarge.copyWith(color: NinjaColors.accentGold)),
                  const SizedBox(height: NinjaSpacing.xs),
                  Text('已解锁成就', style: NinjaTextStyles.bodyMedium),
                  const SizedBox(height: NinjaSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: stats.percent,
                      minHeight: 8,
                      backgroundColor: NinjaColors.divider.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(NinjaColors.accentGold),
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
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: a.isUnlocked
                          ? NinjaColors.success.withValues(alpha: 0.1)
                          : NinjaColors.divider.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(NinjaSpacing.sm),
                    ),
                    child: Center(
                      child: Text(a.icon, style: TextStyle(
                        fontSize: 22, color: a.isUnlocked ? null : NinjaColors.textSecondary,
                      )),
                    ),
                  ),
                  title: Text(a.title, style: NinjaTextStyles.titleSmall),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(a.description, style: NinjaTextStyles.bodySmall),
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
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.check, size: 12, color: NinjaColors.success),
                            const SizedBox(width: 2),
                            Text('已完成', style: TextStyle(fontSize: 10, color: NinjaColors.success, fontWeight: FontWeight.w600)),
                          ]),
                        )
                      : Text('${a.progress}/${a.target}', style: NinjaTextStyles.caption),
                ),
              )),
        ],
      ),
    );
  }
}
