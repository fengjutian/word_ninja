import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/design_tokens.dart';
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
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _TrainingHeader(
                  icon: PhosphorIconsRegular.headphones,
                  title: '听力训练',
                  subtitle: '选择适合你的难度，通过真实语境提升听力理解'),
              const SizedBox(height: 30),
              Text('选择课程', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('按照 CEFR 难度循序渐进',
                  style: TextStyle(color: colors.mutedText, fontSize: 12)),
              const SizedBox(height: 14),
              LayoutBuilder(
                  builder: (context, box) => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _LevelCard(
                              'C1',
                              '高级',
                              '学术讲座、辩论',
                              PhosphorIconsRegular.brain,
                              () => _openLevel(context, 'C1')),
                          _LevelCard(
                              'B2',
                              '中高级',
                              '新闻、演讲',
                              PhosphorIconsRegular.trendUp,
                              () => _openLevel(context, 'B2')),
                          _LevelCard(
                              'B1',
                              '中级',
                              '日常对话、故事',
                              PhosphorIconsRegular.equals,
                              () => _openLevel(context, 'B1')),
                          _LevelCard(
                              'A2',
                              '初级',
                              '简短对话',
                              PhosphorIconsRegular.trendDown,
                              () => _openLevel(context, 'A2')),
                          _LevelCard(
                              'A1',
                              '入门',
                              '基础听力',
                              PhosphorIconsRegular.star,
                              () => _openLevel(context, 'A1')),
                        ]
                            .map((item) => SizedBox(
                                width: box.maxWidth >= 1000
                                    ? (box.maxWidth - 48) / 5
                                    : box.maxWidth > 680
                                        ? (box.maxWidth - 12) / 2
                                        : box.maxWidth,
                                child: item))
                            .toList(),
                      )),
              const SizedBox(height: 30),
              Text('专项练习', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              LayoutBuilder(
                  builder: (context, box) => Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _ModeCard('精听', '逐句播放，理解每一句', PhosphorIconsRegular.ear,
                            () => _openMode(context, '精听')),
                        _ModeCard(
                            '听写',
                            '听音频填写缺失内容',
                            PhosphorIconsRegular.notePencil,
                            () => _openMode(context, '听写')),
                        _ModeCard(
                            '跟读',
                            '边听边读，校准发音',
                            PhosphorIconsRegular.microphoneStage,
                            () => _openMode(context, '跟读')),
                      ]
                          .map((item) => SizedBox(
                              width: box.maxWidth > 760
                                  ? (box.maxWidth - 24) / 3
                                  : box.maxWidth,
                              child: item))
                          .toList())),
            ]),
          ),
        ),
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

class _TrainingHeader extends StatelessWidget {
  const _TrainingHeader(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.primary, size: 22)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 3),
          Text(subtitle,
              style:
                  TextStyle(fontSize: 13, color: context.appColors.mutedText))
        ])
      ]);
}

class _LevelCard extends StatelessWidget {
  final String level, title, desc;
  final IconData icon;
  final VoidCallback onTap;

  const _LevelCard(this.level, this.title, this.desc, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: primary, size: 20),
        ),
        title: Text('$level · $title',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle:
            Text(desc, style: TextStyle(fontSize: 12, color: colors.mutedText)),
        trailing: Icon(PhosphorIconsRegular.caretRight,
            color: colors.mutedText, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeCard(this.title, this.subtitle, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading:
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        title: Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 11, color: colors.mutedText)),
        onTap: onTap,
      ),
    );
  }
}
