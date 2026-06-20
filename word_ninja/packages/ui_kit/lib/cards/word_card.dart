import 'package:flutter/material.dart';
import '../ninja_theme/ninja_theme.dart';

/// 单词卡片组件
class WordCard extends StatelessWidget {
  final String word;
  final String meaning;
  final String? phonetic;
  final int mastery;
  final VoidCallback? onTap;

  const WordCard({
    super.key,
    required this.word,
    required this.meaning,
    this.phonetic,
    required this.mastery,
    this.onTap,
  });

  Color _masteryColor(int value) {
    if (value < 30) return NinjaColors.error;
    if (value < 60) return NinjaColors.warning;
    if (value < 85) return NinjaColors.success;
    return NinjaColors.info;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: NinjaSpacing.lg,
        vertical: NinjaSpacing.sm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(NinjaSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(NinjaSpacing.lg),
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
                      backgroundColor: NinjaColors.divider.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _masteryColor(mastery),
                      ),
                    ),
                    Text(
                      '$mastery%',
                      style: NinjaTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _masteryColor(mastery),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: NinjaSpacing.md),
              // 单词信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(word, style: NinjaTextStyles.heading3),
                    if (phonetic != null)
                      Text(phonetic!,
                          style: NinjaTextStyles.bodySmall),
                    const SizedBox(height: NinjaSpacing.xs),
                    Text(meaning, style: NinjaTextStyles.bodyMedium),
                  ],
                ),
              ),
              // 箭头
              const Icon(Icons.chevron_right, color: NinjaColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
