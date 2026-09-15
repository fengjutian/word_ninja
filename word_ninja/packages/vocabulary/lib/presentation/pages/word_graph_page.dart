import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
import 'package:ui_kit/app_theme/design_tokens.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/presentation/providers/word_provider.dart';
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
  int _centerIndex = 0;
  List<_GraphNode> _nodes = [];
  List<_GraphEdge> _edges = [];

  @override
  void initState() {
    super.initState();
    if (widget.words.isNotEmpty) {
      _centerIndex = widget.initialIndex.clamp(0, widget.words.length - 1);
    }
    _buildGraph();
  }

  void _buildGraph() {
    if (widget.words.isEmpty) return;
    final all = widget.words;
    final center = all[_centerIndex];

    _nodes = [];
    _edges = [];

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

    // If not enough, add random words
    if (related.length < 4) {
      final remaining = all.where((w) => !seen.contains(w.word)).toList()
        ..shuffle();
      for (final w in remaining.take(6 - related.length)) {
        if (seen.add(w.word)) {
          _edges.add(_GraphEdge(from: 0, to: _nodes.length, label: '随机'));
          _nodes.add(_GraphNode(
              word: w.word,
              meaning: w.meaning,
              difficulty: w.difficulty,
              source: w.source,
              tags: w.tags));
        }
      }
    }
  }

  void _selectNode(int index) {
    setState(() {
      _centerIndex =
          widget.words.indexWhere((w) => w.word == _nodes[index].word);
      if (_centerIndex < 0) _centerIndex = 0;
      _buildGraph();
    });
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
      backgroundColor: colors.canvas,
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
                      nodes: _nodes, edges: _edges, onNodeTap: _selectNode)),
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
