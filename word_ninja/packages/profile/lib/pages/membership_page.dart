import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:auth/presentation/providers/auth_provider.dart';

/// 会员页面
class MembershipPage extends ConsumerWidget {
  const MembershipPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isPro = authState.user?.isPro ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('会员中心')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          const SizedBox(height: NinjaSpacing.xl),
          const Center(
            child: Icon(PhosphorIconsRegular.star, size: 64, color: NinjaColors.accentGold),
          ),
          const SizedBox(height: NinjaSpacing.md),
          const Center(
            child: Text('Word Ninja Pro', style: NinjaTextStyles.displayMedium),
          ),
          if (isPro)
            const Center(
              child: Chip(
                label: Text('已开通', style: TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: NinjaColors.success,
              ),
            ),
          const SizedBox(height: NinjaSpacing.xxl),

          _BenefitTile(PhosphorIconsRegular.sparkle, '无限AI对话', '不受限制地使用AI导师'),
          _BenefitTile(PhosphorIconsRegular.cloudArrowUp, '云同步', '多端数据实时同步'),
          _BenefitTile(PhosphorIconsRegular.microphoneStage, '口语评分', 'AI发音评测'),
          _BenefitTile(PhosphorIconsRegular.chartBar, '详细统计', '学习数据深度分析'),
          _BenefitTile(PhosphorIconsRegular.eye, '无广告', '纯净学习体验'),

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
                      onPressed: isPro
                          ? null
                          : () {
                              // 跳转到支付页面或显示购买流程
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('支付功能即将上线！请前往 Web 端完成购买'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                      child: Text(isPro ? '已开通 Pro 会员' : '开通会员'),
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
