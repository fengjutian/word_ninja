import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 学习计划页
class StudyPlanPage extends ConsumerStatefulWidget {
  const StudyPlanPage({super.key});

  @override
  ConsumerState<StudyPlanPage> createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends ConsumerState<StudyPlanPage> {
  final _goalCtrl = TextEditingController();
  int _dailyMinutes = 30;

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学习计划')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('设定目标', style: NinjaTextStyles.heading2),
                  const SizedBox(height: NinjaSpacing.md),
                  TextField(
                    controller: _goalCtrl,
                    decoration: const InputDecoration(
                      hintText: '如：雅思6.5、看懂英文新闻...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: NinjaSpacing.md),
                  Text('每日学习时长：${_dailyMinutes}分钟',
                      style: NinjaTextStyles.bodyMedium),
                  Slider(
                    value: _dailyMinutes.toDouble(),
                    min: 10,
                    max: 120,
                    divisions: 11,
                    label: '$_dailyMinutes 分钟',
                    onChanged: (v) =>
                        setState(() => _dailyMinutes = v.round()),
                  ),
                  const SizedBox(height: NinjaSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('AI生成计划'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NinjaSpacing.lg),
          const Text('今日任务', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          _TaskTile('📖 学习 20 个新单词', 'vocabulary', true),
          _TaskTile('📄 阅读 1 篇文章', 'reading', false),
          _TaskTile('💬 AI 对话 10 分钟', 'ai_tutor', false),
          _TaskTile('🔄 复习 15 个单词', 'review', false),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String title;
  final String type;
  final bool isCompleted;

  const _TaskTile(this.title, this.type, this.isCompleted);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.sm),
      child: CheckboxListTile(
        title: Text(title,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              color: isCompleted ? NinjaColors.textSecondary : null,
            )),
        value: isCompleted,
        onChanged: (_) {},
        activeColor: NinjaColors.success,
      ),
    );
  }
}
