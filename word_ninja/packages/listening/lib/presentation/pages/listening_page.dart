import 'package:flutter/material.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:ai/providers/ai_providers.dart' show aiReadingServiceProvider;

/// 听力训练页面 - 课程选择 + 三种练习模式
class ListeningPage extends StatefulWidget {
  const ListeningPage({super.key});

  @override
  State<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends State<ListeningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('听力训练')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Semantics(header: true, child: Text('AI听力课程', style: NinjaTextStyles.heading2)),
          const SizedBox(height: NinjaSpacing.md),
          _LevelCard('N1', '高级 · 学术讲座、辩论', Icons.psychology, NinjaColors.levelMaster, () => _openLevel(context, 'N1')),
          _LevelCard('N2', '中高级 · 新闻、演讲', Icons.trending_up, NinjaColors.levelAdvanced, () => _openLevel(context, 'N2')),
          _LevelCard('N3', '中级 · 日常对话、故事', Icons.trending_flat, NinjaColors.levelIntermediate, () => _openLevel(context, 'N3')),
          _LevelCard('N4', '初级 · 简单对话', Icons.trending_down, NinjaColors.levelBeginner, () => _openLevel(context, 'N4')),
          _LevelCard('N5', '入门 · 基础听力', Icons.star, NinjaColors.info, () => _openLevel(context, 'N5')),
          const SizedBox(height: NinjaSpacing.xl),
          Semantics(header: true, child: Text('练习模式', style: NinjaTextStyles.heading2)),
          const SizedBox(height: NinjaSpacing.md),
          _ModeCard('精听', '逐句播放，理解每一句', Icons.hearing, NinjaColors.secondary,
              () => _openMode(context, '精听')),
          _ModeCard('听写', '听音频填写缺失内容', Icons.edit_note, NinjaColors.accentPurple,
              () => _openMode(context, '听写')),
          _ModeCard('跟读', '边听边读，录音后AI评分', Icons.record_voice_over, NinjaColors.success,
              () => _openMode(context, '跟读')),
          const SizedBox(height: NinjaSpacing.xl),
          // 提示
          Card(
            color: NinjaColors.info.withValues(alpha: 0.05),
            child: const Padding(
              padding: EdgeInsets.all(NinjaSpacing.lg),
              child: Row(children: [
                Icon(Icons.info_outline, color: NinjaColors.info),
                SizedBox(width: NinjaSpacing.md),
                Expanded(child: Text('音频播放功能需要 TTS 服务支持，当前使用 AI 生成课程文本。',
                    style: TextStyle(fontSize: 13, color: NinjaColors.textSecondary))),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _openLevel(BuildContext ctx, String level) {
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('$level · 听力课程')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.headphones, size: 64, color: NinjaColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: NinjaSpacing.lg),
              Text('$level 级别课程', style: NinjaTextStyles.heading2),
              const SizedBox(height: NinjaSpacing.md),
              const Text('AI 正在为您准备课程内容...', style: NinjaTextStyles.bodyMedium),
              const SizedBox(height: NinjaSpacing.lg),
              Semantics(
                label: 'AI听力课程内容展示区',
                child: Container(
                  padding: const EdgeInsets.all(NinjaSpacing.lg),
                  margin: const EdgeInsets.symmetric(horizontal: NinjaSpacing.xl),
                  decoration: BoxDecoration(
                    color: NinjaColors.background,
                    borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
                    border: Border.all(color: NinjaColors.divider),
                  ),
                  child: const Text(
                    '课程内容将包含：\n\n'
                    '• 对话理解练习\n'
                    '• 关键信息提取\n'
                    '• 细节理解题\n'
                    '• 主旨大意题\n\n'
                    '音频功能需要设备 TTS 引擎支持。',
                    style: NinjaTextStyles.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: NinjaSpacing.xl),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(_).showSnackBar(
                    const SnackBar(content: Text('音频功能需要配置 TTS 服务，请先前往「设置」中配置。'), duration: Duration(seconds: 2)),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始学习'),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  void _openMode(BuildContext ctx, String mode) {
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('$mode · 听力练习')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note, size: 64, color: NinjaColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: NinjaSpacing.lg),
              Text('$mode 模式', style: NinjaTextStyles.heading2),
              const SizedBox(height: NinjaSpacing.md),
              Text(
                mode == '精听' ? '逐句播放，反复练习，提升听力理解能力。'
                    : mode == '听写' ? '听取音频，填写缺失的单词或句子。'
                    : '聆听标准发音，跟读录音，AI 评估发音准确度。',
                style: NinjaTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: NinjaSpacing.xl),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(_).showSnackBar(
                    const SnackBar(content: Text('音频功能需要配置 TTS 服务，请先前往「设置」中配置。'), duration: Duration(seconds: 2)),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始练习'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class _LevelCard extends StatelessWidget {
  final String level, desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LevelCard(this.level, this.desc, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: ListTile(
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text('$level · $desc', style: NinjaTextStyles.heading3),
        trailing: const Icon(Icons.play_circle_fill, color: NinjaColors.primary),
        onTap: onTap,
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard(this.title, this.subtitle, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: NinjaTextStyles.heading3),
        subtitle: Text(subtitle, style: NinjaTextStyles.bodySmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
