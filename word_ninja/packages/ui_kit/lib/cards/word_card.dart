import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import '../app_theme/app_theme.dart';

/// 单词卡片组件
class WordCard extends StatelessWidget {
  final String word;
  final String meaning;
  final String? phonetic;
  final int mastery;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WordCard({
    super.key,
    required this.word,
    required this.meaning,
    this.phonetic,
    required this.mastery,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _masteryColor(int value) {
    if (value < 30) return AppColors.error;
    if (value < 60) return AppColors.warning;
    if (value < 85) return AppColors.success;
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // 掌握度圆环
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: mastery / 100,
                      strokeWidth: 3,
                      backgroundColor: AppColors.divider.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _masteryColor(mastery),
                      ),
                    ),
                    Text(
                      '$mastery%',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _masteryColor(mastery),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 单词信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(word, style: AppTextStyles.heading3),
                    if (phonetic != null)
                      Text(phonetic!, style: AppTextStyles.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(meaning, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: '编辑',
                  onPressed: onEdit,
                  icon: const Icon(PhosphorIconsRegular.pencilSimple,
                      size: 19),
                ),
              if (onDelete != null)
                IconButton(
                  tooltip: '删除',
                  onPressed: onDelete,
                  color: AppColors.error,
                  icon: const Icon(PhosphorIconsRegular.trash, size: 19),
                ),
              const Icon(PhosphorIconsRegular.caretRight,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
