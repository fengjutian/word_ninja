import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:vocabulary/presentation/providers/word_provider.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:ai/providers/ai_providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'dart:convert';
import '../widgets/translate_popup.dart';

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
  _Article(title: 'The Art of Learning', level: 'N2', wordCount: 328, source: 'AI生成', topic: 'learning', category: _ReadingCategory.all,
      content: 'Learning is a lifelong journey. Every day presents new opportunities to grow and develop our skills...'),
  _Article(title: 'Technology Trends', level: 'N3', wordCount: 512, source: '新闻', topic: 'technology', category: _ReadingCategory.news,
      content: 'The world of technology is rapidly evolving. From artificial intelligence to quantum computing...'),
  _Article(title: 'A Journey Through Time', level: 'N2', wordCount: 420, source: 'AI生成', topic: 'time travel', category: _ReadingCategory.fiction,
      content: 'The old clock tower struck midnight as Sarah stepped through the ancient doorway...'),
  _Article(title: 'The Future of AI', level: 'N3', wordCount: 450, source: '科技', topic: 'artificial intelligence', category: _ReadingCategory.tech,
      content: 'Artificial intelligence has transformed the way we live and work...'),
  _Article(title: 'Chinese Tea Culture', level: 'N1', wordCount: 380, source: '文化', topic: 'tea culture', category: _ReadingCategory.culture,
      content: 'Tea has been an integral part of Chinese culture for thousands of years...'),
  _Article(title: 'How to Study Effectively', level: 'N4', wordCount: 280, source: '教育', topic: 'study methods', category: _ReadingCategory.education,
      content: 'Effective study habits are essential for academic success. Research shows that...'),
];

/// 阅读主页
class ReaderPage extends ConsumerStatefulWidget {
  const ReaderPage({super.key});

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  _ReadingCategory _selectedCategory = _ReadingCategory.all;
  List<_Article> _articles = _defaultArticles;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);
    try {
      // 尝试从 AI 服务获取推荐文章（离线时使用本地数据）
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_Article> get _filteredArticles {
    if (_selectedCategory == _ReadingCategory.all) return _articles;
    return _articles.where((a) => a.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final articles = _filteredArticles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('阅读训练'),
        actions: [
          IconButton(
            icon: const Icon(PhosphorIconsRegular.sparkle),
            tooltip: 'AI 生成文章',
            onPressed: () => _showAiGenerateDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                        isSelected ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.circle,
                        size: 16,
                        color: isSelected ? NinjaColors.primary : NinjaColors.textSecondary,
                      ),
                      label: Text(meta.$1),
                      onPressed: () => setState(() => _selectedCategory = cat),
                      backgroundColor: isSelected ? NinjaColors.primary.withValues(alpha: 0.08) : null,
                      side: isSelected ? const BorderSide(color: NinjaColors.primary) : null,
                    );
                  }).toList(),
                ),
                const SizedBox(height: NinjaSpacing.lg),
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
                    _ImportButton('PDF', PhosphorIconsRegular.filePdf, onTap: () => _importFile('pdf')),
                    const SizedBox(width: NinjaSpacing.md),
                    _ImportButton('EPUB', PhosphorIconsRegular.book, onTap: () => _importFile('epub')),
                    const SizedBox(width: NinjaSpacing.md),
                    _ImportButton('TXT', PhosphorIconsRegular.fileText, onTap: () => _importFile('txt')),
                  ],
                ),
              ],
            ),
    );
  }

  void _showAiGenerateDialog(BuildContext context) {
    final topicController = TextEditingController();
    int selectedLevel = 3;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('AI 生成文章'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: topicController,
                decoration: const InputDecoration(
                  labelText: '文章主题',
                  hintText: '例如: climate change, cooking, travel...',
                ),
              ),
              const SizedBox(height: NinjaSpacing.lg),
              Row(
                children: [
                  const Text('难度等级: '),
                  const SizedBox(width: NinjaSpacing.sm),
                  DropdownButton<int>(
                    value: selectedLevel,
                    items: List.generate(5, (i) => DropdownMenuItem(value: i + 1, child: Text('N${i + 1}'))),
                    onChanged: (v) { if (v != null) setDialogState(() => selectedLevel = v); },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
            FilledButton(
              onPressed: () {
                final topic = topicController.text.trim();
                if (topic.isEmpty) return;
                Navigator.pop(ctx);
                _generateArticle(topic, selectedLevel);
              },
              child: const Text('生成'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateArticle(String topic, int level) async {
    setState(() => _isLoading = true);
    try {
      final content = await ref.read(aiReadingServiceProvider).generateArticle(topic: topic, level: level);
      final article = _Article(
        title: topic,
        level: 'N$level',
        wordCount: content.split(' ').length,
        source: 'AI生成',
        topic: topic,
        category: _ReadingCategory.all,
        content: content,
      );
      setState(() {
        _articles = [article, ..._articles];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 文章已生成'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e')),
        );
      }
    }
  }

  void _openArticle(_Article article) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _ArticleReaderView(article: article, ref: ref),
    ));
  }

  Future<void> _importFile(String format) async {
    try {
      final extensions = format == 'pdf' ? ['pdf'] : format == 'epub' ? ['epub'] : ['txt'];
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes!;
      final rawName = file.name.replaceAll('.$format', '');

      String content;
      if (format == 'pdf') {
        content = _extractPdfText(bytes);
      } else if (format == 'epub') {
        content = _extractEpubText(bytes);
      } else {
        content = String.fromCharCodes(bytes);
      }

      if (content.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('无法从 ${format.toUpperCase()} 文件中提取文字')),
          );
        }
        return;
      }

      final article = _Article(
        title: rawName,
        level: 'N3',
        wordCount: content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length,
        source: '导入',
        topic: rawName,
        category: _ReadingCategory.all,
        content: content,
      );
      setState(() => _articles = [article, ..._articles]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已导入: $rawName (${format.toUpperCase()})'), duration: const Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入 ${format.toUpperCase()} 失败: $e')),
        );
      }
    }
  }

  String _extractPdfText(List<int> bytes) {
    final text = String.fromCharCodes(bytes);
    final buf = StringBuffer();
    final textRe = RegExp(r'\(([^)]*)\)\s*Tj');
    for (final m in textRe.allMatches(text)) {
      final t = m.group(1) ?? '';
      if (t.trim().isNotEmpty) buf.writeln(t);
    }
    final hexRe = RegExp(r'<([0-9A-Fa-f]+)>\s*Tj');
    for (final m in hexRe.allMatches(text)) {
      try {
        final hex = m.group(1)!;
        final chars = <int>[];
        for (int i = 0; i < hex.length; i += 4) {
          final codeUnit = int.parse(hex.substring(i, i + 4), radix: 16);
          if (codeUnit > 31 && codeUnit < 127) chars.add(codeUnit);
        }
        if (chars.isNotEmpty) buf.writeln(String.fromCharCodes(chars));
      } catch (e) { log.w('PDF hex decode failed', e); }
    }
    return buf.toString().trim();
  }

  String _extractEpubText(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final xhtmlFiles = archive.files.where((f) =>
        f.name.endsWith('.xhtml') || f.name.endsWith('.html') || f.name.endsWith('.htm'));
    final buf = StringBuffer();
    for (final file in xhtmlFiles) {
      final content = utf8.decode(file.content as List<int>);
      final stripped = content
          .replaceAll(RegExp(r'<[^>]+>'), '\n')
          .replaceAll(RegExp(r'&[a-z]+;'), ' ')
          .replaceAll(RegExp(r'\n{3,}'), '\n\n')
          .trim();
      if (stripped.isNotEmpty) buf.writeln(stripped);
    }
    return buf.toString().trim();
  }
}

/// 文章阅读器
class _ArticleReaderView extends StatefulWidget {
  final _Article article;
  final WidgetRef ref;
  const _ArticleReaderView({required this.article, required this.ref});

  @override
  State<_ArticleReaderView> createState() => _ArticleReaderViewState();
}


class _ArticleReaderViewState extends State<_ArticleReaderView> {
  OverlayEntry? _popupOverlay;
  String _selectedText = '';

  WidgetRef get ref => widget.ref;

  @override
  void dispose() {
    _removePopup();
    super.dispose();
  }

  void _removePopup() {
    _popupOverlay?.remove();
    _popupOverlay = null;
  }

  void _showTranslatePopup(BuildContext context, String text) {
    _removePopup();
    if (text.trim().isEmpty) return;

    _selectedText = text.trim();
    final overlay = Overlay.of(context);
    final word = _selectedText;

    _popupOverlay = OverlayEntry(
      builder: (overlayContext) {
        // Position near the top of the screen; in a real app you'd compute
        // position from the selection rect using editableTextState.renderObject
        return Positioned(
          left: 16,
          right: 16,
          top: MediaQuery.of(overlayContext).padding.top + kToolbarHeight + 8,
          child: Material(
            elevation: 0,
            color: Colors.transparent,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TranslatePopup(
                word: word,
                onAddToVocabulary: (meaning, example, phonetic) {
                  ref.read(wordListProvider.notifier).addWord(
                    Word(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      userId: 'local',
                      word: word,
                      meaning: meaning.isNotEmpty ? meaning : '待补充',
                      phonetic: phonetic,
                      example: example,
                      source: 'reading',
                      createdAt: DateTime.now(),
                    ),
                  );
                  _removePopup();
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _removePopup,
                  child: const Text('关闭'),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );

    overlay.insert(_popupOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.article.content ?? '文章内容加载中...';

    return Scaffold(
      appBar: AppBar(title: Text(widget.article.title)),
      body: ListView(
        padding: const EdgeInsets.all(NinjaSpacing.lg),
        children: [
          Row(
            children: [
              Chip(label: Text(widget.article.level, style: const TextStyle(fontSize: 11))),
              const SizedBox(width: NinjaSpacing.sm),
              Flexible(child: Text('${widget.article.wordCount} 词 · ${widget.article.source}', style: NinjaTextStyles.caption)),
            ],
          ),
          const SizedBox(height: NinjaSpacing.lg),
          SelectableText(
            content,
            style: NinjaTextStyles.bodyLarge,
            contextMenuBuilder: (menuContext, editableTextState) {
              // Get the selected text
              final selection = editableTextState.textEditingValue.selection;
              String selected;
              if (selection.isValid && !selection.isCollapsed) {
                selected = selection.textInside(editableTextState.textEditingValue.text);
              } else {
                selected = '';
              }

              // Show the translate popup overlay
              if (selected.trim().isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _showTranslatePopup(context, selected);
                });
              }

              // Return the default context menu
              return AdaptiveTextSelectionToolbar.buttonItems(
                buttonItems: [
                  if (selection.isValid && !selection.isCollapsed)
                    ...editableTextState.contextMenuButtonItems,
                  ContextMenuButtonItem(
                    label: '翻译',
                    onPressed: () {
                      if (selected.trim().isNotEmpty) {
                        _showTranslatePopup(context, selected);
                      }
                    },
                  ),
                ],
                anchors: editableTextState.contextMenuAnchors,
              );
            },
          ),
          const SizedBox(height: NinjaSpacing.xl),
          // 操作提示
          Container(
            padding: const EdgeInsets.all(NinjaSpacing.lg),
            decoration: BoxDecoration(
              color: NinjaColors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(NinjaSpacing.buttonRadius),
            ),
            child: const Row(
              children: [
                Icon(PhosphorIconsRegular.handTap, color: NinjaColors.info),
                SizedBox(width: NinjaSpacing.sm),
                Expanded(
                  child: Text('选中文字后可查看翻译、加入单词本、AI解析',
                      style: TextStyle(fontSize: 12, color: NinjaColors.info)),
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
              Flexible(child: Text(article.source, style: NinjaTextStyles.caption)),
            ],
          ),
        ),
        trailing: const Icon(PhosphorIconsRegular.caretRight),
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
