import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 口语训练页 - 场景选择 + 发音练习 + 录音
class SpeakingPage extends ConsumerStatefulWidget {
  const SpeakingPage({super.key});

  @override
  ConsumerState<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends ConsumerState<SpeakingPage> {
  bool _isRecording = false;

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('麦克风录音功能需要设备权限和 STT 服务支持。\n当前为演示模式。'), duration: Duration(seconds: 3)),
      );
    }
    // 模拟录音 2 秒后自动停止
    if (_isRecording) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isRecording = false);
      });
    }
  }

  void _openScene(String scene) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('$scene · AI陪练')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(PhosphorIconsRegular.chatCircle, size: 64, color: NinjaColors.textSecondary),
              const SizedBox(height: NinjaSpacing.lg),
              Text('$scene 场景', style: NinjaTextStyles.heading2),
              const SizedBox(height: NinjaSpacing.md),
              Text(
                scene == '旅游' ? '练习机场、酒店、餐厅等旅游场景下的英语对话。'
                    : scene == '面试' ? '模拟英文面试场景，练习自我介绍和常见面试问题。'
                    : scene == '商务会议' ? '练习商务谈判、演讲和会议中的专业英语表达。'
                    : '与 AI 进行日常英语对话，提升口语流利度。',
                style: NinjaTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NinjaSpacing.xl),
              Semantics(
                label: '开始AI语音对话',
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(_).showSnackBar(
                      const SnackBar(content: Text('语音对话功能需要 STT/TTS 服务，请在设置中配置。'), duration: Duration(seconds: 2)),
                    );
                  },
                  icon: const Icon(PhosphorIconsRegular.play),
                  label: const Text('开始对话'),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
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
                  const Text('朗读以下句子，AI 将评估你的发音：', style: NinjaTextStyles.bodyMedium),
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
                  Semantics(
                    label: _isRecording ? '停止录音' : '开始录音',
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _toggleRecording,
                        icon: Icon(_isRecording ? PhosphorIconsRegular.stop : PhosphorIconsRegular.microphone),
                        label: Text(_isRecording ? '停止录音' : '开始录音'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRecording ? NinjaColors.error : null,
                        ),
                      ),
                    ),
                  ),
                  if (_isRecording) ...[
                    const SizedBox(height: NinjaSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: NinjaColors.error)),
                        const SizedBox(width: 8),
                        const Text('录音中...', style: TextStyle(color: NinjaColors.error, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: NinjaSpacing.lg),
          Card(
            color: NinjaColors.info.withValues(alpha: 0.05),
            child: const Padding(
              padding: EdgeInsets.all(NinjaSpacing.lg),
              child: Row(children: [
                Icon(PhosphorIconsRegular.info, color: NinjaColors.info),
                SizedBox(width: NinjaSpacing.md),
                Expanded(child: Text('语音识别和评测需要设备麦克风权限和 STT 服务支持。当前版本提供演示体验。',
                    style: TextStyle(fontSize: 13, color: NinjaColors.textSecondary))),
              ]),
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
