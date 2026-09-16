part of 'word_graph_page.dart';

class _GraphNode {
  final String word, meaning;
  final String relationType;
  final bool isCenter;
  Offset pos = Offset.zero;

  _GraphNode({
    required this.word,
    required this.meaning,
    this.relationType = 'center',
    this.isCenter = false,
  });

  Color get color {
    if (isCenter) return AppColors.primary;
    return switch (relationType) {
      'synonyms' => AppColors.success,
      'antonyms' => AppColors.error,
      'derivatives' => AppColors.accentPurple,
      'related' => AppColors.info,
      _ => AppColors.secondary,
    };
  }

  double get radius => isCenter ? 40 : 32;

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
  final String relationType;
  final double strength;

  _GraphEdge({
    required this.from,
    required this.to,
    required this.label,
    required this.relationType,
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
  int? _selectedIndex;

  void _layout(Size size) {
    if (widget.nodes.isEmpty) return;
    final cx = size.width / 2, cy = size.height / 2;
    // Center node
    widget.nodes[0].pos = Offset(cx, cy);
    // Group semantic relations into stable sectors, similar to an ECharts
    // category graph, so colors and meanings are visually scannable.
    if (widget.nodes.length <= 1) return;
    final shortestSide = math.min(size.width, size.height);
    final firstRadius = math.min(shortestSide * 0.30, 220.0);
    const sectorAngles = <String, double>{
      'synonyms': -0.35,
      'related': 0.35,
      'antonyms': 2.8,
      'derivatives': -2.8,
    };
    for (final relation in sectorAngles.keys) {
      final indices = <int>[
        for (var i = 1; i < widget.nodes.length; i++)
          if (widget.nodes[i].relationType == relation) i,
      ];
      for (var position = 0; position < indices.length; position++) {
        final centered = position - (indices.length - 1) / 2;
        final ring = position ~/ 6;
        final angle = sectorAngles[relation]! + centered * 0.22;
        final radius = firstRadius + ring * 92 + (position.isOdd ? 18 : 0);
        widget.nodes[indices[position]].pos = Offset(
          cx + math.cos(angle) * radius,
          cy + math.sin(angle) * radius,
        );
      }
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
            if (hit >= 0) {
              setState(() => _selectedIndex = hit);
              widget.onNodeTap(hit);
            }
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
                selectedIndex: _selectedIndex,
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
  final int? selectedIndex;

  _GraphPainter({
    required this.nodes,
    required this.edges,
    required this.isDark,
    required this.background,
    required this.border,
    required this.mutedText,
    required this.primary,
    this.hoveredIndex,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    _drawGrid(canvas, size);

    if (nodes.isEmpty) return;

    // Edges
    for (final e in edges) {
      if (e.from < 0 ||
          e.to < 0 ||
          e.from >= nodes.length ||
          e.to >= nodes.length) {
        continue;
      }
      final from = nodes[e.from].pos;
      final to = nodes[e.to].pos;
      final relationColor = _relationColor(e.relationType);
      final direction = to - from;
      final normal = Offset(-direction.dy, direction.dx);
      final normalLength = normal.distance;
      final bend = e.to.isEven ? 13.0 : -13.0;
      final control = (from + to) / 2 +
          (normalLength == 0 ? Offset.zero : normal / normalLength * bend);
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
      canvas.drawPath(
          path,
          Paint()
            ..color = relationColor.withValues(alpha: 0.10)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7);
      final linePaint = Paint()
        ..color = relationColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 + e.strength * 2;
      canvas.drawPath(path, linePaint);

      // Label at midpoint
      final mid = Offset(
        0.25 * from.dx + 0.5 * control.dx + 0.25 * to.dx,
        0.25 * from.dy + 0.5 * control.dy + 0.25 * to.dy,
      );
      final tp = TextPainter(
          text: TextSpan(
              text: e.label,
              style: TextStyle(fontSize: 10, color: relationColor)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
    }

    // Nodes (back to front)
    for (int i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      _drawNode(canvas, n, isHovered: i == hoveredIndex);
    }
    final detailIndex = selectedIndex ?? hoveredIndex;
    if (detailIndex != null &&
        detailIndex >= 0 &&
        detailIndex < nodes.length) {
      _drawTooltip(canvas, size, nodes[detailIndex]);
    }
  }

  void _drawTooltip(Canvas canvas, Size size, _GraphNode node) {
    final meaning = node.meaning.trim();
    if (meaning.isEmpty) return;
    final text = '${node.word}\n$meaning';
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
          fontSize: 12,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 4,
      ellipsis: '…',
    )..layout(maxWidth: 210);
    var origin = node.pos + Offset(node.radius + 14, -painter.height / 2 - 10);
    if (origin.dx + painter.width + 24 > size.width) {
      origin = Offset(node.pos.dx - node.radius - painter.width - 38, origin.dy);
    }
    origin = Offset(origin.dx.clamp(10, size.width - painter.width - 30),
        origin.dy.clamp(10, size.height - painter.height - 30));
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(origin.dx, origin.dy, painter.width + 24, painter.height + 20),
      const Radius.circular(10),
    );
    canvas.drawRRect(rect, Paint()..color = background.withValues(alpha: 0.97));
    canvas.drawRRect(
        rect,
        Paint()
          ..color = node.color.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
    painter.paint(canvas, origin + const Offset(12, 10));
  }

  Color _relationColor(String type) => switch (type) {
        'synonyms' => AppColors.success,
        'antonyms' => AppColors.error,
        'derivatives' => AppColors.accentPurple,
        'related' => AppColors.info,
        _ => mutedText,
      };

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
      old.selectedIndex != selectedIndex ||
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
          _LegendDot(AppColors.success, '近义词'),
          _LegendDot(AppColors.error, '反义词'),
          _LegendDot(AppColors.info, '相关词'),
          _LegendDot(AppColors.accentPurple, '派生词'),
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
