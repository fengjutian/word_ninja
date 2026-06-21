import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';

/// 分类
enum _ReadingCategory { all, news, fiction, tech, culture, education }

const _categoryMeta = {
  _ReadingCategory.all: ('全部', ''),
  _ReadingCategory.news: ('新闻', 'technology'),
  _ReadingCategory.fiction: ('小说', 'fiction'),
  _ReadingCategory.tech: ('科技', 'science'),
  _ReadingCategory.culture: ('文化', 'culture'),
  _ReadingCategory.education: ('教育', 'education'),
};

/// 文章模型
class _Article {
  final String title;
  final String level;
  final int wordCount;
  final String source;
  final String topic;
  final _ReadingCategory category;

  const _Article({
    required this.title,
    required this.level,
    required this.wordCount,
    required this.source,
    required this.topic,
    required this.category,
  });
}

/// 内置文章数据
const _articles = [
  _Article(title: 'The Art of Learning', level: 'N2', wordCount: 328, source: 'AI生成', topic: 'learning', category: _ReadingCategory.all),
  _Article(title: 'Technology Trends 2025', level: 'N3', wordCount: 512, source: '新闻', topic: 'technology', category: _ReadingCategory.news),
  _Article(title: 'A Journey Through Time', level: 'N2', wordCount: 420, source: 'AI生成', topic: 'time travel', category: _ReadingCategory.fiction),
  _Article(title: 'The Future of AI', level: 'N3', wordCount: 450, source: '科技', topic: 'artificial intelligence', category: _ReadingCategory.tech),
  _Article(title: 'Chinese Tea Culture', level: 'N1', wordCount: 380, source: '文化', topic: 'tea culture', category: _ReadingCategory.culture),
  _Article(title: 'How to Study Effectively', level: 'N4', wordCount: 280, source: '教育', topic: 'study methods', category: _ReadingCategory.education),
  _Article(title: 'Digital Nomad Life', level: 'N3', wordCount: 460, source: '新闻', topic: 'digital nomad', category: _ReadingCategory.news),
  _Article(title: 'Short Story: The Rain', level: 'N5', wordCount: 200, source: 'AI生成', topic: 'story', category: _ReadingCategory.fiction),
];

/// 阅读主页
class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({super.key});

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  _ReadingCategory _selectedCategory = _ReadingCategory.all;

  List<_Article> get _filteredArticles {
    if (_selectedCategory == _ReadingCategory.all) return _articles.toList();
    return _articles.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final articles = _filteredArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('阅读训练'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {
            // TODO: 打开AI生成文章对话框
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('AI文章生成即将上线')),
            );
          }),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Text('今日推荐', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          if (articles.isNotEmpty)
            _ArticleCard(article: articles.first, onTap: () => _openArticle(articles.first))
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(NinjaSpacing.xl),
                child: Center(child: Text('暂无文章', style: NinjaTextStyles.bodyLarge)),
              ),
            ),
          const SizedBox(height: NinjaSpacing.lg),
          Text('分类阅读', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          Wrap(
            spacing: NinjaSpacing.sm,
            runSpacing: NinjaSpacing.sm,
            children: _ReadingCategory.values.map((cat) {
              final meta = _categoryMeta[cat]!;
              final isSelected = cat == _selectedCategory;
              return ActionChip(
                avatar: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: isSelected ? NinjaColors.primary : NinjaColors.textSecondary,
                ),
                label: Text(meta.$1),
                onPressed: () => setState(() => _selectedCategory = cat),
                backgroundColor: isSelected
                    ? NinjaColors.primary.withValues(alpha: 0.08)
                    : null,
                side: isSelected ? const BorderSide(color: NinjaColors.primary) : null,
              );
            }).toList(),
          ),
          const SizedBox(height: NinjaSpacing.lg),
          // 更多文章
          if (articles.length > 1) ...[
            Text('更多文章', style: NinjaTextStyles.heading2),
            const SizedBox(height: NinjaSpacing.md),
            ...articles.skip(1).map((a) => _ArticleCard(article: a, onTap: () => _openArticle(a))),
          ],
          const SizedBox(height: NinjaSpacing.lg),
          Text('导入阅读', style: NinjaTextStyles.heading2),
          const SizedBox(height: NinjaSpacing.md),
          Row(
            children: [
              _ImportButton('PDF', Icons.picture_as_pdf, onTap: () => _showImportSnack(context, 'PDF')),
              const SizedBox(width: NinjaSpacing.md),
              _ImportButton('EPUB', Icons.book, onTap: () => _showImportSnack(context, 'EPUB')),
              const SizedBox(width: NinjaSpacing.md),
              _ImportButton('TXT', Icons.description, onTap: () => _showImportSnack(context, 'TXT')),
            ],
          ),
        ],
      ),
    );
  }

  void _openArticle(_Article article) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ArticleReaderView(article: article),
    ));
  }

  void _showImportSnack(BuildContext ctx, String format) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('$format 导入功能即将上线')),
    );
  }
}

/// 简化的文章阅读器
class _ArticleReaderView extends StatelessWidget {
  final _Article article;
  const _ArticleReaderView({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Row(
            children: [
              Chip(label: Text(article.level, style: const TextStyle(fontSize: 11))),
              const SizedBox(width: NinjaSpacing.sm),
              Text('${article.wordCount} 词 · ${article.source}', style: NinjaTextStyles.caption),
            ],
          ),
          const SizedBox(height: NinjaSpacing.lg),
          Text('关于「${article.topic}」的文章内容...\n\nAI 正在为您生成完整文章，请稍后重试。',
              style: NinjaTextStyles.bodyLarge),
          const SizedBox(height: NinjaSpacing.xl),
          // 选中文字后的操作提示
          Container(
            padding: const EdgeInsets.all(NinjaSpacing.lg),
            decoration: BoxDecoration(
              color: NinjaColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app, color: NinjaColors.info),
                const SizedBox(width: NinjaSpacing.sm),
                Expanded(
                  child: Text('选中文字后可查看翻译、加入单词本、AI解析',
                      style: NinjaTextStyles.bodySmall.copyWith(color: NinjaColors.info)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final _Article article;
  final VoidCallback onTap;

  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: NinjaSpacing.md),
      child: ListTile(
        contentPadding: const EdgeInsets.all(NinjaSpacing.lg),
        title: Text(article.title, style: NinjaTextStyles.heading3),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: NinjaSpacing.sm),
          child: Row(
            children: [
              Chip(
                label: Text(article.level, style: const TextStyle(fontSize: 11)),
                backgroundColor: NinjaColors.primary.withValues(alpha: 0.08),
              ),
              const SizedBox(width: NinjaSpacing.sm),
              Text('${article.wordCount} 词', style: NinjaTextStyles.bodySmall),
              const SizedBox(width: NinjaSpacing.sm),
              Text(article.source, style: NinjaTextStyles.caption),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ImportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ImportButton(this.label, this.icon, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
