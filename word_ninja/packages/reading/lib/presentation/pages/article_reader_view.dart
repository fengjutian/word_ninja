part of 'reader_page.dart';

/// 文章阅读器
class _ArticleReaderView extends StatefulWidget {
  final _Article article;
  final WidgetRef ref;
  const _ArticleReaderView({required this.article, required this.ref});

  @override
  State<_ArticleReaderView> createState() => _ArticleReaderViewState();
}

class _ArticleReaderViewState extends State<_ArticleReaderView> {
  OverlayEntry? _popupOverlay;
  String _selectedText = '';

  WidgetRef get ref => widget.ref;

  @override
  void dispose() {
    _removePopup();
    super.dispose();
  }

  void _removePopup() {
    _popupOverlay?.remove();
    _popupOverlay = null;
  }

  void _showTranslatePopup(BuildContext context, String text) {
    _removePopup();
    if (text.trim().isEmpty) return;

    _selectedText = text.trim();
    final overlay = Overlay.of(context);
    final word = _selectedText;

    _popupOverlay = OverlayEntry(
      builder: (overlayContext) {
        // Position near the top of the screen; in a real app you'd compute
        // position from the selection rect using editableTextState.renderObject
        return Positioned(
          left: 16,
          right: 16,
          top: MediaQuery.of(overlayContext).padding.top + kToolbarHeight + 8,
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TranslatePopup(
                  word: word,
                  onAddToVocabulary: (meaning, example, phonetic) {
                    ref.read(wordListProvider.notifier).addWord(
                          Word(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            userId: 'local',
                            word: word,
                            meaning: meaning.isNotEmpty ? meaning : '待补充',
                            phonetic: phonetic,
                            example: example,
                            source: 'reading',
                            createdAt: DateTime.now(),
                          ),
                        );
                    _removePopup();
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _removePopup,
                    child: const Text('关闭'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    overlay.insert(_popupOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.article.content ?? '文章内容加载中...';

    return Scaffold(
      appBar: AppBar(title: Text(widget.article.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Chip(
                  label: Text(widget.article.level,
                      style: const TextStyle(fontSize: 11))),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                  child: Text(
                      '${widget.article.wordCount} 词 · ${widget.article.source}',
                      style: AppTextStyles.caption)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SelectableText(
            content,
            style: AppTextStyles.bodyLarge,
            contextMenuBuilder: (menuContext, editableTextState) {
              // Get the selected text
              final selection = editableTextState.textEditingValue.selection;
              String selected;
              if (selection.isValid && !selection.isCollapsed) {
                selected = selection
                    .textInside(editableTextState.textEditingValue.text);
              } else {
                selected = '';
              }

              // Show the translate popup overlay
              if (selected.trim().isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _showTranslatePopup(context, selected);
                });
              }

              // Return the default context menu
              return AdaptiveTextSelectionToolbar.buttonItems(
                buttonItems: [
                  if (selection.isValid && !selection.isCollapsed)
                    ...editableTextState.contextMenuButtonItems,
                  ContextMenuButtonItem(
                    label: '翻译',
                    onPressed: () {
                      if (selected.trim().isNotEmpty) {
                        _showTranslatePopup(context, selected);
                      }
                    },
                  ),
                ],
                anchors: editableTextState.contextMenuAnchors,
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          // 操作提示
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
            child: const Row(
              children: [
                Icon(PhosphorIconsRegular.handTap, color: AppColors.info),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('选中文字后可查看翻译、加入单词本、AI解析',
                      style: TextStyle(fontSize: 12, color: AppColors.info)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
