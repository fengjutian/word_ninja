import 'package:flutter/material.dart';
import 'package:ui_kit/lib/ninja_theme/ninja_theme.dart';

/// 阅读主页
class ReaderPage extends StatelessWidget {
  const ReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('阅读训练'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Text('今日推荐', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          _ArticleCard(
            title: 'The Art of Learning',
            level: 'N2',
            wordCount: 328,
            source: 'AI生成',
          ),
          _ArticleCard(
            title: 'Technology Trends 2025',
            level: 'N3',
            wordCount: 512,
            source: '新闻',
          ),
          const SizedBox(height: NinjaSpacing.lg),
          Text('分类阅读', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          Wrap(
            spacing: NinjaSpacing.sm,
            runSpacing: NinjaSpacing.sm,
            children: [
              _CategoryChip('新闻', Icons.newspaper),
              _CategoryChip('小说', Icons.auto_stories),
              _CategoryChip('科技', Icons.computer),
              _CategoryChip('文化', Icons.public),
              _CategoryChip('教育', Icons.school),
            ],
          ),
          const SizedBox(height: NinjaSpacing.lg),
          Text('导入阅读', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          Row(
            children: [
              _ImportButton('PDF', Icons.picture_as_pdf),
              const SizedBox(width: NinjaSpacing.md),
              _ImportButton('EPUB', Icons.book),
              const SizedBox(width: NinjaSpacing.md),
              _ImportButton('TXT', Icons.description),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String title;
  final String level;
  final int wordCount;
  final String source;

  const _ArticleCard({
    required this.title,
    required this.level,
    required this.wordCount,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(NinjaSpacing.lg),
        title: Text(title, style: NinjaTextStyles.heading3),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: NinjaSpacing.sm),
          child: Row(
            children: [
              Chip(label: Text(level, style: const TextStyle(fontSize: 11))),
              const SizedBox(width: NinjaSpacing.sm),
              Text('$wordCount 词', style: NinjaTextStyles.bodySmall),
              const SizedBox(width: NinjaSpacing.sm),
              Text(source, style: NinjaTextStyles.caption),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CategoryChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () {},
    );
  }
}

class _ImportButton extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ImportButton(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
