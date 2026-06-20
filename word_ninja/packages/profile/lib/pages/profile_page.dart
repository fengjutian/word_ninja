import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/lib/badges/ninja_level_badge.dart';
import 'package:ui_kit/lib/cards/exp_progress_bar.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';

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
                        const Text('忍者学徒', style: NinjaTextStyles.heading2),
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
          _MenuItem(Icons.settings, '设置', () {}),
          _MenuItem(Icons.star, '会员中心', () {},
              trailing: const Chip(
                label: Text('免费版', style: TextStyle(fontSize: 11)),
                backgroundColor: NinjaColors.info,
                labelStyle: TextStyle(color: Colors.white),
              )),
          _MenuItem(Icons.sync, '数据同步', () {}),
          _MenuItem(Icons.shield, '隐私政策', () {}),
          _MenuItem(Icons.info, '关于', () {}),

          const SizedBox(height: NinjaSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: NinjaColors.error,
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
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem(this.icon, this.title, this.onTap, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.xs),
      child: ListTile(
        leading: Icon(icon, color: NinjaColors.primary),
        title: Text(title, style: NinjaTextStyles.bodyLarge),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: NinjaColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
