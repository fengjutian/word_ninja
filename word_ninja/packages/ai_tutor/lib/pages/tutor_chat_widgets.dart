part of 'tutor_chat_page.dart';

/// 左侧会话抽屉
class _SessionDrawer extends StatelessWidget {
  final List<ChatSession> sessions;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onDelete;
  final VoidCallback onNew;

  const _SessionDrawer({
    required this.sessions,
    required this.currentIndex,
    required this.onSelect,
    required this.onDelete,
    required this.onNew,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: Column(
        children: [
          // 顶部：新会话按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onNew,
                  icon: const Icon(PhosphorIconsRegular.plus, size: 18),
                  label: const Text('新会话'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: BorderSide(
                        color: AppColors.divider.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          // 会话列表
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (ctx, i) {
                final s = sessions[i];
                final isActive = i == currentIndex;
                return _SessionTile(
                  title: s.title,
                  isActive: isActive,
                  onTap: () => onSelect(i),
                  onDelete: sessions.length > 1 ? () => onDelete(i) : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 会话列表项
class _SessionTile extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _SessionTile({
    required this.title,
    required this.isActive,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.primary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(PhosphorIconsRegular.trash,
                        size: 16, color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onAddToVocab;

  const _MessageBubble(this.message,
      {this.onTap, this.onDelete, this.onAddToVocab});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final bgColor = message.isError
        ? AppColors.error.withValues(alpha: 0.1)
        : message.isUser
            ? scheme.primary
            : colors.sidebar;
    final textColor = message.isError
        ? AppColors.error
        : message.isUser
            ? Colors.white
            : scheme.onSurface;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 820),
        margin: const EdgeInsets.only(bottom: 14),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onDelete,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: message.isUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: message.isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              border: Border.all(
                color: message.isError
                    ? AppColors.error.withValues(alpha: 0.3)
                    : message.isUser
                        ? scheme.primary
                        : colors.border,
              ),
            ),
            child: message.isLoading
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    const SizedBox(width: 8),
                    Text(message.text,
                        style: TextStyle(color: textColor, fontSize: 15)),
                  ])
                : message.isUser
                    ? Text(message.text,
                        style: TextStyle(color: textColor, fontSize: 15))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(children: [
                            Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: scheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(7)),
                                child: Icon(PhosphorIconsRegular.sparkle,
                                    size: 12, color: scheme.primary)),
                            const SizedBox(width: 8),
                            Text('WordFlow AI',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors.mutedText)),
                          ]),
                          const SizedBox(height: 10),
                          MarkdownBody(
                            data: message.text,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                  color: textColor, fontSize: 15, height: 1.5),
                              code: TextStyle(
                                color: AppColors.accentPurple,
                                backgroundColor: AppColors.background,
                                fontSize: 13,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          if (onAddToVocab != null)
                            GestureDetector(
                              onTap: onAddToVocab,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(PhosphorIconsRegular.bookmarkSimple,
                                        size: 12, color: scheme.primary),
                                    const SizedBox(width: 2),
                                    Text('加入单词本',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: scheme.primary)),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
