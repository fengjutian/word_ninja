import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/storage/preferences.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 设置页面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  int _dailyWordGoal = 20;
  int _dailyReadingGoal = 1;
  int _aiDuration = 10;
  bool _darkMode = false;
  double _fontSize = 1.0;
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _dailyWordGoal = Preferences.getInt('daily_word_goal', defaultValue: 20);
      _dailyReadingGoal = Preferences.getInt('daily_reading_goal', defaultValue: 1);
      _aiDuration = Preferences.getInt('ai_duration', defaultValue: 10);
      _darkMode = Preferences.getBool('dark_mode');
      _fontSize = Preferences.getDouble('font_size', defaultValue: 1.0);
      _reminderEnabled = Preferences.getBool('reminder_enabled', defaultValue: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          const Text('学习设置', style: NinjaTextStyles.heading3),
          _SliderTile(
            '每日单词目标', '$_dailyWordGoal 词', PhosphorIconsRegular.bookOpen,
            value: _dailyWordGoal.toDouble(), min: 5, max: 100, divisions: 19,
            onChanged: (v) {
              setState(() => _dailyWordGoal = v.round());
              Preferences.setInt('daily_word_goal', v.round());
            },
          ),
          _SliderTile(
            '每日阅读目标', '$_dailyReadingGoal 篇', PhosphorIconsRegular.books,
            value: _dailyReadingGoal.toDouble(), min: 1, max: 10, divisions: 9,
            onChanged: (v) {
              setState(() => _dailyReadingGoal = v.round());
              Preferences.setInt('daily_reading_goal', v.round());
            },
          ),
          _SliderTile(
            'AI对话时长', '$_aiDuration 分钟', PhosphorIconsRegular.timer,
            value: _aiDuration.toDouble(), min: 5, max: 60, divisions: 11,
            onChanged: (v) {
              setState(() => _aiDuration = v.round());
              Preferences.setInt('ai_duration', v.round());
            },
          ),
          SwitchListTile(
            secondary: const Icon(PhosphorIconsRegular.bell, color: NinjaColors.textSecondary),
            title: const Text('复习提醒'),
            subtitle: Text(_reminderEnabled ? '每天 20:00' : '已关闭'),
            value: _reminderEnabled,
            onChanged: (v) {
              setState(() => _reminderEnabled = v);
              Preferences.setBool('reminder_enabled', v);
            },
          ),
          const SizedBox(height: NinjaSpacing.lg),
          const Text('显示设置', style: NinjaTextStyles.heading3),
          SwitchListTile(
            secondary: const Icon(PhosphorIconsRegular.moon, color: NinjaColors.textSecondary),
            title: const Text('深色模式'),
            subtitle: Text(_darkMode ? '已开启' : '跟随系统'),
            value: _darkMode,
            onChanged: (v) {
              setState(() => _darkMode = v);
              Preferences.setBool('dark_mode', v);
            },
          ),
          _DropdownTile(
            '字体大小', PhosphorIconsRegular.textAa,
            value: _fontSize,
            items: const {0.8: '小', 1.0: '标准', 1.2: '大', 1.4: '特大'},
            onChanged: (v) {
              setState(() => _fontSize = v);
              Preferences.setDouble('font_size', v);
            },
          ),
          const SizedBox(height: NinjaSpacing.lg),
          const Text('其他', style: NinjaTextStyles.heading3),
          ListTile(
            leading: const Icon(PhosphorIconsRegular.database, color: NinjaColors.textSecondary),
            title: const Text('清除缓存'),
            trailing: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存已清除')),
                );
              },
              child: const Text('清除'),
            ),
          ),
          ListTile(
            leading: const Icon(PhosphorIconsRegular.question, color: NinjaColors.textSecondary),
            title: const Text('帮助与反馈'),
            trailing: const Icon(PhosphorIconsRegular.caretRight, size: 18),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('帮助中心即将上线')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final double value;
  final double min, max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderTile(this.title, this.subtitle, this.icon,
      {required this.value, required this.min, required this.max, required this.divisions, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: NinjaColors.textSecondary),
      title: Text(title),
      subtitle: Slider(
        value: value, min: min, max: max, divisions: divisions,
        label: subtitle, onChanged: onChanged,
      ),
      trailing: Text(subtitle, style: NinjaTextStyles.bodySmall),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final double value;
  final Map<double, String> items;
  final ValueChanged<double> onChanged;

  const _DropdownTile(this.title, this.icon,
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: NinjaColors.textSecondary),
      title: Text(title),
      trailing: SegmentedButton<double>(
        segments: items.entries.map((e) => ButtonSegment<double>(value: e.key, label: Text(e.value))).toList(),
        selected: {value},
        onSelectionChanged: (v) => onChanged(v.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
