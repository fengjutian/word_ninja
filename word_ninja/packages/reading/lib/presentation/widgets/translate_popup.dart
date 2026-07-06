import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai/providers/ai_providers.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 划词翻译弹窗
/// 显示翻译结果并提供加入单词本和AI解析操作
class TranslatePopup extends ConsumerStatefulWidget {
  final String word;
  final void Function(String meaning, String example, String phonetic)? onAddToVocabulary;
  final VoidCallback? onAiAnalysis;

  const TranslatePopup({
    super.key,
    required this.word,
    this.onAddToVocabulary,
    this.onAiAnalysis,
  });

  @override
  ConsumerState<TranslatePopup> createState() => _TranslatePopupState();
}

class _TranslatePopupState extends ConsumerState<TranslatePopup> {
  Future<Map<String, dynamic>>? _translationFuture;
  Map<String, dynamic>? _translationData;

  @override
  void initState() {
    super.initState();
    _fetchTranslation();
  }

  @override
  void didUpdateWidget(covariant TranslatePopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word != widget.word) {
      _fetchTranslation();
    }
  }

  void _fetchTranslation() {
    _translationFuture = ref.read(aiChatServiceProvider).explainWord(widget.word);
    _translationFuture?.then((data) {
      if (mounted) setState(() => _translationData = data);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Text(widget.word, style: NinjaTextStyles.heading3),
              const SizedBox(height: 4),
              _TranslationResult(future: _translationFuture),
              const Divider(height: NinjaSpacing.lg),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      final data = _translationData;
                      if (widget.onAddToVocabulary != null && data != null) {
                        widget.onAddToVocabulary!(
                          data['meaning'] as String? ?? '',
                          data['example'] as String? ?? '',
                          data['phonetic'] as String? ?? '',
                        );
                      } else if (widget.onAddToVocabulary != null) {
                        widget.onAddToVocabulary!('', '', '');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('「${widget.word}」已加入单词本')),
                        );
                      }
                    },
                    icon: const Icon(PhosphorIconsRegular.bookmarkSimple, size: 16),
                    label: const Text('加入单词本'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: widget.onAiAnalysis ?? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('正在AI解析「${widget.word}」...')),
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

/// 翻译结果展示组件
class _TranslationResult extends StatelessWidget {
  final Future<Map<String, dynamic>>? future;
  const _TranslationResult({required this.future});

  @override
  Widget build(BuildContext context) {
    final f = future;
    if (f == null) {
      return const SizedBox(height: 20, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: f,
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
