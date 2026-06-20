import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';
import 'package:ai/lib/services/ai_chat_service.dart';

/// AI 导师聊天页 — Sensei Shell
class TutorChatPage extends ConsumerStatefulWidget {
  const TutorChatPage({super.key});

  @override
  ConsumerState<TutorChatPage> createState() => _TutorChatPageState();
}

class _TutorChatPageState extends ConsumerState<TutorChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <_ChatMessage>[
    _ChatMessage(
      'こんにちは！我是 Sensei Shell，你的英语忍者导师。\n有什么问题尽管问我！',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, isUser: true));
      _messages.add(_ChatMessage(
        '思考中... 🧠',
        isUser: false,
        isLoading: true,
      ));
      _msgCtrl.clear();
    });
    _scrollToBottom();

    // 调用 AI 服务
    _callAiService(text);
  }

  Future<void> _callAiService(String text) async {
    try {
      final aiService = ref.read(aiChatServiceProvider);
      final reply = await aiService.chat(message: text, systemPrompt: '你是一个英语忍者导师 Sensei Shell，用友好有趣的方式回答英语学习问题。');
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage(reply, isUser: false));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage('抱歉，暂时无法连接AI。请稍后再试。', isUser: false));
      });
    }
  }

  void _scrollToBottom() {
    Future.microtask(() => _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sensei Shell', style: TextStyle(fontSize: 16)),
                Text('在线', style: TextStyle(fontSize: 12, color: Colors.white70)),
              ],
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
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                return _MessageBubble(msg);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(NinjaSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic, color: NinjaColors.primary),
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
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: NinjaSpacing.sm),
                  CircleAvatar(
                    backgroundColor: NinjaColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
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

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;

  const _ChatMessage(this.text, {required this.isUser, this.isLoading = false});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble(this.message);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: NinjaSpacing.sm),
        padding: const EdgeInsets.all(NinjaSpacing.md),
        decoration: BoxDecoration(
          color: message.isUser
              ? NinjaColors.primary
              : NinjaColors.background,
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
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : NinjaColors.textPrimary,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
