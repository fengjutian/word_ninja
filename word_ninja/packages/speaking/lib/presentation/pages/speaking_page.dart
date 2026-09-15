import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/design_tokens.dart';
import 'package:listening/providers/tts_provider.dart';

/// 口语训练页 - 场景选择 + 发音练习 + TTS 播放
class SpeakingPage extends ConsumerStatefulWidget {
  const SpeakingPage({super.key});

  @override
  ConsumerState<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends ConsumerState<SpeakingPage> {
  bool _isPlaying = false;
  bool _isRecording = false;

  Future<void> _playSentence(String text) async {
    final tts = ref.read(ttsServiceProvider);
    setState(() => _isPlaying = true);
    await tts.speak(text, rate: 0.8);
    if (mounted) setState(() => _isPlaying = false);
  }

  void _toggleRecording() {
    if (_isPlaying) return;
    setState(() => _isRecording = !_isRecording);
    if (_isRecording) {
      // Windows STT not yet available — play the sentence via TTS instead
      _playSentence('The quick brown fox jumps over the lazy dog.');
      setState(() => _isRecording = false);
    }
  }

  void _openScene(String scene) {
    final tts = ref.read(ttsServiceProvider);
    final prompt = _getScenePrompt(scene);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('$scene · AI陪练')),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Icon(PhosphorIconsRegular.chatCircle,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.lg),
              Text('$scene 场景', style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.md),
              Text(_getSceneDesc(scene),
                  style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('示例对话：', style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.sm),
                    Text(prompt, style: AppTextStyles.bodyLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text('点击播放收听系统 TTS 朗读', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                FilledButton.icon(
                  onPressed: () => tts.speak(prompt, rate: 0.8),
                  icon: const Icon(PhosphorIconsRegular.play),
                  label: const Text('播放'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => tts.stop(),
                  icon: const Icon(PhosphorIconsRegular.stop),
                  label: const Text('停止'),
                ),
              ]),
            ],
          ),
        ),
      ),
    ));
  }

  String _getScenePrompt(String scene) {
    switch (scene) {
      case '旅游':
        return 'Excuse me, could you tell me how to get to the nearest subway station? I need to catch a train to the airport.';
      case '面试':
        return 'Tell me about yourself and why you are interested in this position. What are your greatest strengths?';
      case '商务会议':
        return 'I would like to present our quarterly results. Our revenue has increased by fifteen percent compared to last quarter.';
      default:
        return 'Hi, how are you doing today? The weather is really nice, isn\'t it? What do you like to do in your free time?';
    }
  }

  String _getSceneDesc(String scene) {
    switch (scene) {
      case '旅游':
        return '练习机场、酒店、餐厅等旅游场景下的英语对话。';
      case '面试':
        return '模拟英文面试场景，练习自我介绍和常见面试问题。';
      case '商务会议':
        return '练习商务谈判、演讲和会议中的专业英语表达。';
      default:
        return '与 AI 进行日常英语对话，提升口语流利度。';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
        child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(PhosphorIconsRegular.microphone,
                              color: Theme.of(context).colorScheme.primary,
                              size: 22)),
                      const SizedBox(width: 14),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('口语训练',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 3),
                            Text('用真实场景练表达，用标准发音练流利度',
                                style: TextStyle(
                                    fontSize: 13, color: colors.mutedText))
                          ])
                    ]),
                    const SizedBox(height: 30),
                    Text('AI 陪练场景',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                        builder: (context, box) => Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _SceneCard('旅游', PhosphorIconsRegular.airplane,
                                  '机场、酒店与问路', () => _openScene('旅游')),
                              _SceneCard('面试', PhosphorIconsRegular.briefcase,
                                  '英文面试与自我介绍', () => _openScene('面试')),
                              _SceneCard(
                                  '商务会议',
                                  PhosphorIconsRegular.usersThree,
                                  '商务谈判与演讲',
                                  () => _openScene('商务会议')),
                              _SceneCard('日常聊天', PhosphorIconsRegular.chats,
                                  '自然的日常对话', () => _openScene('日常聊天')),
                            ]
                                .map((item) => SizedBox(
                                    width: box.maxWidth > 760
                                        ? (box.maxWidth - 12) / 2
                                        : box.maxWidth,
                                    child: item))
                                .toList())),
                    const SizedBox(height: 30),
                    Text('发音练习', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 14),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(children: [
                              Icon(PhosphorIconsRegular.waveform,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 10),
                              const Text('今日发音句',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text('预计 2 分钟',
                                  style: TextStyle(
                                      fontSize: 11, color: colors.mutedText))
                            ]),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 24),
                              decoration: BoxDecoration(
                                color: colors.subtleSurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '"The quick brown fox jumps over the lazy dog."',
                                style: TextStyle(
                                    fontSize: 18, fontStyle: FontStyle.italic),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(children: [
                              Expanded(
                                  child: FilledButton.icon(
                                onPressed: _isPlaying
                                    ? null
                                    : () => _playSentence(
                                        'The quick brown fox jumps over the lazy dog.'),
                                icon: Icon(_isPlaying
                                    ? PhosphorIconsRegular.hourglass
                                    : PhosphorIconsRegular.play),
                                label: Text(_isPlaying ? '播放中...' : '播放发音'),
                              )),
                              const SizedBox(width: 10),
                              Semantics(
                                label: _isRecording ? '停止录音' : '开始录音',
                                child: OutlinedButton.icon(
                                  onPressed:
                                      _isPlaying ? null : _toggleRecording,
                                  icon: Icon(_isRecording
                                      ? PhosphorIconsRegular.microphone
                                      : PhosphorIconsRegular.microphone),
                                  label:
                                      Text(_isRecording ? '正在录音...' : '开始跟读'),
                                ),
                              )
                            ]),
                            if (_isRecording) ...[
                              const SizedBox(height: AppSpacing.md),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(PhosphorIconsRegular.info,
                                      size: 14, color: AppColors.info),
                                  SizedBox(width: 6),
                                  Text('Windows STT 语音识别开发中，当前通过 TTS 播放示范',
                                      style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12)),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ])),
        ),
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String desc;
  final VoidCallback onTap;

  const _SceneCard(this.title, this.icon, this.desc, this.onTap);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        leading: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 20)),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle:
            Text(desc, style: TextStyle(fontSize: 12, color: colors.mutedText)),
        trailing: Icon(PhosphorIconsRegular.caretRight,
            size: 16, color: colors.mutedText),
        onTap: onTap,
      ),
    );
  }
}
