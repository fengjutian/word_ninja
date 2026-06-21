import 'package:flutter/material.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 划词翻译弹窗
class TranslatePopup extends StatelessWidget {
  final String word;

  const TranslatePopup({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(NinjaSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(word, style: NinjaTextStyles.heading3),
            const SizedBox(height: 4),
            Text('待翻译', style: NinjaTextStyles.bodyMedium),
            const Divider(height: NinjaSpacing.lg),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_add, size: 16),
                  label: const Text('加入单词本'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('AI解析'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
