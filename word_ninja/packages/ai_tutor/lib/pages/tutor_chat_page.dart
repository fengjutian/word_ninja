import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ai/ai.dart';
import 'package:vocabulary/presentation/providers/word_provider.dart';
import 'package:vocabulary/data/model/word.dart';
import '../providers/chat_history_provider.dart';
import 'analysis_page.dart';

part 'tutor_chat_widgets.dart';

/// AI 导师聊天页 — AI Tutor
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
          .map((m) =>
              {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();
      final notifier = ref.read(chatHistoryProvider.notifier);
      notifier.removeLast(); // 移除"思考中..."
      notifier.addMessage(ChatMessage('', isUser: false)); // 空消息，流式填充
      final stream = aiService.chatStream(
        message: text,
        systemPrompt: '你是英语学习导师 AI Tutor，用友好有趣的方式回答英语学习问题。用中文回复。',
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
      notifier.finishStream(); // 保存已接收的部分内容
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
    _callAiService(
        _msgCtrl.text.trim().isNotEmpty ? _msgCtrl.text.trim() : '请重试');
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
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
        .map((m) => '${m.isUser ? '👤 你' : '🤖 Tutor'}:\n${m.text}')
        .join('\n\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('对话已复制到剪贴板'), duration: Duration(seconds: 1)),
    );
  }

  void _addAiResponseToVocabulary(int index, List<ChatMessage> messages) {
    String? word;
    for (int j = index - 1; j >= 0; j--) {
      if (messages[j].isUser) {
        final match =
            RegExp(r"[a-zA-Z]{2,}(?:-[a-zA-Z]+)*").firstMatch(messages[j].text);
        if (match != null) word = match.group(0);
        break;
      }
    }
    if (word == null || word.isEmpty) return;

    final aiAnswer = messages[index].text; // AI 的回答内容

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('正在查询「$word」的释义...'),
          duration: const Duration(seconds: 1)),
    );

    final aiService = ref.read(aiChatServiceProvider);
    aiService.explainWord(word).then((data) {
      if (!mounted) return;
      final meaning =
          (data['meaning'] as String?) ?? _extractFirstLine(aiAnswer);
      final example = (data['example'] as String?)?.isNotEmpty == true
          ? data['example'] as String
          : aiAnswer;
      ref.read(wordListProvider.notifier).addWord(
            Word(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: 'local',
              word: word!,
              meaning: meaning,
              phonetic: (data['phonetic'] as String?) ?? '',
              example: example,
              tags: _parseCollocations(data['collocations']),
              source: 'ai_tutor',
              createdAt: DateTime.now(),
            ),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('已加入单词本（含释义、音标、例句、搭配）'),
            duration: Duration(seconds: 2)),
      );
    }).catchError((_) {
      if (!mounted) return;
      ref.read(wordListProvider.notifier).addWord(
            Word(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              userId: 'local',
              word: word!,
              meaning: _extractFirstLine(aiAnswer),
              example: aiAnswer,
              source: 'ai_tutor',
              createdAt: DateTime.now(),
            ),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('「$word」已加入单词本'),
            duration: const Duration(seconds: 1)),
      );
    });
  }

  /// 提取文本第一段纯文字作为简要释义
  String _extractFirstLine(String text) {
    // 去除 markdown 标记，取第一行
    final plain = text
        .replaceAll(RegExp(r'\*{1,3}'), '')
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .trim();
    final firstLine = plain
        .split('\n')
        .firstWhere((l) => l.trim().isNotEmpty, orElse: () => '待补充');
    return firstLine.length > 80
        ? '${firstLine.substring(0, 80)}...'
        : firstLine;
  }

  /// 解析 AI 返回的搭配为标签列表
  List<String> _parseCollocations(dynamic raw) {
    if (raw == null) return [];
    if (raw is List)
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    if (raw is String && raw.isNotEmpty) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
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
        onDelete: (i) =>
            ref.read(chatHistoryProvider.notifier).deleteSession(i),
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
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accentPurple],
                ),
              ),
              child: const Center(
                child: Text('S',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionsState.current.title,
                    style:
                        AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(_isLoading ? '输入中...' : '在线',
                      style: TextStyle(
                          fontSize: 12,
                          color: _isLoading
                              ? AppColors.warning
                              : AppColors.textOnDark.withValues(alpha: 0.7))),
                ],
              ),
            ),
            if (_lastError != null)
              IconButton(
                icon: Icon(PhosphorIconsRegular.arrowsClockwise,
                    size: 18,
                    color: AppColors.textOnDark.withValues(alpha: 0.7)),
                tooltip: '重试',
                onPressed: _retry,
              ),
            IconButton(
              icon: Icon(PhosphorIconsRegular.chartBar,
                  size: 18, color: AppColors.textOnDark.withValues(alpha: 0.7)),
              tooltip: '学习分析',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalysisPage()),
              ),
            ),
            IconButton(
              icon: Icon(PhosphorIconsRegular.copy,
                  size: 18, color: AppColors.textOnDark.withValues(alpha: 0.7)),
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
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                return _MessageBubble(
                  msg,
                  onTap: msg.isUser
                      ? () {
                          _msgCtrl.text = msg.text;
                          _msgCtrl.selection =
                              TextSelection.collapsed(offset: msg.text.length);
                        }
                      : null,
                  onDelete: msg.isLoading ? null : () => _deleteMessage(i),
                  onAddToVocab: !msg.isUser && !msg.isLoading && !msg.isError
                      ? () => _addAiResponseToVocabulary(i, messages)
                      : null,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.divider.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.microphone,
                        color: AppColors.primary),
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
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  CircleAvatar(
                    backgroundColor: _isLoading
                        ? AppColors.textSecondary
                        : AppColors.primary,
                    child: IconButton(
                      icon: Icon(PhosphorIconsRegular.paperPlaneTilt,
                          color: Colors.white, size: 18),
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
