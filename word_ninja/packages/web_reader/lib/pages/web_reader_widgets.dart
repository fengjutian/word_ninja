part of 'web_reader_page.dart';

/// 聊天气泡
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAddToVocab;

  const _ChatBubble(this.message, {this.onAddToVocab});

  @override
  Widget build(BuildContext context) {
    final bgColor = message.isError
        ? AppColors.error.withValues(alpha: 0.1)
        : message.isUser
            ? AppColors.primary
            : AppColors.background;
    final textColor = message.isError
        ? AppColors.error
        : message.isUser
            ? Colors.white
            : AppColors.textPrimary;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: message.isUser
                ? const Radius.circular(12)
                : const Radius.circular(4),
            bottomRight: message.isUser
                ? const Radius.circular(4)
                : const Radius.circular(12),
          ),
        ),
        child: message.isLoading
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 6),
                Flexible(
                    child: Text(message.text,
                        style: TextStyle(color: textColor, fontSize: 13))),
              ])
            : message.isUser
                ? Text(message.text,
                    style: TextStyle(color: textColor, fontSize: 14))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MarkdownBody(
                        data: message.text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                              color: textColor, fontSize: 14, height: 1.4),
                          code: TextStyle(
                            color: AppColors.accentPurple,
                            backgroundColor: AppColors.background,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (onAddToVocab != null)
                        GestureDetector(
                          onTap: onAddToVocab,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(PhosphorIconsRegular.bookmarkSimple,
                                    size: 11,
                                    color: AppColors.primary
                                        .withValues(alpha: 0.7)),
                                const SizedBox(width: 2),
                                Text('加入单词本',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.primary
                                            .withValues(alpha: 0.7))),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}
