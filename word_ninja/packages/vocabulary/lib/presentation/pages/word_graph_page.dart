import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/design_tokens.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:ai/providers/ai_providers.dart';
import 'dart:math' as math;

part 'word_graph_widgets.dart';

typedef WordRelationLoader = Future<Map<String, List<Map<String, String>>>>
    Function(String word);

/// 单词关系图谱页 — 展示单词之间的关联
class WordGraphPage extends ConsumerStatefulWidget {
  final List<Word> words;
  final int initialIndex;
  final WordRelationLoader? relationLoader;
  const WordGraphPage({
    super.key,
    required this.words,
    this.initialIndex = 0,
    this.relationLoader,
  });

  @override
  ConsumerState<WordGraphPage> createState() => _WordGraphPageState();
}

class _WordGraphPageState extends ConsumerState<WordGraphPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _centerIndex = 0;
  Word? _centerWord;
  Word? _selectedWord;
  List<_GraphNode> _nodes = [];
  List<_GraphEdge> _edges = [];
  bool _isLoading = false;
  String? _loadError;
  int _requestId = 0;
  final Map<String, Map<String, List<Map<String, String>>>> _relationCache = {};

  @override
  void initState() {
    super.initState();
    _syncCenterIndex(widget.initialIndex);
    if (widget.words.isNotEmpty) _centerWord = widget.words[_centerIndex];
    Future.microtask(_loadGraph);
  }

  @override
  void didUpdateWidget(covariant WordGraphPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.words != widget.words ||
        oldWidget.initialIndex != widget.initialIndex) {
      final previousCenterId = oldWidget.words.isNotEmpty &&
              _centerIndex >= 0 &&
              _centerIndex < oldWidget.words.length
          ? oldWidget.words[_centerIndex].id
          : null;
      final retainedIndex = previousCenterId == null
          ? -1
          : widget.words.indexWhere((word) => word.id == previousCenterId);
      _syncCenterIndex(
        retainedIndex >= 0 ? retainedIndex : widget.initialIndex,
      );
      _centerWord = widget.words.isEmpty ? null : widget.words[_centerIndex];
      _selectedWord = null;
      _loadGraph();
    }
  }

  void _syncCenterIndex(int preferredIndex) {
    _centerIndex = widget.words.isEmpty
        ? 0
        : preferredIndex.clamp(0, widget.words.length - 1);
  }

  Future<void> _loadGraph({bool forceRefresh = false}) async {
    final center = _centerWord;
    if (center == null) return;
    final requestId = ++_requestId;
    final cacheKey = center.word.trim().toLowerCase();
    setState(() {
      _isLoading = true;
      _loadError = null;
      _nodes = [_nodeFromWord(center, isCenter: true)];
      _edges = [];
    });

    try {
      var relations = forceRefresh ? null : _relationCache[cacheKey];
      relations ??= await (widget.relationLoader != null
          ? widget.relationLoader!(center.word)
          : ref.read(aiWordServiceProvider).getWordRelations(center.word));
      _relationCache[cacheKey] = relations;
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _buildSemanticGraph(center, relations!);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isLoading = false;
        _loadError = error.toString();
      });
    }
  }

  void _buildSemanticGraph(
    Word center,
    Map<String, List<Map<String, String>>> relations,
  ) {
    _nodes = [_nodeFromWord(center, isCenter: true)];
    _edges = [];
    const relationLabels = {
      'synonyms': '近义词',
      'antonyms': '反义词',
      'related': '相关词',
      'derivatives': '派生词',
    };
    final seen = <String>{center.word.trim().toLowerCase()};
    for (final entry in relationLabels.entries) {
      for (final item in relations[entry.key] ?? const []) {
        final value = (item['word'] ?? '').trim();
        final normalized = value.toLowerCase();
        if (value.isEmpty ||
            normalized == 'nan' ||
            normalized == 'null' ||
            !seen.add(normalized)) {
          continue;
        }
        final nodeIndex = _nodes.length;
        _nodes.add(_GraphNode(
          word: value,
          meaning: (item['meaning'] ?? '').trim(),
          relationType: entry.key,
        ));
        _edges.add(_GraphEdge(
          from: 0,
          to: nodeIndex,
          label: entry.value,
          relationType: entry.key,
          strength: entry.key == 'synonyms' || entry.key == 'antonyms' ? 0.8 : 0.5,
        ));
      }
    }
  }

  _GraphNode _nodeFromWord(Word word, {bool isCenter = false}) {
    return _GraphNode(
      word: word.word,
      meaning: word.meaning,
      isCenter: isCenter,
    );
  }

  void _openNodeDetails(int index) {
    final node = _nodes[index];
    final savedIndex = widget.words.indexWhere(
      (word) => word.word.toLowerCase() == node.word.toLowerCase(),
    );
    setState(() => _selectedWord = savedIndex >= 0
        ? widget.words[savedIndex]
        : Word(id: '', userId: '', word: node.word, meaning: node.meaning));
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _focusWord(Word word) {
    setState(() {
      _centerIndex = widget.words.indexWhere((item) => item.id == word.id);
      _centerWord = word;
      _selectedWord = null;
    });
    _loadGraph();
  }

  Future<void> _showWordPicker() async {
    var query = '';
    final selectedWord = await showDialog<Word>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final normalized = query.trim().toLowerCase();
          final matches = normalized.isEmpty
              ? widget.words
              : widget.words
                  .where((word) =>
                      word.word.toLowerCase().contains(normalized) ||
                      word.meaning.toLowerCase().contains(normalized))
                  .toList();
          return AlertDialog(
            title: Text('选择中心词（${widget.words.length}）'),
            content: SizedBox(
              width: 420,
              height: 460,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: '搜索单词或释义',
                    ),
                    onChanged: (value) =>
                        setDialogState(() => query = value),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: matches.isEmpty
                        ? const Center(child: Text('没有匹配的单词'))
                        : ListView.builder(
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final word = matches[index];
                              final selected = word.id == _centerWord?.id;
                              return ListTile(
                                selected: selected,
                                leading: Icon(selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked),
                                title: Text(word.word),
                                subtitle: Text(
                                  word.meaning,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () =>
                                    Navigator.of(dialogContext).pop(word),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('关闭'),
              ),
            ],
          );
        },
      ),
    );
    if (selectedWord != null && mounted) {
      _focusWord(selectedWord);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (widget.words.isEmpty) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(title: const Text('知识图谱')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.hub_outlined, size: 48, color: colors.mutedText),
            const SizedBox(height: 16),
            Text('还没有可关联的单词', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('添加至少两个单词后，这里会展示它们的关系',
                style: TextStyle(fontSize: 12, color: colors.mutedText)),
          ]),
        ),
      );
    }
    final center = _centerWord ?? widget.words[_centerIndex];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.canvas,
      endDrawer: _WordInfoDrawer(
        word: _selectedWord ?? center,
        isCenter: (_selectedWord ?? center).word.toLowerCase() ==
            center.word.toLowerCase(),
        onFocus: () {
          final selected = _selectedWord ?? center;
          Navigator.of(context).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _focusWord(selected);
          });
        },
      ),
      appBar: AppBar(
        title: const Text('知识图谱'),
        actions: [
                if (widget.words.length > 1 && _centerIndex > 0)
                  IconButton(
                      icon: const Icon(Icons.arrow_left),
                      tooltip: '上一个',
                      onPressed: () {
                        setState(() {
                          _centerIndex--;
                          _centerWord = widget.words[_centerIndex];
                        });
                        _loadGraph();
                      }),
                if (_centerIndex >= 0 &&
                    _centerIndex < widget.words.length - 1)
                  IconButton(
                      icon: const Icon(Icons.arrow_right),
                      tooltip: '下一个',
                      onPressed: () {
                        setState(() {
                          _centerIndex++;
                          _centerWord = widget.words[_centerIndex];
                        });
                        _loadGraph();
                      }),
                IconButton(
                  tooltip: '重新生成',
                  onPressed: _isLoading ? null : () => _loadGraph(forceRefresh: true),
                  icon: const Icon(Icons.refresh),
                ),
              ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(11)),
                child: Icon(Icons.hub_outlined,
                    color: Theme.of(context).colorScheme.primary)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(center.word,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(center.meaning.isEmpty ? '点击其他节点切换中心词' : center.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: colors.mutedText))
                    ])),
            OutlinedButton.icon(
              onPressed: _showWordPicker,
              icon: const Icon(Icons.menu_book_outlined, size: 17),
              label: Text('单词本 ${widget.words.length}'),
            ),
            const SizedBox(width: 10),
            _GraphMetric(
                label: '关联节点', value: '${_nodes.length - 1}', colors: colors),
            const SizedBox(width: 10),
            _GraphMetric(
                label: '关系数量', value: '${_edges.length}', colors: colors),
          ]),
          const SizedBox(height: 16),
          Expanded(
              child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: colors.sidebar,
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(14)),
            child: Stack(children: [
              Positioned.fill(
                  child: _GraphCanvas(
                      nodes: _nodes,
                      edges: _edges,
                      onNodeTap: _openNodeDetails)),
              Positioned(left: 14, bottom: 12, child: _NodeLegend()),
              if (_isLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33FFFFFF),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              if (!_isLoading && _loadError != null)
                Positioned.fill(
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error),
                            const SizedBox(height: 8),
                            const Text('语义关系加载失败'),
                            const SizedBox(height: 4),
                            Text(
                              _loadError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11, color: colors.mutedText),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: _loadGraph,
                              child: const Text('重试'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (!_isLoading && _loadError == null && _nodes.length == 1)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '暂未找到可靠的语义关系',
                      style: TextStyle(color: colors.mutedText),
                    ),
                  ),
                ),
              Positioned(
                  right: 14,
                  bottom: 12,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                          color: colors.subtleSurface,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('点击节点可重新聚焦',
                          style: TextStyle(
                              fontSize: 11, color: colors.mutedText)))),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _GraphMetric extends StatelessWidget {
  const _GraphMetric(
      {required this.label, required this.value, required this.colors});
  final String label, value;
  final AppColorTokens colors;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: colors.sidebar,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(9)),
      child: Row(children: [
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: colors.mutedText))
      ]));
}

class _WordInfoDrawer extends StatelessWidget {
  const _WordInfoDrawer({
    required this.word,
    required this.isCenter,
    required this.onFocus,
  });

  final Word word;
  final bool isCenter;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final meaning = word.meaning.trim() == '解析失败' || word.meaning.isEmpty
        ? '暂无释义'
        : word.meaning;

    return Drawer(
      width: 360,
      backgroundColor: colors.sidebar,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 14, 16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.hub_outlined, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(word.word,
                            style: Theme.of(context).textTheme.titleLarge),
                        if (word.phonetic.isNotEmpty)
                          Text(
                            word.phonetic,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.mutedText,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _WordInfoSection(title: '释义', content: meaning),
                  if (word.example.trim().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _WordInfoSection(title: '例句', content: word.example),
                  ],
                  const SizedBox(height: 24),
                  Text('学习信息', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  _WordInfoRow(label: '来源', value: _sourceLabel(word.source)),
                  _WordInfoRow(label: '难度', value: '${word.difficulty} / 5'),
                  _WordInfoRow(label: '掌握度', value: '${word.mastery}%'),
                  _WordInfoRow(label: '复习次数', value: '${word.reviewCount}'),
                  if (word.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('标签', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: word.tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                visualDensity: VisualDensity.compact,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isCenter ? null : onFocus,
                  icon: const Icon(Icons.center_focus_strong, size: 18),
                  label: Text(isCenter ? '当前中心词' : '设为中心词'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _sourceLabel(String source) => switch (source) {
        'reading' => '阅读收集',
        'ai' || 'ai_tutor' => 'AI 生成',
        'manual' => '手动添加',
        _ => '其他',
      };
}

class _WordInfoSection extends StatelessWidget {
  const _WordInfoSection({required this.title, required this.content});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.65)),
        ],
      );
}

class _WordInfoRow extends StatelessWidget {
  const _WordInfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: context.appColors.mutedText),
              ),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
