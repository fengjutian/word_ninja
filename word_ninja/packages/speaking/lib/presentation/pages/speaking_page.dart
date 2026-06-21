import 'package:flutter/material.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 口语训练页
class SpeakingPage extends StatelessWidget {
  const SpeakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('口语训练')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Text('AI陪练场景', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          _SceneCard('旅游', Icons.flight, '机场、酒店、问路'),
          _SceneCard('面试', Icons.work, '英文面试对话'),
          _SceneCard('商务会议', Icons.meeting_room, '商务谈判、演讲'),
          _SceneCard('日常聊天', Icons.chat, '朋友间的日常对话'),
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
                      _ScoreItem('准确度', 0),
                      _ScoreItem('流利度', 0),
                      _ScoreItem('语调', 0),
                      _ScoreItem('语速', 0),
                    ],
                  ),
                  const SizedBox(height: NinjaSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.mic),
                      label: const Text('开始录音'),
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

class _SceneCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String desc;

  const _SceneCard(this.title, this.icon, this.desc);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: ListTile(
        leading: Icon(icon, color: NinjaColors.primary, size: 28),
        title: Text(title, style: NinjaTextStyles.heading3),
        subtitle: Text(desc, style: NinjaTextStyles.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
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
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 3,
            backgroundColor: NinjaColors.divider.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(NinjaColors.success),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: NinjaTextStyles.caption),
      ],
    );
  }
}
