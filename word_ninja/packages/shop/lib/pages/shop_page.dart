import 'package:flutter/material.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ui_kit/ui_kit.dart' show NinjaIcon;

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
                  NinjaIcon.coin(size: 20, color: NinjaColors.accentGold),
                  const SizedBox(width: 4),
                  Text('1,250', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          _CategorySection(
            title: '角色皮肤',
            icon: NinjaIcon.ninjaHead(size: 18, color: NinjaColors.primary),
            items: [
              _ShopItemData('暗影忍者', 500, true),
              _ShopItemData('忍者大师', 800, false),
              _ShopItemData('樱花忍者', 600, false),
            ],
          ),
          const SizedBox(height: NinjaSpacing.sm),
          _CategorySection(
            title: '背景主题',
            icon: NinjaIcon.mountain(size: 18, color: NinjaColors.secondary),
            items: [
              _ShopItemData('月光庭院', 300, false),
              _ShopItemData('樱花雨', 400, false),
              _ShopItemData('忍者道场', 350, false),
            ],
          ),
          const SizedBox(height: NinjaSpacing.sm),
          _CategorySection(
            title: '徽章',
            icon: NinjaIcon.trophy(size: 18, color: NinjaColors.accentGold),
            items: [
              _ShopItemData('金色传说', 1000, false),
              _ShopItemData('百胜勇士', 500, false),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final Widget icon;
  final List<_ShopItemData> items;

  const _CategorySection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: NinjaSpacing.xs,
            bottom: NinjaSpacing.md,
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: NinjaSpacing.sm),
              Text(title, style: NinjaTextStyles.heading3),
            ],
          ),
        ),
        ...items.map((item) => _ShopItem(
              name: item.name,
              price: item.price,
              owned: item.owned,
            )),
      ],
    );
  }
}

class _ShopItemData {
  final String name;
  final int price;
  final bool owned;
  const _ShopItemData(this.name, this.price, this.owned);
}

class _ShopItem extends StatelessWidget {
  final String name;
  final int price;
  final bool owned;

  const _ShopItem({
    required this.name,
    required this.price,
    required this.owned,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NinjaColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
          ),
          child: Center(
            child: NinjaIcon.shuriken(size: 22, color: NinjaColors.primary),
          ),
        ),
        title: Text(name, style: NinjaTextStyles.titleSmall),
        subtitle: owned
            ? null
            : Text('$price 金币', style: NinjaTextStyles.caption.copyWith(color: NinjaColors.accentGold)),
        trailing: owned
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: NinjaColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 14, color: NinjaColors.success),
                    const SizedBox(width: 4),
                    Text('已拥有',
                        style: TextStyle(fontSize: 11, color: NinjaColors.success, fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            : SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: NinjaIcon.coin(size: 14, color: Colors.white),
                  label: Text('$price',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NinjaColors.accentGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
