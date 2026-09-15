part of 'reader_page.dart';

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
  final String? content;

  const _Article({
    required this.title,
    required this.level,
    required this.wordCount,
    required this.source,
    required this.topic,
    required this.category,
    this.content,
  });
}

/// 内置文章数据（作为离线后备）
const _defaultArticles = [
  _Article(
      title: 'The Art of Learning',
      level: 'B2',
      wordCount: 328,
      source: 'AI生成',
      topic: 'learning',
      category: _ReadingCategory.all,
      content:
          'Learning is a lifelong journey. Every day presents new opportunities to grow and develop our skills...'),
  _Article(
      title: 'Technology Trends',
      level: 'B1',
      wordCount: 512,
      source: '新闻',
      topic: 'technology',
      category: _ReadingCategory.news,
      content:
          'The world of technology is rapidly evolving. From artificial intelligence to quantum computing...'),
  _Article(
      title: 'A Journey Through Time',
      level: 'B2',
      wordCount: 420,
      source: 'AI生成',
      topic: 'time travel',
      category: _ReadingCategory.fiction,
      content:
          'The old clock tower struck midnight as Sarah stepped through the ancient doorway...'),
  _Article(
      title: 'The Future of AI',
      level: 'B1',
      wordCount: 450,
      source: '科技',
      topic: 'artificial intelligence',
      category: _ReadingCategory.tech,
      content:
          'Artificial intelligence has transformed the way we live and work...'),
  _Article(
      title: 'Chinese Tea Culture',
      level: 'C1',
      wordCount: 380,
      source: '文化',
      topic: 'tea culture',
      category: _ReadingCategory.culture,
      content:
          'Tea has been an integral part of Chinese culture for thousands of years...'),
  _Article(
      title: 'How to Study Effectively',
      level: 'A2',
      wordCount: 280,
      source: '教育',
      topic: 'study methods',
      category: _ReadingCategory.education,
      content:
          'Effective study habits are essential for academic success. Research shows that...'),
];
