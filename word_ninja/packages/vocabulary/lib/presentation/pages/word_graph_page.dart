import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ninja_theme/ninja_theme.dart';
import 'package:vocabulary/data/model/word.dart';
import 'package:vocabulary/presentation/providers/word_provider.dart';
import 'dart:math' as math;

/// 单词关系图谱页 — 展示单词之间的关联
class WordGraphPage extends ConsumerStatefulWidget {
  final List<Word> words;
  final int initialIndex;
  const WordGraphPage(
      {super.key, required this.words, this.initialIndex = 0});

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
      final remaining = all
          .where((w) => !seen.contains(w.word))
          .toList()
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
      _centerIndex = widget.words
          .indexWhere((w) => w.word == _nodes[index].word);
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
                Expanded(child: _GraphCanvas(nodes: _nodes, edges: _edges, onNodeTap: _selectNode)),
                _NodeLegend(),
              ],
            ),
    );
  }
}

class _GraphNode {
  final String word, meaning;
  final int difficulty;
  final String source;
  final List<String> tags;
  final bool isCenter;
  Offset pos = Offset.zero;

  _GraphNode({
    required this.word,
    required this.meaning,
    required this.difficulty,
    required this.source,
    required this.tags,
    this.isCenter = false,
  });

  Color get color {
    if (isCenter) return NinjaColors.primary;
    return switch (source) {
      'reading' => NinjaColors.success,
      'ai' => NinjaColors.accentPurple,
      'manual' => NinjaColors.secondary,
      _ => NinjaColors.info,
    };
  }

  double get radius => isCenter ? 40 : 28 + difficulty * 3.0;

  String get label => isCenter ? '$word\n$meaning' : word;
}

class _GraphEdge {
  final int from, to;
  final String label;
  final double strength;

  _GraphEdge({
    required this.from,
    required this.to,
    required this.label,
    this.strength = 0.3,
  });
}

class _GraphCanvas extends StatefulWidget {
  final List<_GraphNode> nodes;
  final List<_GraphEdge> edges;
  final ValueChanged<int> onNodeTap;

  const _GraphCanvas({
    required this.nodes,
    required this.edges,
    required this.onNodeTap,
  });

  @override
  State<_GraphCanvas> createState() => _GraphCanvasState();
}

class _GraphCanvasState extends State<_GraphCanvas> {
  Offset _pan = Offset.zero;
  int? _hoveredIndex;

  void _layout(Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    // Center node
    widget.nodes[0].pos = Offset(cx, cy);
    // Surrounding nodes in a circle
    final count = widget.nodes.length - 1;
    if (count <= 0) return;
    final radius = math.min(size.width, size.height) * 0.32;
    for (int i = 0; i < count; i++) {
      final angle = (2 * math.pi * i / count) - math.pi / 2;
      widget.nodes[i + 1].pos =
          Offset(cx + math.cos(angle) * radius, cy + math.sin(angle) * radius);
    }
  }

  int _hitNode(Offset pos) {
    for (int i = widget.nodes.length - 1; i >= 0; i--) {
      final dist = (widget.nodes[i].pos - pos).distance;
      if (dist < widget.nodes[i].radius + 8) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(builder: (context, constraints) {
      _layout(constraints.biggest);
      return GestureDetector(
        onTapDown: (d) {
          final hit = _hitNode(d.localPosition);
          if (hit >= 0 && hit != 0) widget.onNodeTap(hit);
        },
        onLongPressMoveUpdate: (d) {
          setState(() => _pan += d.offsetFromOrigin);
        },
        child: MouseRegion(
          onHover: (e) {
            setState(() => _hoveredIndex = _hitNode(e.localPosition));
          },
          onExit: (_) => setState(() => _hoveredIndex = null),
          child: CustomPaint(
            size: constraints.biggest,
            painter: _GraphPainter(
              nodes: widget.nodes,
              edges: widget.edges,
              isDark: isDark,
              hoveredIndex: _hoveredIndex,
            ),
          ),
        ),
      );
    });
  }
}

class _GraphPainter extends CustomPainter {
  final List<_GraphNode> nodes;
  final List<_GraphEdge> edges;
  final bool isDark;
  final int? hoveredIndex;

  _GraphPainter({
    required this.nodes,
    required this.edges,
    required this.isDark,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bg = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF5F5F5);
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    // Edges
    for (final e in edges) {
      final from = nodes[e.from].pos;
      final to = nodes[e.to].pos;
      final linePaint = Paint()
        ..color = NinjaColors.divider.withValues(alpha: 0.5)
        ..strokeWidth = 1.5 + e.strength * 2;
      canvas.drawLine(from, to, linePaint);

      // Label at midpoint
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      final tp = TextPainter(
          text: TextSpan(
              text: e.label,
              style: TextStyle(
                  fontSize: 10, color: NinjaColors.textSecondary)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
    }

    // Nodes (back to front)
    for (int i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      _drawNode(canvas, n, isHovered: i == hoveredIndex);
    }
  }

  void _drawNode(Canvas canvas, _GraphNode n, {bool isHovered = false}) {
    final r = n.radius;
    final pos = n.pos;

    // Shadow
    canvas.drawCircle(
        pos, r + 2, Paint()..color = NinjaColors.primary.withValues(alpha: 0.15));

    // Background circle
    canvas.drawCircle(pos, r, Paint()..color = n.color.withValues(alpha: 0.15));

    // Border
    canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = n.color.withValues(alpha: isHovered ? 0.9 : 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHovered ? 2.5 : 1.5);

    // Text
    final lines = n.label.split('\n');
    for (int li = 0; li < lines.length; li++) {
      final tp = TextPainter(
          text: TextSpan(
              text: lines[li],
              style: TextStyle(
                  fontSize: n.isCenter ? (li == 0 ? 14 : 10) : 11,
                  fontWeight:
                      n.isCenter && li == 0 ? FontWeight.w700 : FontWeight.w500,
                  color: isDark
                      ? NinjaColors.textOnDark
                      : NinjaColors.textPrimary)),
          textDirection: TextDirection.ltr)
        ..layout();
      final yOffset = (li - (lines.length - 1) * 0.5) * (tp.height + 2);
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2) + Offset(0, yOffset));
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) =>
      old.hoveredIndex != hoveredIndex;
}

class _NodeLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: const [
          _LegendDot(NinjaColors.primary, '中心词'),
          _LegendDot(NinjaColors.secondary, '手动添加'),
          _LegendDot(NinjaColors.success, '阅读收集'),
          _LegendDot(NinjaColors.accentPurple, 'AI 生成'),
          _LegendDot(NinjaColors.info, '其他'),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10, height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: NinjaColors.textSecondary)),
    ]);
  }
}
