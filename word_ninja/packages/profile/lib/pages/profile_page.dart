import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:auth/presentation/providers/auth_provider.dart';
import 'package:ui_kit/badges/ninja_level_badge.dart';
import 'package:ui_kit/cards/exp_progress_bar.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;
import 'package:sync/sync_service.dart';

/// 个人中心页
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final level = user?.level ?? 1;
    final exp = user?.exp ?? 0;
    final nickname = user?.nickname ?? '忍者';
    final rank = user?.rank ?? '学徒龟';

    // 使用 User 实体自带的经验值计算
    final maxExp = user?.expToNextLevel ?? 1000;
    final effectiveMaxExp = maxExp > exp ? maxExp : exp + 100;

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          // 个人信息卡片
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.xl),
              child: Row(
                children: [
                  NinjaLevelBadge(level: level),
                  const SizedBox(width: NinjaSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(nickname, style: NinjaTextStyles.heading2),
                            const SizedBox(width: NinjaSpacing.sm),
                            NinjaIcon.shuriken(size: 16, color: NinjaColors.primary),
                          ],
                        ),
                        const SizedBox(height: NinjaSpacing.xs),
                        Text('Lv.$level · $rank', style: NinjaTextStyles.bodyMedium),
                        const SizedBox(height: NinjaSpacing.sm),
                        ExpProgressBar(currentExp: exp, maxExp: effectiveMaxExp),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NinjaSpacing.lg),

          // 功能列表
          _MenuItem(
            const Icon(PhosphorIcons.regular.gear, size: 20, color: NinjaColors.primary),
            '设置',
            () => context.push('/settings'),
          ),
          _MenuItem(
            NinjaIcon.shuriken(size: 20, color: NinjaColors.accentGold),
            '会员中心',
            () => context.push('/membership'),
          ),
          _MenuItem(
            const Icon(PhosphorIcons.regular.arrowsClockwise, size: 20, color: NinjaColors.primary),
            '数据同步',
            () async {
              final syncService = ref.read(syncProvider);
              final result = await syncService.sync();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              }
            },
          ),
          _MenuItem(
            const Icon(PhosphorIcons.regular.trophy, size: 20, color: NinjaColors.primary),
            '成就中心',
            () => context.push('/achievement'),
          ),
          _MenuItem(
            const Icon(PhosphorIcons.regular.info, size: 20, color: NinjaColors.primary),
            '关于 Word Ninja',
            () => _showAboutDialog(context),
          ),

          const SizedBox(height: NinjaSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _logout(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: NinjaColors.error,
                side: const BorderSide(color: NinjaColors.error),
              ),
              child: const Text('退出登录'),
            ),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: NinjaColors.error),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          NinjaIcon.shuriken(size: 24, color: NinjaColors.primary),
          const SizedBox(width: 8),
          const Text('Word Ninja'),
        ]),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('忍者英语 v1.0.0'),
            SizedBox(height: 8),
            Text('一款基于 Flutter 全平台开发的 AI 英语学习工具。'),
            SizedBox(height: 8),
            Text('通过「忍者修炼 + RPG成长 + AI老师」模式，让用户在游戏化体验中完成英语学习。'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('知道了')),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem(this.icon, this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.xs),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: NinjaColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(NinjaSpacing.sm),
          ),
          child: Center(child: icon),
        ),
        title: Text(title, style: NinjaTextStyles.bodyMedium),
        trailing: const Icon(PhosphorIcons.regular.caretRight, size: 18, color: NinjaColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
