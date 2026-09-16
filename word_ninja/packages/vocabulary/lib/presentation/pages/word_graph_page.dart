import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/design_tokens.dart';
import 'package:vocabulary/data/model/word.dart';
import 'dart:math' as math;

part 'word_graph_widgets.dart';

/// 单词关系图谱页 — 展示单词之间的关联
class WordGraphPage extends ConsumerStatefulWidget {
  final List<Word> words;
  final int initialIndex;
  const WordGraphPage({super.key, required this.words, this.initialIndex = 0});

  @override
  ConsumerState<WordGraphPage> createState() => _WordGraphPageState();
}

class _WordGraphPageState extends ConsumerState<WordGraphPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _centerIndex = 0;
  Word? _selectedWord;
  List<_GraphNode> _nodes = [];
  List<_GraphEdge> _edges = [];

  @override
  void initState() {
    super.initState();
    _syncCenterIndex(widget.initialIndex);
    _buildGraph();
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
      _selectedWord = null;
      _buildGraph();
    }
  }

  void _syncCenterIndex(int preferredIndex) {
    _centerIndex = widget.words.isEmpty
        ? 0
        : preferredIndex.clamp(0, widget.words.length - 1);
  }

  void _buildGraph() {
    _nodes = [];
    _edges = [];
    if (widget.words.isEmpty) return;
    _syncCenterIndex(_centerIndex);
    final all = widget.words;
    final center = all[_centerIndex];

    // Central node
    _nodes.add(_GraphNode(
        word: center.word,
        meaning: center.meaning,
        difficulty: center.difficulty,
        source: center.source,
        tags: center.tags,
        isCenter: true));

    // Related nodes: words sharing tags or similar difficulty
    final related = <Word>[];
    final seen = {center.word};
    for (final w in all) {
      if (w.word == center.word) continue;
      final tagOverlap = center.tags.toSet().intersection(w.tags.toSet());
      final difficultyClose = (center.difficulty - w.difficulty).abs() <= 1;
      final sourceMatch = center.source == w.source;

      if (tagOverlap.isNotEmpty || difficultyClose || sourceMatch) {
        if (seen.add(w.word)) {
          related.add(w);
          // Build edge
          String relation;
          if (tagOverlap.isNotEmpty) {
            relation = tagOverlap.first;
          } else if (sourceMatch) {
            relation = '同来源';
          } else {
            relation = '难度相近';
          }
          _edges.add(_GraphEdge(
            from: 0,
            to: _nodes.length,
            label: relation,
            strength: tagOverlap.length * 0.3 + (sourceMatch ? 0.2 : 0),
          ));
          _nodes.add(_GraphNode(
              word: w.word,
              meaning: w.meaning,
              difficulty: w.difficulty,
              source: w.source,
              tags: w.tags));
        }
      }
    }

    // Keep every word visible. Words without a detected relationship still
    // belong to the vocabulary graph and can be selected as a new center.
    for (final w in all.where((word) => !seen.contains(word.word))) {
      if (seen.add(w.word)) {
        _edges.add(_GraphEdge(from: 0, to: _nodes.length, label: '词库'));
        _nodes.add(_GraphNode(
            word: w.word,
            meaning: w.meaning,
            difficulty: w.difficulty,
            source: w.source,
            tags: w.tags));
      }
    }
  }

  void _openNodeDetails(int index) {
    final wordIndex =
        widget.words.indexWhere((word) => word.word == _nodes[index].word);
    if (wordIndex < 0) return;
    setState(() => _selectedWord = widget.words[wordIndex]);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _focusWord(Word word) {
    setState(() {
      _centerIndex = widget.words.indexWhere((item) => item.id == word.id);
      if (_centerIndex < 0) _centerIndex = 0;
      _buildGraph();
    });
    Navigator.of(context).pop();
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
    final center = widget.words[_centerIndex];
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.canvas,
      endDrawer: _WordInfoDrawer(
        word: _selectedWord ?? center,
        isCenter: (_selectedWord ?? center).id == center.id,
        onFocus: () => _focusWord(_selectedWord ?? center),
      ),
      appBar: AppBar(
        title: const Text('知识图谱'),
        actions: widget.words.length > 1
            ? [
                if (_centerIndex > 0)
                  IconButton(
                      icon: const Icon(Icons.arrow_left),
                      tooltip: '上一个',
                      onPressed: () {
                        setState(() {
                          _centerIndex--;
                          _buildGraph();
                        });
                      }),
                if (_centerIndex < widget.words.length - 1)
                  IconButton(
                      icon: const Icon(Icons.arrow_right),
                      tooltip: '下一个',
                      onPressed: () {
                        setState(() {
                          _centerIndex++;
                          _buildGraph();
                        });
                      }),
              ]
            : null,
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
