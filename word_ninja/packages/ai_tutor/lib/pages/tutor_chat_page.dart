import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ai/ai.dart';

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
      '你好！我是 Sensei Shell，你的英语忍者导师。\n有什么问题尽管问我！',
      isUser: false,
    ),
  ];
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
    setState(() {
      _messages.add(_ChatMessage(text, isUser: true));
      _messages.add(_ChatMessage('思考中...', isUser: false, isLoading: true));
      _msgCtrl.clear();
      _lastError = null;
      _isLoading = true;
    });
    _scrollToBottom();
    _callAiService(text);
  }

  Future<void> _callAiService(String text) async {
    try {
      final aiService = ref.read(aiChatServiceProvider);
      // 构建聊天历史
      final history = _messages
          .where((m) => !m.isLoading)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();
      final reply = await aiService.chat(
        message: text,
        systemPrompt: '你是英语忍者导师 Sensei Shell，用友好有趣的方式回答英语学习问题。用中文回复。',
        history: history,
      );
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage(reply, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(_ChatMessage('抱歉，暂时无法连接AI。请稍后再试。', isUser: false, isError: true));
        _lastError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _retry() {
    if (_lastError == null) return;
    // 移除最后的错误消息和加载消息
    setState(() {
      if (_messages.length >= 2) {
        _messages.removeLast(); // 错误消息
        final lastUserMsg = _messages.lastWhere((m) => m.isUser, orElse: () => _messages.last);
        _messages.add(_ChatMessage('思考中...', isUser: false, isLoading: true));
        _isLoading = true;
        _lastError = null;
      }
    });
    _callAiService(_msgCtrl.text.trim().isNotEmpty ? _msgCtrl.text.trim() : '请重试');
  }

  void _scrollToBottom() {
    Future.microtask(() {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Text('Sensei Shell', style: NinjaTextStyles.titleMedium.copyWith(color: Colors.white)),
                Text(_isLoading ? '输入中...' : '在线',
                    style: TextStyle(fontSize: 12, color: _isLoading ? NinjaColors.warning : NinjaColors.textOnDark.withValues(alpha: 0.7))),
              ],
            ),
            const Spacer(),
            if (_lastError != null)
              IconButton(
                icon: Icon(PhosphorIconsRegular.arrowsClockwise, size: 18, color: NinjaColors.textOnDark.withValues(alpha: 0.7)),
                tooltip: '重试',
                onPressed: _retry,
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
                return Semantics(
                  label: msg.isUser ? '你: ${msg.text}' : 'Sensei: ${msg.text}',
                  child: _MessageBubble(msg),
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('语音输入功能即将上线'), duration: Duration(seconds: 1)),
                      );
                    },
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
                  Semantics(
                    label: '发送消息',
                    child: CircleAvatar(
                      backgroundColor: _isLoading ? NinjaColors.textSecondary : NinjaColors.primary,
                      child: IconButton(
                        icon: Icon(PhosphorIconsRegular.paperPlaneTilt, color: Colors.white, size: 18),
                        onPressed: _isLoading ? null : _sendMessage,
                      ),
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
  final bool isError;

  const _ChatMessage(this.text, {required this.isUser, this.isLoading = false, this.isError = false});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble(this.message);

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
            : Text(message.text, style: TextStyle(color: textColor, fontSize: 15)),
      ),
    );
  }
}
