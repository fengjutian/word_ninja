import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ai/providers/ai_providers.dart' show aiReadingServiceProvider;
import 'package:listening/providers/tts_provider.dart';

/// 听力训练页面 - 课程选择 + 三种练习模式
class ListeningPage extends ConsumerStatefulWidget {
  const ListeningPage({super.key});

  @override
  ConsumerState<ListeningPage> createState() => _ListeningPageState();
}

class _ListeningPageState extends ConsumerState<ListeningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('听力训练')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Semantics(
              header: true,
              child: Text('AI听力课程', style: AppTextStyles.heading2)),
          const SizedBox(height: AppSpacing.md),
          _LevelCard('C1', '高级 · 学术讲座、辩论', PhosphorIconsRegular.brain,
              AppColors.levelMaster, () => _openLevel(context, 'C1')),
          _LevelCard('B2', '中高级 · 新闻、演讲', PhosphorIconsRegular.trendUp,
              AppColors.levelAdvanced, () => _openLevel(context, 'B2')),
          _LevelCard('B1', '中级 · 日常对话、故事', PhosphorIconsRegular.equals,
              AppColors.levelIntermediate, () => _openLevel(context, 'B1')),
          _LevelCard('A2', '初级 · 简单对话', PhosphorIconsRegular.trendDown,
              AppColors.levelBeginner, () => _openLevel(context, 'A2')),
          _LevelCard('A1', '入门 · 基础听力', PhosphorIconsRegular.star,
              AppColors.info, () => _openLevel(context, 'A1')),
          const SizedBox(height: AppSpacing.xl),
          Semantics(
              header: true, child: Text('练习模式', style: AppTextStyles.heading2)),
          const SizedBox(height: AppSpacing.md),
          _ModeCard('精听', '逐句播放，理解每一句', PhosphorIconsRegular.ear,
              AppColors.secondary, () => _openMode(context, '精听')),
          _ModeCard('听写', '听音频填写缺失内容', PhosphorIconsRegular.notePencil,
              AppColors.accentPurple, () => _openMode(context, '听写')),
          _ModeCard('跟读', '边听边读，录音后AI评分', PhosphorIconsRegular.microphoneStage,
              AppColors.success, () => _openMode(context, '跟读')),
        ],
      ),
    );
  }

  void _openLevel(BuildContext ctx, String level) {
    final tts = ref.read(ttsServiceProvider);
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('$level · 听力课程')),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(PhosphorIconsRegular.headphones,
                    size: 48, color: AppColors.primary.withValues(alpha: 0.4)),
                const SizedBox(height: AppSpacing.lg),
                Text('$level 级别课程',
                    style: AppTextStyles.heading2, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                _buildSampleSentence(level),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: () {
                    final sentence = _getSampleText(level);
                    tts.speak(sentence, rate: 0.8);
                  },
                  icon: const Icon(PhosphorIconsRegular.play),
                  label: const Text('播放音频'),
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => tts.stop(),
                  icon: const Icon(PhosphorIconsRegular.stop),
                  label: const Text('停止'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildSampleSentence(String level) {
    final text = _getSampleText(level);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('示例文本：', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          Text(text, style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          Text('点击下方播放按钮收听系统 TTS 发音', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  String _getSampleText(String level) {
    switch (level) {
      case 'C1':
        return 'The professor delivered an insightful lecture on renewable energy sources, emphasizing the importance of sustainable development.';
      case 'B2':
        return 'According to the latest news report, the government plans to invest heavily in public transportation infrastructure.';
      case 'B1':
        return 'Yesterday I went to the bookstore and bought a new novel. The story seems really interesting so far.';
      case 'A2':
        return 'Hello, my name is John. I enjoy playing basketball and listening to music in my free time.';
      case 'A1':
        return 'Hello! How are you? My name is Anna. I like music and movies.';
      default:
        return 'Welcome to WordFlow listening practice.';
    }
  }

  void _openMode(BuildContext ctx, String mode) {
    final tts = ref.read(ttsServiceProvider);
    Navigator.of(ctx).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('$mode · 听力练习')),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(PhosphorIconsRegular.musicNote,
                    size: 48, color: AppColors.primary.withValues(alpha: 0.4)),
                const SizedBox(height: AppSpacing.lg),
                Text('$mode 模式', style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.md),
                Text(
                  mode == '精听'
                      ? '逐句播放，反复练习，提升听力理解能力。'
                      : mode == '听写'
                          ? '听取音频，填写缺失的单词或句子。'
                          : '聆听标准发音，跟读录音，AI 评估发音准确度。',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: () {
                    final sample =
                        'Practice makes perfect. Keep listening and you will improve your English skills.';
                    tts.speak(sample, rate: 0.8);
                  },
                  icon: const Icon(PhosphorIconsRegular.play),
                  label: const Text('播放示例'),
                ),
              ],
            ),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
        title: Text('$level · $desc', style: AppTextStyles.heading3),
        trailing:
            const Icon(PhosphorIconsFill.playCircle, color: AppColors.primary),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: AppTextStyles.heading3),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
        onTap: onTap,
      ),
    );
  }
}
