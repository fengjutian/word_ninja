part of 'word_graph_page.dart';

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
    if (isCenter) return AppColors.primary;
    return switch (source) {
      'reading' => AppColors.success,
      'ai' => AppColors.accentPurple,
      'manual' => AppColors.secondary,
      _ => AppColors.info,
    };
  }

  double get radius => isCenter ? 40 : 28 + difficulty * 3.0;

  String get label {
    if (!isCenter) return word;
    final cleanMeaning = meaning.trim() == '解析失败' ? '暂无释义' : meaning.trim();
    if (cleanMeaning.isEmpty) return word;
    final shortMeaning = cleanMeaning.length > 12
        ? '${cleanMeaning.substring(0, 12)}…'
        : cleanMeaning;
    return '$word\n$shortMeaning';
  }
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
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(builder: (context, constraints) {
      _layout(constraints.biggest);
      return InteractiveViewer(
        minScale: 0.65,
        maxScale: 2.5,
        boundaryMargin: const EdgeInsets.all(180),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) {
            final hit = _hitNode(d.localPosition);
            if (hit >= 0) widget.onNodeTap(hit);
          },
          child: MouseRegion(
            onHover: (e) {
              final hit = _hitNode(e.localPosition);
              if (hit != _hoveredIndex) setState(() => _hoveredIndex = hit);
            },
            onExit: (_) => setState(() => _hoveredIndex = null),
            child: CustomPaint(
              size: constraints.biggest,
              painter: _GraphPainter(
                nodes: widget.nodes,
                edges: widget.edges,
                isDark: isDark,
                background: colors.sidebar,
                border: colors.border,
                mutedText: colors.mutedText,
                primary: primary,
                hoveredIndex: _hoveredIndex,
              ),
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
  final Color background, border, mutedText, primary;
  final int? hoveredIndex;

  _GraphPainter({
    required this.nodes,
    required this.edges,
    required this.isDark,
    required this.background,
    required this.border,
    required this.mutedText,
    required this.primary,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    _drawGrid(canvas, size);

    // Edges
    for (final e in edges) {
      final from = nodes[e.from].pos;
      final to = nodes[e.to].pos;
      final linePaint = Paint()
        ..color = border.withValues(alpha: 0.8)
        ..strokeWidth = 1.5 + e.strength * 2;
      canvas.drawLine(from, to, linePaint);

      // Label at midpoint
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      final tp = TextPainter(
          text: TextSpan(
              text: e.label, style: TextStyle(fontSize: 10, color: mutedText)),
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

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = border.withValues(alpha: 0.32)
      ..strokeWidth = 1;
    const gap = 32.0;
    for (double x = gap; x < size.width; x += gap) {
      for (double y = gap; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  void _drawNode(Canvas canvas, _GraphNode n, {bool isHovered = false}) {
    final r = n.radius;
    final pos = n.pos;

    // Shadow
    final nodeColor = n.isCenter ? primary : n.color;
    canvas.drawCircle(pos, r + (isHovered ? 5 : 3),
        Paint()..color = nodeColor.withValues(alpha: isHovered ? 0.14 : 0.08));

    // Background circle
    canvas.drawCircle(pos, r,
        Paint()..color = nodeColor.withValues(alpha: isDark ? 0.22 : 0.10));

    // Border
    canvas.drawCircle(
        pos,
        r,
        Paint()
          ..color = nodeColor.withValues(alpha: isHovered ? 0.95 : 0.58)
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
                  color:
                      isDark ? AppColors.textOnDark : AppColors.textPrimary)),
          textDirection: TextDirection.ltr)
        ..layout();
      final yOffset = (li - (lines.length - 1) * 0.5) * (tp.height + 2);
      tp.paint(canvas,
          pos - Offset(tp.width / 2, tp.height / 2) + Offset(0, yOffset));
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) =>
      old.hoveredIndex != hoveredIndex ||
      old.nodes != nodes ||
      old.edges != edges ||
      old.background != background ||
      old.primary != primary;
}

class _NodeLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.appColors.subtleSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: const [
          _LegendDot(AppColors.primary, '中心词'),
          _LegendDot(AppColors.secondary, '手动添加'),
          _LegendDot(AppColors.success, '阅读收集'),
          _LegendDot(AppColors.accentPurple, 'AI 生成'),
          _LegendDot(AppColors.info, '其他'),
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(fontSize: 11, color: context.appColors.mutedText)),
    ]);
  }
}
