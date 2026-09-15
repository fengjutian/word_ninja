import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
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
            icon: const Icon(PhosphorIconsRegular.pencilSimple),
            tooltip: '编辑单词',
            onPressed: () => context.push('/vocabulary/edit/${word.id}'),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.trash),
            tooltip: '删除单词',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 单词主信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Text(word.word, style: AppTextStyles.displayMedium),
                    if (word.phonetic.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text('/${word.phonetic}/',
                          style: AppTextStyles.bodyLarge),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Text(word.meaning,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primary,
                        )),
                    const SizedBox(height: AppSpacing.lg),
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
            const SizedBox(height: AppSpacing.lg),

            // 例句
            if (word.example.isNotEmpty) ...[
              const Text('例句', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(word.example, style: AppTextStyles.bodyLarge),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // 标签
            if (word.tags.isNotEmpty) ...[
              const Text('标签', style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: word.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
    if (mastery >= 85) return (AppColors.success, '已掌握');
    if (mastery >= 60) return (AppColors.info, '熟悉');
    if (mastery >= 30) return (AppColors.warning, '学习中');
    return (AppColors.error, '陌生');
  }
}
