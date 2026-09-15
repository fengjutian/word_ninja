import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/design_tokens.dart';
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
        final matches =
            RegExp(r"[a-zA-Z]{3,}(?:-[a-zA-Z]+)*").allMatches(messages[j].text);
        const ignored = {
          'nan',
          'null',
          'undefined',
          'out',
          'the',
          'and',
          'you'
        };
        for (final match in matches) {
          final candidate = match.group(0)!.toLowerCase();
          if (!ignored.contains(candidate)) {
            word = candidate;
            break;
          }
        }
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
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

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
        toolbarHeight: 62,
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.sidebarSimple),
          tooltip: '会话记录',
          onPressed: () => _drawerKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(PhosphorIconsRegular.sparkle,
                  size: 17, color: scheme.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionsState.current.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(_isLoading ? '正在思考…' : 'AI 英语学习导师',
                      style: TextStyle(fontSize: 11, color: colors.mutedText)),
                ],
              ),
            ),
            if (_lastError != null)
              IconButton(
                icon:
                    const Icon(PhosphorIconsRegular.arrowsClockwise, size: 18),
                tooltip: '重试',
                onPressed: _retry,
              ),
            IconButton(
              icon: const Icon(PhosphorIconsRegular.chartBar, size: 18),
              tooltip: '学习分析',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalysisPage()),
              ),
            ),
            IconButton(
              icon: const Icon(PhosphorIconsRegular.copy, size: 18),
              tooltip: '复制对话',
              onPressed: () => _copyConversation(messages),
            ),
          ],
        ),
      ),
      backgroundColor: colors.canvas,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[i];
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: _MessageBubble(
                      msg,
                      onTap: msg.isUser
                          ? () {
                              _msgCtrl.text = msg.text;
                              _msgCtrl.selection = TextSelection.collapsed(
                                  offset: msg.text.length);
                            }
                          : null,
                      onDelete: msg.isLoading ? null : () => _deleteMessage(i),
                      onAddToVocab:
                          !msg.isUser && !msg.isLoading && !msg.isError
                              ? () => _addAiResponseToVocabulary(i, messages)
                              : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
            color: colors.canvas,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.sidebar,
                      border: Border.all(color: colors.border),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 18,
                            offset: Offset(0, 5))
                      ],
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: '询问单词、语法、写作或口语问题…',
                        prefixIcon: IconButton(
                          icon: Icon(PhosphorIconsRegular.microphone,
                              size: 19, color: colors.mutedText),
                          tooltip: '语音输入（即将上线）',
                          onPressed: () {},
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(5),
                          child: IconButton.filled(
                            icon: const Icon(PhosphorIconsRegular.arrowUp,
                                size: 17),
                            onPressed: _isLoading ? null : _sendMessage,
                          ),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
