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

