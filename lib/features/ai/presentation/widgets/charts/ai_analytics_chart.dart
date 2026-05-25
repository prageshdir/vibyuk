import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_analytics.dart';

class AiAnalyticsChart extends StatefulWidget {
  final List<AiMetricPoint> dataPoints;
  final Color lineColor;
  final String label;
  final String unit;
  final double height;

  const AiAnalyticsChart({
    super.key,
    required this.dataPoints,
    this.lineColor = AppColors.primary,
    this.label = 'Revenue',
    this.unit = '£',
    this.height = 180,
  });

  @override
  State<AiAnalyticsChart> createState() => _AiAnalyticsChartState();
}

class _AiAnalyticsChartState extends State<AiAnalyticsChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _drawAnimation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _drawAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: Text('No data available')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (_hoveredIndex != null)
              Text(
                '${widget.unit}${widget.dataPoints[_hoveredIndex!].value.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.lineColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTapDown: (details) => _updateHovered(details.localPosition),
          onPanUpdate: (details) => _updateHovered(details.localPosition),
          onPanEnd: (_) => setState(() => _hoveredIndex = null),
          onTapUp: (_) => setState(() => _hoveredIndex = null),
          child: AnimatedBuilder(
            animation: _drawAnimation,
            builder: (_, __) => CustomPaint(
              size: Size(double.infinity, widget.height),
              painter: _LineChartPainter(
                points: widget.dataPoints,
                progress: _drawAnimation.value,
                lineColor: widget.lineColor,
                hoveredIndex: _hoveredIndex,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.dataPoints.first.label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
            Text(
              widget.dataPoints.last.label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  void _updateHovered(Offset position) {
    if (widget.dataPoints.isEmpty) return;
    final itemWidth = context.size!.width / widget.dataPoints.length;
    final index = (position.dx / itemWidth).floor().clamp(
          0,
          widget.dataPoints.length - 1,
        );
    setState(() => _hoveredIndex = index);
  }
}

class _LineChartPainter extends CustomPainter {
  final List<AiMetricPoint> points;
  final double progress;
  final Color lineColor;
  final int? hoveredIndex;

  _LineChartPainter({
    required this.points,
    required this.progress,
    required this.lineColor,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final maxVal = points.map((p) => p.value).reduce(math.max);
    final minVal = points.map((p) => p.value).reduce(math.min);
    final range = (maxVal - minVal) == 0 ? 1.0 : maxVal - minVal;

    List<Offset> offsets = List.generate(points.length, (i) {
      final x = i * size.width / (points.length - 1);
      final normalised = (points[i].value - minVal) / range;
      final y = size.height * (1 - normalised * 0.85 - 0.05);
      return Offset(x, y);
    });

    // Determine draw cutoff
    final drawCount = (points.length * progress).ceil().clamp(1, points.length);
    final visibleOffsets = offsets.sublist(0, drawCount);

    // Fill path
    if (visibleOffsets.length >= 2) {
      final fillPath = Path();
      fillPath.moveTo(visibleOffsets.first.dx, size.height);
      fillPath.lineTo(visibleOffsets.first.dx, visibleOffsets.first.dy);
      for (int i = 1; i < visibleOffsets.length; i++) {
        final cp1 = Offset(
          (visibleOffsets[i - 1].dx + visibleOffsets[i].dx) / 2,
          visibleOffsets[i - 1].dy,
        );
        final cp2 = Offset(
          (visibleOffsets[i - 1].dx + visibleOffsets[i].dx) / 2,
          visibleOffsets[i].dy,
        );
        fillPath.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          visibleOffsets[i].dx,
          visibleOffsets[i].dy,
        );
      }
      fillPath.lineTo(visibleOffsets.last.dx, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withOpacity(0.3),
            lineColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(fillPath, fillPaint);
    }

    // Line path
    if (visibleOffsets.length >= 2) {
      final linePath = Path();
      linePath.moveTo(visibleOffsets.first.dx, visibleOffsets.first.dy);
      for (int i = 1; i < visibleOffsets.length; i++) {
        final cp1 = Offset(
          (visibleOffsets[i - 1].dx + visibleOffsets[i].dx) / 2,
          visibleOffsets[i - 1].dy,
        );
        final cp2 = Offset(
          (visibleOffsets[i - 1].dx + visibleOffsets[i].dx) / 2,
          visibleOffsets[i].dy,
        );
        linePath.cubicTo(
          cp1.dx,
          cp1.dy,
          cp2.dx,
          cp2.dy,
          visibleOffsets[i].dx,
          visibleOffsets[i].dy,
        );
      }

      final linePaint = Paint()
        ..color = lineColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(linePath, linePaint);
    }

    // Data points
    for (int i = 0; i < visibleOffsets.length; i++) {
      final isHovered = hoveredIndex == i;
      final dotPaint = Paint()
        ..color = isHovered ? lineColor : lineColor.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        visibleOffsets[i],
        isHovered ? 6 : 3,
        dotPaint,
      );
      if (isHovered) {
        final ringPaint = Paint()
          ..color = lineColor.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(visibleOffsets[i], 10, ringPaint);

        // Vertical dashed line
        final dashPaint = Paint()
          ..color = lineColor.withOpacity(0.3)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;
        double dy = 0;
        while (dy < size.height) {
          canvas.drawLine(
            Offset(visibleOffsets[i].dx, dy),
            Offset(visibleOffsets[i].dx, math.min(dy + 4, size.height)),
            dashPaint,
          );
          dy += 8;
        }
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.progress != progress ||
      old.points != points ||
      old.hoveredIndex != hoveredIndex;
}
