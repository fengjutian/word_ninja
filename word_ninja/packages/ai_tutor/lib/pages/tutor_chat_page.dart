import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ai/ai.dart';
import 'package:vocabulary/presentation/providers/word_provider.dart';
import 'package:vocabulary/data/model/word.dart';
import '../providers/chat_history_provider.dart';

/// AI 导师聊天页 — Sensei Shell
class TutorChatPage extends ConsumerStatefulWidget {
  const TutorChatPage({super.key});

  @override
  ConsumerState<TutorChatPage> createState() => _TutorChatPageState();
}

class _TutorChatPageState extends ConsumerState<TutorChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _drawerKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String? _lastError;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;
    final notifier = ref.read(chatHistoryProvider.notifier);
    notifier.addMessage(ChatMessage(text, isUser: true));
    notifier.addMessage(ChatMessage('思考中...', isUser: false, isLoading: true));
    _msgCtrl.clear();
    setState(() {
      _lastError = null;
      _isLoading = true;
    });
    _scrollToBottom();
    _callAiService(text);
  }

  Future<void> _callAiService(String text) async {
    try {
      final aiService = ref.read(aiChatServiceProvider);
      final state = ref.read(chatHistoryProvider);
      final messages = state.current.messages;
      final history = messages
          .where((m) => !m.isLoading)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();
      final notifier = ref.read(chatHistoryProvider.notifier);
      notifier.removeLast(); // 移除"思考中..."
      notifier.addMessage(ChatMessage('', isUser: false)); // 空消息，流式填充
      final stream = aiService.chatStream(
        message: text,
        systemPrompt: '你是英语忍者导师 Sensei Shell，用友好有趣的方式回答英语学习问题。用中文回复。',
        history: history,
      );
      await for (final chunk in stream) {
        if (!mounted) return;
        ref.read(chatHistoryProvider.notifier).appendToLastMessage(chunk);
        _scrollToBottom();
      }
      if (!mounted) return;
      ref.read(chatHistoryProvider.notifier).finishStream();
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      final notifier = ref.read(chatHistoryProvider.notifier);
      notifier.removeLast();
      notifier.addMessage(ChatMessage('抱歉，暂时无法连接AI。请稍后再试。', isUser: false, isError: true));
      setState(() {
        _lastError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _retry() {
    if (_lastError == null) return;
    final notifier = ref.read(chatHistoryProvider.notifier);
    notifier.removeLast();
    notifier.addMessage(ChatMessage('思考中...', isUser: false, isLoading: true));
    setState(() {
      _isLoading = true;
      _lastError = null;
    });
    _callAiService(_msgCtrl.text.trim().isNotEmpty ? _msgCtrl.text.trim() : '请重试');
  }

  void _selectAndClose(int index) {
    ref.read(chatHistoryProvider.notifier).switchToSession(index);
    _drawerKey.currentState?.closeDrawer();
    setState(() {
      _lastError = null;
      _isLoading = false;
    });
  }

  void _newAndClose() {
    ref.read(chatHistoryProvider.notifier).newSession();
    _drawerKey.currentState?.closeDrawer();
    setState(() {
      _lastError = null;
      _isLoading = false;
    });
  }

  void _deleteMessage(int index) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除消息'),
        content: const Text('确定要删除这条消息吗？\n删除用户消息时，AI 回复也会一并删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: NinjaColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(chatHistoryProvider.notifier).deleteAt(index);
      }
    });
  }

  void _copyConversation(List<ChatMessage> messages) {
    final text = messages
        .where((m) => !m.isLoading && !m.isError)
        .map((m) => '${m.isUser ? '👤 你' : '🤖 Sensei'}:\n${m.text}')
        .join('\n\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('对话已复制到剪贴板'), duration: Duration(seconds: 1)),
    );
  }

  void _addToVocabulary(String text) {
    // 提取第一个英文单词（字母组成，至少 2 个字符）
    final match = RegExp(r'[a-zA-Z]{2,}').firstMatch(text);
    if (match == null) return;
    final word = match.group(0)!;
    ref.read(wordListProvider.notifier).addWord(
      Word(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'local',
        word: word,
        meaning: '待补充',
        source: 'ai_tutor',
        createdAt: DateTime.now(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('「$word」已加入单词本'), duration: const Duration(seconds: 1)),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        final pos = _scrollCtrl.position;
        // 只在用户接近底部时自动滚动（距离底部 < 200px）
        if (pos.maxScrollExtent - pos.pixels < 200) {
          _scrollCtrl.animateTo(
            pos.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionsState = ref.watch(chatHistoryProvider);
    final messages = sessionsState.current.messages;

    return Scaffold(
      key: _drawerKey,
      drawer: _SessionDrawer(
        sessions: sessionsState.sessions,
        currentIndex: sessionsState.currentIndex,
        onSelect: _selectAndClose,
        onDelete: (i) => ref.read(chatHistoryProvider.notifier).deleteSession(i),
        onNew: _newAndClose,
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.list, color: Colors.white),
          onPressed: () => _drawerKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [NinjaColors.primary, NinjaColors.accentPurple],
                ),
              ),
              child: const Center(
                child: Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionsState.current.title,
                    style: NinjaTextStyles.titleMedium.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(_isLoading ? '输入中...' : '在线',
                      style: TextStyle(fontSize: 12, color: _isLoading ? NinjaColors.warning : NinjaColors.textOnDark.withValues(alpha: 0.7))),
                ],
              ),
            ),
            if (_lastError != null)
              IconButton(
                icon: Icon(PhosphorIconsRegular.arrowsClockwise, size: 18, color: NinjaColors.textOnDark.withValues(alpha: 0.7)),
                tooltip: '重试',
                onPressed: _retry,
              ),
            IconButton(
              icon: Icon(PhosphorIconsRegular.copy, size: 18, color: NinjaColors.textOnDark.withValues(alpha: 0.7)),
              tooltip: '复制对话',
              onPressed: () => _copyConversation(messages),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(NinjaSpacing.md),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                return _MessageBubble(
                  msg,
                  onTap: msg.isUser ? () {
                    _msgCtrl.text = msg.text;
                    _msgCtrl.selection = TextSelection.collapsed(offset: msg.text.length);
                  } : null,
                  onDelete: msg.isLoading ? null : () => _deleteMessage(i),
                  onAddToVocab: msg.isUser && !msg.isLoading
                      ? () => _addToVocabulary(msg.text)
                      : null,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(NinjaSpacing.md),
            decoration: BoxDecoration(
              color: NinjaColors.surface,
              boxShadow: [
                BoxShadow(
                  color: NinjaColors.divider.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.microphone, color: NinjaColors.primary),
                    tooltip: '语音输入（即将上线）',
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: InputDecoration(
                        hintText: '输入你的英语问题...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: NinjaSpacing.sm),
                  CircleAvatar(
                    backgroundColor: _isLoading ? NinjaColors.textSecondary : NinjaColors.primary,
                    child: IconButton(
                      icon: Icon(PhosphorIconsRegular.paperPlaneTilt, color: Colors.white, size: 18),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
              padding: const EdgeInsets.all(NinjaSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onNew,
                  icon: const Icon(PhosphorIconsRegular.plus, size: 18),
                  label: const Text('新会话'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: NinjaColors.textPrimary,
                    side: BorderSide(color: NinjaColors.divider.withValues(alpha: 0.5)),
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
      color: isActive ? NinjaColors.primary.withValues(alpha: 0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NinjaSpacing.md, vertical: NinjaSpacing.sm + 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? NinjaColors.primary : NinjaColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onDelete != null)
                GestureDetector(
                  onTap: onDelete,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(PhosphorIconsRegular.trash, size: 16, color: NinjaColors.textSecondary),
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

  const _MessageBubble(this.message, {this.onTap, this.onDelete, this.onAddToVocab});

  @override
  Widget build(BuildContext context) {
    final bgColor = message.isError
        ? NinjaColors.error.withValues(alpha: 0.1)
        : message.isUser
            ? NinjaColors.primary
            : NinjaColors.background;
    final textColor = message.isError
        ? NinjaColors.error
        : message.isUser
            ? Colors.white
            : NinjaColors.textPrimary;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onDelete,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          margin: const EdgeInsets.only(bottom: NinjaSpacing.sm),
          padding: const EdgeInsets.all(NinjaSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: message.isUser ? const Radius.circular(16) : const Radius.circular(4),
              bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(16),
            ),
            border: message.isError ? Border.all(color: NinjaColors.error.withValues(alpha: 0.3)) : null,
          ),
          child: message.isLoading
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Text(message.text, style: TextStyle(color: textColor, fontSize: 15)),
                ])
              : message.isUser
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message.text, style: TextStyle(color: textColor, fontSize: 15)),
                        if (onAddToVocab != null)
                          GestureDetector(
                            onTap: onAddToVocab,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(PhosphorIconsRegular.bookmarkSimple, size: 12, color: Colors.white70),
                                  const SizedBox(width: 2),
                                  Text('加入单词本', style: TextStyle(fontSize: 11, color: Colors.white70)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : MarkdownBody(
                      data: message.text,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: textColor, fontSize: 15, height: 1.5),
                        code: TextStyle(
                          color: NinjaColors.accentPurple,
                          backgroundColor: NinjaColors.background,
                          fontSize: 13,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: NinjaColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
