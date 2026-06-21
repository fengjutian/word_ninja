import 'package:flutter/material.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 听力训练页
class ListeningPage extends StatelessWidget {
  const ListeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('听力训练')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Text('AI听力课程', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          _LevelCard('N1', '高级', Icons.psychology, NinjaColors.levelMaster),
          _LevelCard('N2', '中高级', Icons.trending_up, NinjaColors.levelAdvanced),
          _LevelCard('N3', '中级', Icons.trending_flat, NinjaColors.levelIntermediate),
          _LevelCard('N4', '初级', Icons.trending_down, NinjaColors.levelBeginner),
          _LevelCard('N5', '入门', Icons.star, NinjaColors.info),
          const SizedBox(height: NinjaSpacing.xl),
          Text('练习模式', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          _ModeCard('精听', '逐句播放，理解每一句', Icons.hearing, NinjaColors.secondary),
          _ModeCard('听写', '听音频填写内容', Icons.edit_note, NinjaColors.accentPurple),
          _ModeCard('跟读', '录音后AI评分', Icons.record_voice_over, NinjaColors.success),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String level;
  final String desc;
  final IconData icon;
  final Color color;

  const _LevelCard(this.level, this.desc, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text('$level · $desc', style: NinjaTextStyles.heading3),
        trailing: const Icon(Icons.play_circle_fill, color: NinjaColors.primary),
        onTap: () {},
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ModeCard(this.title, this.subtitle, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: NinjaTextStyles.heading3),
        subtitle: Text(subtitle, style: NinjaTextStyles.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
