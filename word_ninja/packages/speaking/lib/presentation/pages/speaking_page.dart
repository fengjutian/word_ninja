import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
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
          padding: const EdgeInsets.all(NinjaSpacing.lg),
          child: Column(
            children: [
              const Icon(PhosphorIconsRegular.chatCircle, size: 48,
                  color: NinjaColors.textSecondary),
              const SizedBox(height: NinjaSpacing.lg),
              Text('$scene 场景', style: NinjaTextStyles.heading2),
              const SizedBox(height: NinjaSpacing.md),
              Text(_getSceneDesc(scene),
                  style: NinjaTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: NinjaSpacing.xl),
              Container(
                padding: const EdgeInsets.all(NinjaSpacing.lg),
                decoration: BoxDecoration(
                  color: NinjaColors.background,
                  borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
                  border: Border.all(color: NinjaColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('示例对话：', style: NinjaTextStyles.label),
                    const SizedBox(height: NinjaSpacing.sm),
                    Text(prompt, style: NinjaTextStyles.bodyLarge),
                    const SizedBox(height: NinjaSpacing.sm),
                    Text('点击播放收听系统 TTS 朗读',
                        style: NinjaTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: NinjaSpacing.lg),
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
    return Scaffold(
      appBar: AppBar(title: const Text('口语训练')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Semantics(header: true, child: Text('AI陪练场景', style: NinjaTextStyles.heading2)),
          const SizedBox(height: NinjaSpacing.md),
          _SceneCard('旅游', PhosphorIconsRegular.airplane, '机场、酒店、问路', () => _openScene('旅游')),
          _SceneCard('面试', PhosphorIconsRegular.briefcase, '英文面试对话', () => _openScene('面试')),
          _SceneCard('商务会议', PhosphorIconsRegular.usersThree, '商务谈判、演讲', () => _openScene('商务会议')),
          _SceneCard('日常聊天', PhosphorIconsRegular.chats, '朋友间的日常对话', () => _openScene('日常聊天')),
          const SizedBox(height: NinjaSpacing.xl),
          Semantics(header: true, child: Text('发音练习', style: NinjaTextStyles.heading2)),
          const SizedBox(height: NinjaSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.lg),
              child: Column(
                children: [
                  const Text('点击下方按钮收听标准发音，然后跟读练习：',
                      style: NinjaTextStyles.bodyMedium),
                  const SizedBox(height: NinjaSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(NinjaSpacing.lg),
                    decoration: BoxDecoration(
                      color: NinjaColors.background,
                      borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
                    ),
                    child: const Text(
                      '"The quick brown fox jumps over the lazy dog."',
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: NinjaSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isPlaying
                          ? null
                          : () => _playSentence(
                              'The quick brown fox jumps over the lazy dog.'),
                      icon: Icon(_isPlaying
                          ? PhosphorIconsRegular.hourglass
                          : PhosphorIconsRegular.play),
                      label: Text(_isPlaying ? '播放中...' : '播放发音'),
                    ),
                  ),
                  const SizedBox(height: NinjaSpacing.sm),
                  Semantics(
                    label: _isRecording ? '停止录音' : '开始录音',
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isPlaying ? null : _toggleRecording,
                        icon: Icon(_isRecording
                            ? PhosphorIconsRegular.microphone
                            : PhosphorIconsRegular.microphone),
                        label: Text(_isRecording ? '正在录音...' : '开始跟读'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording ? NinjaColors.error : null,
                        ),
                      ),
                    ),
                  ),
                  if (_isRecording) ...[
                    const SizedBox(height: NinjaSpacing.md),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(PhosphorIconsRegular.info, size: 14, color: NinjaColors.info),
                        SizedBox(width: 6),
                        Text('Windows STT 语音识别开发中，当前通过 TTS 播放示范',
                            style: TextStyle(
                                color: NinjaColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: ListTile(
        leading: Icon(icon, color: NinjaColors.primary, size: 28),
        title: Text(title, style: NinjaTextStyles.heading3),
        subtitle: Text(desc, style: NinjaTextStyles.bodySmall),
        trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
        onTap: onTap,
      ),
    );
  }
}
