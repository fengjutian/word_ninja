import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import '../../data/model/word.dart';
import '../providers/word_provider.dart';

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
            icon: const Icon(PhosphorIcons.regular.pencilSimple),
            tooltip: '编辑单词',
            onPressed: () => context.push('/vocabulary/edit/${word.id}'),
          ),
          IconButton(
            icon: const Icon(PhosphorIcons.regular.trash),
            tooltip: '删除单词',
            onPressed: () => _confirmDelete(context, ref),
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除单词'),
        content: Text('确定要删除 "${word.word}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(wordListProvider.notifier).deleteWord(word.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('单词已删除')),
                  );
                  context.pop();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: NinjaColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryBadge(int mastery) {
    final (color, label) = _masteryInfo(mastery);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text('$label · $mastery%',
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }

  (Color, String) _masteryInfo(int mastery) {
    if (mastery >= 85) return (NinjaColors.success, '已掌握');
    if (mastery >= 60) return (NinjaColors.info, '熟悉');
    if (mastery >= 30) return (NinjaColors.warning, '学习中');
    return (NinjaColors.error, '陌生');
  }
}
