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
  // 模拟评分数据
  int _accuracy = 0;
  int _fluency = 0;
  int _intonation = 0;
  int _speed = 0;

  void _toggleRecording() {
    setState(() {
      if (_isRecording) {
        _isRecording = false;
        // 模拟评分结果
        _accuracy = 60 + (DateTime.now().millisecondsSinceEpoch % 40);
        _fluency = 55 + (DateTime.now().millisecondsSinceEpoch % 45);
        _intonation = 50 + (DateTime.now().millisecondsSinceEpoch % 50);
        _speed = 65 + (DateTime.now().millisecondsSinceEpoch % 35);
      } else {
        _isRecording = true;
        _accuracy = 0; _fluency = 0; _intonation = 0; _speed = 0;
      }
    });
  }

  void _openScene(String scene) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('$scene · AI陪练')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: NinjaColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: NinjaSpacing.lg),
              Text('$scene 场景', style: NinjaTextStyles.heading2),
              const SizedBox(height: NinjaSpacing.md),
              Text('AI 语音对话功能即将上线\n请在设置中配置 TTS/STT 服务', 
                  style: NinjaTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: NinjaSpacing.xl),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始对话'),
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
          Text('AI陪练场景', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          _SceneCard('旅游', Icons.flight, '机场、酒店、问路', () => _openScene('旅游')),
          _SceneCard('面试', Icons.work, '英文面试对话', () => _openScene('面试')),
          _SceneCard('商务会议', Icons.meeting_room, '商务谈判、演讲', () => _openScene('商务会议')),
          _SceneCard('日常聊天', Icons.chat, '朋友间的日常对话', () => _openScene('日常聊天')),
          const SizedBox(height: NinjaSpacing.xl),
          Text('发音练习', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ScoreItem('准确度', _accuracy),
                      _ScoreItem('流利度', _fluency),
                      _ScoreItem('语调', _intonation),
                      _ScoreItem('语速', _speed),
                    ],
                  ),
                  const SizedBox(height: NinjaSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleRecording,
                      icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                      label: Text(_isRecording ? '停止录音' : '开始录音'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isRecording ? NinjaColors.error : null,
                      ),
                    ),
                  ),
                  if (_isRecording) ...[
                    const SizedBox(height: NinjaSpacing.md),
                    Text('🔴 录音中...', style: NinjaTextStyles.bodyMedium.copyWith(color: NinjaColors.error)),
                  ],
                  if (!_isRecording && _accuracy > 0) ...[
                    const SizedBox(height: NinjaSpacing.md),
                    Text('综合评分：${((_accuracy + _fluency + _intonation + _speed) / 4).round()}',
                        style: NinjaTextStyles.heading2.copyWith(color: NinjaColors.success)),
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreItem(this.label, this.score);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 50, height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 3,
                backgroundColor: NinjaColors.divider.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  score >= 80 ? NinjaColors.success : score >= 50 ? NinjaColors.warning : NinjaColors.error,
                ),
              ),
              Text('$score', style: NinjaTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: NinjaTextStyles.caption),
      ],
    );
  }
}
