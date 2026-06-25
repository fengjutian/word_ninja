import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:core/storage/preferences.dart';

/// 排行榜时间范围
enum _RankRange { today, week, month }

/// 金币余额 Provider
final coinBalanceProvider = StateProvider<int>((ref) => 1250);

/// 已拥有商品 Provider
final ownedItemsProvider = StateProvider<Set<String>>((ref) => {'暗影忍者'});

/// 商店页面
class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(coinBalanceProvider);
    final owned = ref.watch(ownedItemsProvider);

    final items = [
      _CategorySectionData(
        title: '角色皮肤',
        icon: const Icon(PhosphorIconsRegular.users, size: 18, color: NinjaColors.primary),
        items: [
          _ShopItemData('暗影忍者', 500),
          _ShopItemData('忍者大师', 800),
          _ShopItemData('樱花忍者', 600),
        ],
      ),
      _CategorySectionData(
        title: '背景主题',
        icon: const Icon(PhosphorIconsRegular.palette, size: 18, color: NinjaColors.secondary),
        items: [
          _ShopItemData('月光庭院', 300),
          _ShopItemData('樱花雨', 400),
          _ShopItemData('忍者道场', 350),
        ],
      ),
      _CategorySectionData(
        title: '徽章',
        icon: const Icon(PhosphorIconsRegular.trophy, size: 18, color: NinjaColors.accentGold),
        items: [
          _ShopItemData('金色传说', 1000),
          _ShopItemData('百胜勇士', 500),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('商店'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.coin, size: 20, color: NinjaColors.accentGold),
                  const SizedBox(width: 4),
                  Text('$coins',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: items.map((section) => Padding(
          padding: const EdgeInsets.only(bottom: NinjaSpacing.sm),
          child: _CategorySection(
            title: section.title,
            icon: section.icon,
            items: section.items,
            owned: owned,
            onBuy: (name, price) => _buyItem(context, ref, name, price, coins, owned),
          ),
        )).toList(),
      ),
    );
  }

  void _buyItem(BuildContext ctx, WidgetRef ref, String name, int price, int coins, Set<String> owned) {
    if (coins < price) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('金币不足！还需要 ${price - coins} 金币'),
          backgroundColor: NinjaColors.error,
        ),
      );
      return;
    }
    // 更新 Riverpod 状态
    ref.read(coinBalanceProvider.notifier).state = coins - price;
    final newOwned = Set<String>.from(owned)..add(name);
    ref.read(ownedItemsProvider.notifier).state = newOwned;
    // 持久化到本地
    Preferences.setInt('shop_coins', coins - price);
    Preferences.setStringList('shop_owned', newOwned.toList());

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('成功购买「$name」！'),
        backgroundColor: NinjaColors.success,
      ),
    );
  }
}

class _CategorySectionData {
  final String title;
  final Widget icon;
  final List<_ShopItemData> items;
  const _CategorySectionData({required this.title, required this.icon, required this.items});
}

class _CategorySection extends StatelessWidget {
  final String title;
  final Widget icon;
  final List<_ShopItemData> items;
  final Set<String> owned;
  final void Function(String name, int price) onBuy;

  const _CategorySection({
    required this.title, required this.icon, required this.items,
    required this.owned, required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: NinjaSpacing.xs, bottom: NinjaSpacing.md),
          child: Row(children: [icon, const SizedBox(width: NinjaSpacing.sm), Text(title, style: NinjaTextStyles.heading3)]),
        ),
        ...items.map((item) {
          final isOwned = owned.contains(item.name);
          return _ShopItem(name: item.name, price: item.price, owned: isOwned, onBuy: () => onBuy(item.name, item.price));
        }),
      ],
    );
  }
}

class _ShopItemData {
  final String name;
  final int price;
  const _ShopItemData(this.name, this.price);
}

class _ShopItem extends StatelessWidget {
  final String name;
  final int price;
  final bool owned;
  final VoidCallback onBuy;

  const _ShopItem({required this.name, required this.price, required this.owned, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: NinjaColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
          ),
          child: const Center(child: Icon(PhosphorIconsRegular.star, color: NinjaColors.primary, size: 22)),
        ),
        title: Text(name, style: NinjaTextStyles.titleSmall),
        subtitle: owned ? null : Text('$price 金币', style: NinjaTextStyles.caption.copyWith(color: NinjaColors.accentGold)),
        trailing: owned
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: NinjaColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(PhosphorIconsRegular.check, size: 14, color: NinjaColors.success),
                  const SizedBox(width: 4),
                  Text('已拥有', style: TextStyle(fontSize: 11, color: NinjaColors.success, fontWeight: FontWeight.w600)),
                ]),
              )
            : SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NinjaColors.accentGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('$price', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
      ),
    );
  }
}
