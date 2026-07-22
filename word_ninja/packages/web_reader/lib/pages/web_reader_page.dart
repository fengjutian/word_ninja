import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ai/ai.dart';
import 'package:ai_tutor/ai_tutor.dart';
import 'package:vocabulary/presentation/providers/word_provider.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:http/http.dart' as http;
import 'package:core/logger/logger.dart';

/// Web 阅读页面 — 左侧 WebView + 右侧 AI 对话
class WebReaderPage extends ConsumerStatefulWidget {
  const WebReaderPage({super.key});

  @override
  ConsumerState<WebReaderPage> createState() => _WebReaderPageState();
}

class _WebReaderPageState extends ConsumerState<WebReaderPage> {
  late final WebViewController _webViewCtrl;
  final _urlCtrl = TextEditingController(text: 'https://');
  final _chatCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isChatLoading = false;
  String? _lastChatError;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(NinjaColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              _urlCtrl.text = url;
              _urlCtrl.selection = TextSelection.collapsed(offset: url.length);
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              _urlCtrl.text = url;
            }
          },
          onWebResourceError: (error) {
            log.w('WebView error: ${error.description}');
          },
        ),
      );
  }

  void _navigateToUrl() {
    final text = _urlCtrl.text.trim();
    if (text.isEmpty) return;
    String url = text;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
      _urlCtrl.text = url;
    }
    _webViewCtrl.loadRequest(Uri.parse(url));
  }

  void _sendChatMessage() {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty || _isChatLoading) return;
    final notifier = ref.read(chatHistoryProvider.notifier);
    notifier.addMessage(ChatMessage(text, isUser: true));
    notifier.addMessage(ChatMessage('思考中...', isUser: false, isLoading: true));
    _chatCtrl.clear();
    setState(() {
      _lastChatError = null;
      _isChatLoading = true;
    });
    _scrollChatToBottom();
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
      notifier.removeLast();
      notifier.addMessage(ChatMessage('', isUser: false));
      final stream = aiService.chatStream(
        message: text,
        systemPrompt: '你是英语忍者导师 Sensei Shell。你在帮助用户阅读网页内容，用友好有趣的方式解答关于网页文章的英语问题。用中文回复。',
        history: history,
      );
      await for (final chunk in stream) {
        if (!mounted) return;
        ref.read(chatHistoryProvider.notifier).appendToLastMessage(chunk);
        _scrollChatToBottom();
      }
      if (!mounted) return;
      ref.read(chatHistoryProvider.notifier).finishStream();
      setState(() => _isChatLoading = false);
    } catch (e) {
      if (!mounted) return;
      final notifier = ref.read(chatHistoryProvider.notifier);
      notifier.finishStream(); // 保存已接收的部分内容
      setState(() {
        _lastChatError = e.toString();
        _isChatLoading = false;
      });
    }
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        final pos = _scrollCtrl.position;
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

  void _askAboutPage() {
    _webViewCtrl.getTitle().then((title) {
      _chatCtrl.text = '请帮我分析一下这篇文章：${title ?? "网页"}';
      _sendChatMessage();
    });
  }

  void _addAiToVocabulary(int index, List<ChatMessage> messages) {
    String? word;
    for (int j = index - 1; j >= 0; j--) {
      if (messages[j].isUser) {
        final match = RegExp(r"[a-zA-Z]{2,}(?:-[a-zA-Z]+)*").firstMatch(messages[j].text);
        if (match != null) word = match.group(0);
        break;
      }
    }
    if (word == null || word.isEmpty) return;

    final aiAnswer = messages[index].text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在查询「$word」的释义...'), duration: const Duration(seconds: 1)),
    );

    final aiService = ref.read(aiChatServiceProvider);
    aiService.explainWord(word).then((data) {
      if (!mounted) return;
      final meaning = (data['meaning'] as String?) ?? _extractFirstLine(aiAnswer);
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
          source: 'web_reader',
          createdAt: DateTime.now(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已加入单词本'), duration: Duration(seconds: 2)),
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
          source: 'web_reader',
          createdAt: DateTime.now(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「$word」已加入单词本'), duration: const Duration(seconds: 1)),
      );
    });
  }

  String _extractFirstLine(String text) {
    final plain = text
        .replaceAll(RegExp(r'\*{1,3}'), '')
        .replaceAll(RegExp(r'#{1,6}\s*'), '')
        .trim();
    final firstLine = plain.split('\n').firstWhere((l) => l.trim().isNotEmpty, orElse: () => '待补充');
    return firstLine.length > 80 ? '${firstLine.substring(0, 80)}...' : firstLine;
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('网页阅读'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.robot),
            tooltip: 'AI 分析当前网页',
            onPressed: _askAboutPage,
          ),
        ],
      ),
      body: isWide
          ? _buildWideLayout()
          : _buildNarrowLayout(),
    );
  }

  /// 宽屏布局：左右分栏
  Widget _buildWideLayout() {
    return Row(
      children: [
        // 左侧：WebView
        Expanded(
          flex: 5,
          child: _buildWebViewPanel(),
        ),
        const VerticalDivider(width: 1),
        // 右侧：AI 对话
        Expanded(
          flex: 4,
          child: _buildChatPanel(),
        ),
      ],
    );
  }

  /// 窄屏布局：Tab 切换
  Widget _buildNarrowLayout() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: NinjaColors.primary,
            unselectedLabelColor: NinjaColors.textSecondary,
            tabs: const [
              Tab(icon: Icon(PhosphorIconsRegular.browser), text: '网页'),
              Tab(icon: Icon(PhosphorIconsRegular.chatCircle), text: 'AI对话'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildWebViewPanel(),
                _buildChatPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// WebView 面板
  Widget _buildWebViewPanel() {
    return Column(
      children: [
        // URL 栏
        Container(
          padding: const EdgeInsets.all(NinjaSpacing.sm),
          color: NinjaColors.surface,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(PhosphorIconsRegular.arrowLeft, size: 20),
                tooltip: '后退',
                onPressed: () => _webViewCtrl.goBack(),
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.arrowRight, size: 20),
                tooltip: '前进',
                onPressed: () => _webViewCtrl.goForward(),
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.arrowsClockwise, size: 20),
                tooltip: '刷新',
                onPressed: () => _webViewCtrl.reload(),
              ),
              Expanded(
                child: TextField(
                  controller: _urlCtrl,
                  decoration: InputDecoration(
                    hintText: '输入网址...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(PhosphorIconsRegular.arrowRight, size: 18),
                      onPressed: _navigateToUrl,
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  onSubmitted: (_) => _navigateToUrl(),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // WebView
        Expanded(
          child: WebViewWidget(controller: _webViewCtrl),
        ),
      ],
    );
  }

  /// AI 对话面板
  Widget _buildChatPanel() {
    final sessionsState = ref.watch(chatHistoryProvider);
    final messages = sessionsState.current.messages;

    return Column(
      children: [
        // 对话列表
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(NinjaSpacing.sm),
            itemCount: messages.length,
            itemBuilder: (ctx, i) {
              final msg = messages[i];
              return _ChatBubble(
                msg,
                onAddToVocab: !msg.isUser && !msg.isLoading && !msg.isError
                    ? () => _addAiToVocabulary(i, messages)
                    : null,
              );
            },
          ),
        ),
        const Divider(height: 1),
        // 输入栏
        Container(
          padding: const EdgeInsets.all(NinjaSpacing.sm),
          color: NinjaColors.surface,
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatCtrl,
                    decoration: InputDecoration(
                      hintText: '询问 AI 关于网页内容...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendChatMessage(),
                  ),
                ),
                const SizedBox(width: NinjaSpacing.xs),
                CircleAvatar(
                  backgroundColor: _isChatLoading ? NinjaColors.textSecondary : NinjaColors.primary,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(PhosphorIconsRegular.paperPlaneTilt, color: Colors.white, size: 16),
                    padding: EdgeInsets.zero,
                    onPressed: _isChatLoading ? null : _sendChatMessage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 聊天气泡
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onAddToVocab;

  const _ChatBubble(this.message, {this.onAddToVocab});

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
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        margin: const EdgeInsets.only(bottom: NinjaSpacing.xs),
        padding: const EdgeInsets.all(NinjaSpacing.sm),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: message.isUser ? const Radius.circular(12) : const Radius.circular(4),
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(12),
          ),
        ),
        child: message.isLoading
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                const SizedBox(width: 6),
                Flexible(child: Text(message.text, style: TextStyle(color: textColor, fontSize: 13))),
              ])
            : message.isUser
                ? Text(message.text, style: TextStyle(color: textColor, fontSize: 14))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MarkdownBody(
                        data: message.text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(color: textColor, fontSize: 14, height: 1.4),
                          code: TextStyle(
                            color: NinjaColors.accentPurple,
                            backgroundColor: NinjaColors.background,
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
                                Icon(PhosphorIconsRegular.bookmarkSimple, size: 11, color: NinjaColors.primary.withValues(alpha: 0.7)),
                                const SizedBox(width: 2),
                                Text('加入单词本', style: TextStyle(fontSize: 10, color: NinjaColors.primary.withValues(alpha: 0.7))),
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
