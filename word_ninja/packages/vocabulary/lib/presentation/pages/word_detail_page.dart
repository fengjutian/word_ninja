import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';
import '../../data/model/word.dart';

/// 单词详情页
class WordDetailPage extends ConsumerWidget {
  final Word word;

  const WordDetailPage({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(word.word),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 单词主信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(NinjaSpacing.xl),
                child: Column(
                  children: [
                    Text(word.word, style: NinjaTextStyles.displayMedium),
                    if (word.phonetic.isNotEmpty) ...[
                      const SizedBox(height: NinjaSpacing.sm),
                      Text('/${word.phonetic}/',
                          style: NinjaTextStyles.bodyLarge),
                    ],
                    const SizedBox(height: NinjaSpacing.md),
                    Text(word.meaning,
                        style: NinjaTextStyles.heading3.copyWith(
                          color: NinjaColors.primary,
                        )),
                    const SizedBox(height: NinjaSpacing.lg),
                    // 掌握度
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMasteryBadge(word.mastery),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: NinjaSpacing.lg),

            // 例句
            if (word.example.isNotEmpty) ...[
              const Text('例句', style: NinjaTextStyles.heading3),
              const SizedBox(height: NinjaSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(NinjaSpacing.lg),
                  child: Text(word.example,
                      style: NinjaTextStyles.bodyLarge),
                ),
              ),
              const SizedBox(height: NinjaSpacing.lg),
            ],

            // 标签
            if (word.tags.isNotEmpty) ...[
              const Text('标签', style: NinjaTextStyles.heading3),
              const SizedBox(height: NinjaSpacing.sm),
              Wrap(
                spacing: NinjaSpacing.sm,
                children: word.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: NinjaColors.primary
                              .withValues(alpha: 0.1),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMasteryBadge(int mastery) {
    final color = mastery >= 85
        ? NinjaColors.success
        : mastery >= 60
            ? NinjaColors.info
            : mastery >= 30
                ? NinjaColors.warning
                : NinjaColors.error;

    final label = mastery >= 85
        ? '已掌握'
        : mastery >= 60
            ? '熟悉'
            : mastery >= 30
                ? '学习中'
                : '陌生';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text('$label · $mastery%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          )),
    );
  }
}
