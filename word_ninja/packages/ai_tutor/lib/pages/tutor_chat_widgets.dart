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

  const _MessageBubble(
    this.message, {
    this.onTap,
    this.onDelete,
    this.onAddToVocab,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final background = message.isError
        ? AppColors.error.withValues(alpha: 0.08)
        : message.isUser
            ? scheme.primary.withValues(alpha: 0.10)
            : colors.sidebar;
    final textColor = message.isError ? AppColors.error : scheme.onSurface;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: message.isUser ? 560 : 760),
        margin: const EdgeInsets.only(bottom: 24),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onDelete,
          child: Container(
            padding: message.isUser
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
                : const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: message.isUser
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(5),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    )
                  : BorderRadius.circular(16),
              border: message.isError
                  ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
                  : message.isUser
                      ? null
                      : Border.all(color: colors.border),
              boxShadow: message.isUser
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
            ),
            child: message.isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        message.text,
                        style: TextStyle(color: textColor, fontSize: 14),
                      ),
                    ],
                  )
                : message.isUser
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ),
                          if (onDelete != null) ...[
                            const SizedBox(width: 8),
                            _MessageDeleteButton(onPressed: onDelete!),
                          ],
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  PhosphorIconsRegular.sparkle,
                                  size: 14,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'WordFlow AI',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.mutedText,
                                ),
                              ),
                              const Spacer(),
                              if (onDelete != null)
                                _MessageDeleteButton(onPressed: onDelete!),
                            ],
                          ),
                          const SizedBox(height: 12),
                          MarkdownBody(
                            data: message.text,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                height: 1.7,
                              ),
                              code: TextStyle(
                                color: AppColors.accentPurple,
                                backgroundColor: AppColors.background,
                                fontSize: 13,
                              ),
                              codeblockDecoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              h2: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                height: 1.45,
                                fontWeight: FontWeight.w700,
                              ),
                              h3: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                              blockquote: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                height: 1.7,
                                fontWeight: FontWeight.w500,
                              ),
                              blockquotePadding: const EdgeInsets.all(14),
                              blockquoteDecoration: BoxDecoration(
                                color: scheme.primaryContainer
                                    .withValues(alpha: 0.45),
                                border: Border(
                                  left: BorderSide(
                                    color: scheme.primary,
                                    width: 4,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              listBullet: TextStyle(
                                color: scheme.primary,
                                fontSize: 15,
                                height: 1.7,
                              ),
                              horizontalRuleDecoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: colors.border),
                                ),
                              ),
                            ),
                          ),
                          if (onAddToVocab != null) ...[
                            const SizedBox(height: 10),
                            Divider(height: 1, color: colors.border),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: onAddToVocab,
                              icon: const Icon(
                                PhosphorIconsRegular.bookmarkSimple,
                                size: 14,
                              ),
                              label: const Text('加入单词本'),
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

class _MessageDeleteButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _MessageDeleteButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: '删除消息',
      icon: const Icon(PhosphorIconsRegular.trash, size: 16),
      color: context.appColors.mutedText,
      hoverColor: AppColors.error.withValues(alpha: 0.08),
      highlightColor: AppColors.error.withValues(alpha: 0.12),
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }
}
