import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/app_theme/app_theme.dart';
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
  late List<_GraphNode> _nodes;
  late List<_GraphEdge> _edges;

  @override
  void initState() {
    super.initState();
    _centerIndex = widget.initialIndex.clamp(0, widget.words.length - 1);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('单词图谱 · ${widget.words[_centerIndex].word}'),
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
      body: _nodes.isEmpty
          ? const Center(child: Text('请先添加单词'))
          : Column(
              children: [
                Expanded(
                    child: _GraphCanvas(
                        nodes: _nodes, edges: _edges, onNodeTap: _selectNode)),
                _NodeLegend(),
              ],
            ),
    );
  }
}
