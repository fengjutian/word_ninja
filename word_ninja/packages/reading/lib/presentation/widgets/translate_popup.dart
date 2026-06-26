import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai/providers/ai_providers.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 划词翻译弹窗
/// 显示翻译结果并提供加入单词本和AI解析操作
class TranslatePopup extends ConsumerWidget {
  final String word;
  final VoidCallback? onAddToVocabulary;
  final VoidCallback? onAiAnalysis;

  const TranslatePopup({
    super.key,
    required this.word,
    this.onAddToVocabulary,
    this.onAiAnalysis,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Builder(
        builder: (context) => Container(
          constraints: const BoxConstraints(maxWidth: 280),
          padding: const EdgeInsets.all(NinjaSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(word, style: NinjaTextStyles.heading3),
              const SizedBox(height: 4),
              _TranslationView(word: word),
              const Divider(height: NinjaSpacing.lg),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onAddToVocabulary ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('「$word」已加入单词本')),
                      );
                    },
                    icon: const Icon(PhosphorIconsRegular.bookmarkSimple, size: 16),
                    label: const Text('加入单词本'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onAiAnalysis ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('正在AI解析「$word」...')),
                      );
                    },
                    icon: const Icon(PhosphorIconsRegular.sparkle, size: 16),
                    label: const Text('AI解析'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 内嵌翻译组件 — 读取 AI 服务获取翻译
class _TranslationView extends ConsumerStatefulWidget {
  final String word;
  const _TranslationView({required this.word});

  @override
  ConsumerState<_TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends ConsumerState<_TranslationView> {
  Future<Map<String, dynamic>>? _translationFuture;

  @override
  Widget build(BuildContext context) {
    _translationFuture ??= ref.read(aiChatServiceProvider).explainWord(widget.word);
    return FutureBuilder<Map<String, dynamic>>(
      future: _translationFuture,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            child: Center(child: SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
          );
        }
        if (snapshot.hasData) {
          final data = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['meaning'] ?? '暂无翻译', style: NinjaTextStyles.bodyMedium),
              if (data['phonetic']?.isNotEmpty == true)
                Text(data['phonetic']!, style: NinjaTextStyles.caption),
            ],
          );
        }
        return Text('翻译失败', style: NinjaTextStyles.bodySmall.copyWith(color: NinjaColors.textSecondary));
      },
    );
  }
}
