import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/badges/ninja_level_badge.dart';
import 'package:ui_kit/cards/exp_progress_bar.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;

/// 个人中心页
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  const NinjaLevelBadge(level: 18),
                  const SizedBox(width: NinjaSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('忍者学徒', style: NinjaTextStyles.heading2),
                            const SizedBox(width: NinjaSpacing.sm),
                            NinjaIcon.shuriken(size: 16, color: NinjaColors.primary),
                          ],
                        ),
                        const SizedBox(height: NinjaSpacing.xs),
                        const Text('Lv.18 · 下忍', style: NinjaTextStyles.bodyMedium),
                        const SizedBox(height: NinjaSpacing.sm),
                        ExpProgressBar(currentExp: 1250, maxExp: 1500),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NinjaSpacing.lg),

          // 功能列表
          _MenuItem(const Icon(Icons.settings, size: 20, color: NinjaColors.primary), '设置', () {}),
          _MenuItem(NinjaIcon.shuriken(size: 20, color: NinjaColors.accentGold), '会员中心', () {},
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NinjaColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('免费版',
                    style: TextStyle(fontSize: 11, color: NinjaColors.info, fontWeight: FontWeight.w600)),
              )),
          _MenuItem(const Icon(Icons.sync, size: 20, color: NinjaColors.primary), '数据同步', () {}),
          _MenuItem(const Icon(Icons.shield, size: 20, color: NinjaColors.primary), '隐私政策', () {}),
          _MenuItem(const Icon(Icons.info, size: 20, color: NinjaColors.primary), '关于', () {}),

          const SizedBox(height: NinjaSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
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
}

class _MenuItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem(this.icon, this.title, this.onTap, {this.trailing});

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
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 18, color: NinjaColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
