import 'package:flutter/material.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 商店页面
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商店'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: NinjaColors.accentGold),
                  const SizedBox(width: 4),
                  Text('1,250', style: NinjaTextStyles.bodyLarge.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Text('角色皮肤', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          _ShopItem('暗影忍者', 'shadow_ninja', 500, true),
          _ShopItem('忍者大师', 'master_ninja', 800, false),
          _ShopItem('樱花忍者', 'sakura_ninja', 600, false),
          const SizedBox(height: NinjaSpacing.xl),
          Text('背景主题', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          _ShopItem('月光庭院', 'moon_garden', 300, false),
          _ShopItem('樱花雨', 'sakura_rain', 400, false),
          _ShopItem('忍者道场', 'dojo', 350, false),
          const SizedBox(height: NinjaSpacing.xl),
          Text('徽章', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          _ShopItem('金色传说', 'gold_legend', 1000, false),
          _ShopItem('百胜勇士', 'warrior', 500, false),
        ],
      ),
    );
  }
}

class _ShopItem extends StatelessWidget {
  final String name;
  final String asset;
  final int price;
  final bool owned;

  const _ShopItem(this.name, this.asset, this.price, this.owned);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NinjaColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.shopping_bag, color: NinjaColors.primary),
        ),
        title: Text(name, style: NinjaTextStyles.heading3),
        trailing: owned
            ? const Chip(
                label: Text('已拥有', style: TextStyle(fontSize: 11)),
                backgroundColor: NinjaColors.success,
                labelStyle: TextStyle(color: Colors.white),
              )
            : ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.monetization_on, size: 14),
                label: Text('$price'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NinjaColors.accentGold,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                ),
              ),
      ),
    );
  }
}
