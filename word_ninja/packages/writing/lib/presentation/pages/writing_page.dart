import 'package:flutter/material.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 写作训练页
class WritingPage extends StatelessWidget {
  const WritingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('写作训练')),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Text('AI作文生成', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.lg),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: '输入作文主题...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: NinjaSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('生成范文'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NinjaSpacing.xl),
          Text('AI批改', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(NinjaSpacing.lg),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: '粘贴你的作文...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: NinjaSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.rate_review),
                      label: const Text('AI批改'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: NinjaSpacing.xl),
          ListTile(
            leading: const Icon(Icons.school, color: NinjaColors.accentGold),
            title: const Text('IELTS模拟评分'),
            subtitle: const Text('基于雅思评分标准'),
            trailing: const Chip(label: Text('6.5')),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
