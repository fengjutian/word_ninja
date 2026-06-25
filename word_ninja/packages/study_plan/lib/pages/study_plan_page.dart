import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai/providers/ai_providers.dart';
import 'package:auth/presentation/providers/auth_provider.dart';
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
  bool _isGenerating = false;
  String? _error;
  List<Map<String, dynamic>> _plan = [];
  Map<String, bool> _taskCompletion = {};

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  int get _currentLevel => ref.read(authProvider).user?.level ?? 1;

  Future<void> _generatePlan() async {
    final goal = _goalCtrl.text.trim();
    if (goal.isEmpty) return;
    setState(() { _isGenerating = true; _error = null; });
    try {
      final service = ref.read(aiPlanServiceProvider);
      final plan = await service.generatePlan(
        goal: goal,
        dailyMinutes: _dailyMinutes,
        currentLevel: _currentLevel,
      );
      final completion = <String, bool>{};
      for (final day in plan) {
        final tasks = day['tasks'] as List? ?? [];
        for (final task in tasks) {
          final key = '${day['day']}_${task['description']}';
          completion[key] = false;
        }
      }
      if (mounted) {
        setState(() {
          _plan = plan;
          _taskCompletion = completion;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = '生成失败: $e');
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
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
                  Row(children: [
                    const Text('设定目标', style: NinjaTextStyles.heading2),
                    const Spacer(),
                    Text('Lv.$_currentLevel', style: NinjaTextStyles.caption.copyWith(color: NinjaColors.primary)),
                  ]),
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
                    onChanged: (v) => setState(() => _dailyMinutes = v.round()),
                  ),
                  const SizedBox(height: NinjaSpacing.md),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(NinjaSpacing.md),
                      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
                      decoration: BoxDecoration(
                        color: NinjaColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
                      ),
                      child: Text(_error!, style: const TextStyle(color: NinjaColors.error)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generatePlan,
                      icon: _isGenerating
                          ? const SizedBox.square(
                              dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(PhosphorIconsRegular.sparkle),
                      label: Text(_isGenerating ? 'AI 生成中...' : 'AI生成计划'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_plan.isNotEmpty) ...[
            const SizedBox(height: NinjaSpacing.lg),
            ..._plan.map((day) => _DayCard(
                  day: day,
                  taskCompletion: _taskCompletion,
                  onToggle: (key) => setState(() => _taskCompletion[key] = !(_taskCompletion[key] ?? false)),
                )),
          ] else ...[
            const SizedBox(height: NinjaSpacing.lg),
            const Text('今日推荐任务', style: NinjaTextStyles.heading2),
            const SizedBox(height: NinjaSpacing.md),
            _TaskTile('📖 学习 20 个新单词', 'vocabulary', true, (_) {}),
            _TaskTile('📄 阅读 1 篇文章', 'reading', false, (_) {}),
            _TaskTile('💬 AI 对话 10 分钟', 'ai_tutor', false, (_) {}),
            _TaskTile('🔄 复习 15 个单词', 'review', false, (_) {}),
          ],
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final Map<String, dynamic> day;
  final Map<String, bool> taskCompletion;
  final void Function(String key) onToggle;

  const _DayCard({required this.day, required this.taskCompletion, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final tasks = (day['tasks'] as List?) ?? [];
    final completed = tasks.where((t) {
      final key = '${day['day']}_${t['description']}';
      return taskCompletion[key] == true;
    }).length;

    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: NinjaSpacing.lg, vertical: NinjaSpacing.md),
            decoration: BoxDecoration(
              color: NinjaColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(NinjaSpacing.cardRadius)),
            ),
            child: Row(
              children: [
                Text('Day ${day['day']}', style: NinjaTextStyles.heading3.copyWith(color: NinjaColors.primary)),
                const Spacer(),
                Text('$completed/$tasks.length', style: NinjaTextStyles.caption),
              ],
            ),
          ),
          ...tasks.map((task) {
            final desc = (task['description'] ?? '').toString();
            final mins = task['duration_min'] ?? 0;
            final key = '${day['day']}_$desc';
            final isChecked = taskCompletion[key] ?? false;
            return CheckboxListTile(
              title: Text('$desc（${mins}分钟）', style: NinjaTextStyles.bodyMedium.copyWith(
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked ? NinjaColors.textSecondary : null,
              )),
              value: isChecked,
              onChanged: (_) => onToggle(key),
              activeColor: NinjaColors.success,
            );
          }),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final String title;
  final String type;
  final bool isCompleted;
  final void Function(bool?) onChanged;

  const _TaskTile(this.title, this.type, this.isCompleted, this.onChanged);

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
        onChanged: onChanged,
        activeColor: NinjaColors.success,
      ),
    );
  }
}
