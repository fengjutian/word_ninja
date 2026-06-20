import 'package:flutter/material.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';

/// 会员页面
class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('会员中心')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          const SizedBox(height: NinjaSpacing.xl),
          const Center(
            child: Icon(Icons.star, size: 64, color: NinjaColors.accentGold),
          ),
          const SizedBox(height: NinjaSpacing.md),
          const Center(
            child: Text('Word Ninja Pro', style: NinjaTextStyles.displayMedium),
          ),
          const SizedBox(height: NinjaSpacing.xxl),

          _BenefitTile(Icons.auto_awesome, '无限AI对话', '不受限制地使用AI导师'),
          _BenefitTile(Icons.cloud_sync, '云同步', '多端数据实时同步'),
          _BenefitTile(Icons.record_voice_over, '口语评分', 'AI发音评测'),
          _BenefitTile(Icons.assessment, '详细统计', '学习数据深度分析'),
          _BenefitTile(Icons.remove_red_eye, '无广告', '纯净学习体验'),

          const SizedBox(height: NinjaSpacing.xxl),
          Card(
            color: NinjaColors.accentGold.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.xl),
              child: Column(
                children: [
                  const Text('¥29/月', style: NinjaTextStyles.displayLarge),
                  const SizedBox(height: NinjaSpacing.sm),
                  const Text('首月优惠 ¥9.9', style: NinjaTextStyles.bodyMedium),
                  const SizedBox(height: NinjaSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('开通会员'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _BenefitTile(this.icon, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: NinjaColors.accentGold, size: 28),
          const SizedBox(width: NinjaSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: NinjaTextStyles.heading3),
              Text(desc, style: NinjaTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
