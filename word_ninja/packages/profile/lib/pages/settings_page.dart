import 'package:flutter/material.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          const Text('学习设置', style: NinjaTextStyles.heading3),
          _SettingTile('每日单词目标', '20 词', Icons.menu_book),
          _SettingTile('每日阅读目标', '1 篇', Icons.auto_stories),
          _SettingTile('AI对话时长', '10 分钟', Icons.timer),
          _SettingTile('复习提醒', '每天 20:00', Icons.notifications),
          const SizedBox(height: NinjaSpacing.lg),
          const Text('显示设置', style: NinjaTextStyles.heading3),
          _SettingTile('深色模式', '跟随系统', Icons.dark_mode),
          _SettingTile('字体大小', '标准', Icons.text_fields),
          const SizedBox(height: NinjaSpacing.lg),
          const Text('其他', style: NinjaTextStyles.heading3),
          _SettingTile('缓存管理', '127 MB', Icons.storage),
          _SettingTile('帮助与反馈', '', Icons.help),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SettingTile(this.title, this.subtitle, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.xs),
      child: ListTile(
        leading: Icon(icon, color: NinjaColors.textSecondary),
        title: Text(title),
        trailing: subtitle.isNotEmpty
            ? Text(subtitle, style: NinjaTextStyles.bodySmall)
            : const Icon(Icons.chevron_right, size: 18),
        onTap: () {},
      ),
    );
  }
}
