import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_platform_analytics.dart';

class AdminBarChart extends StatefulWidget {
  final List<AdminTimeSeriesPoint> data;
  final Color color;
  final String? unit;

  const AdminBarChart({
    super.key,
    required this.data,
    required this.color,
    this.unit,
  });

  @override
  State<AdminBarChart> createState() => _AdminBarChartState();
}

class _AdminBarChartState extends State<AdminBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutQuart);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _BarChartPainter(
          data: widget.data,
          color: widget.color,
          progress: _anim.value,
          unit: widget.unit,
          textStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              ),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<AdminTimeSeriesPoint> data;
  final Color color;
  final double progress;
  final String? unit;
  final TextStyle? textStyle;

  _BarChartPainter({
    required this.data,
    required this.color,
    required this.progress,
    this.unit,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.map((d) => d.value).reduce(math.max);
    if (maxVal == 0) return;

    const labelHeight = 18.0;
    const barPad = 6.0;
    final chartH = size.height - labelHeight;
    final barW = (size.width / data.length) - barPad;

    final barPaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (var i = 0; i < data.length; i++) {
      final frac = data[i].value / maxVal;
      final barH = frac * chartH * progress;
      final left = i * (barW + barPad);
      final top = chartH - barH;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barW, barH),
        const Radius.circular(6),
      );

      glowPaint.color = color.withOpacity(0.15);
      canvas.drawRRect(rect, glowPaint);

      barPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, color.withOpacity(0.6)],
      ).createShader(Rect.fromLTWH(left, top, barW, barH));
      canvas.drawRRect(rect, barPaint);

      final span = TextSpan(text: data[i].label, style: textStyle);
      final tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barW + barPad);
      tp.paint(
        canvas,
        Offset(left + (barW - tp.width) / 2, chartH + 4),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.progress != progress || old.data != data;
}

class AdminLineChart extends StatefulWidget {
  final List<AdminTimeSeriesPoint> data;
  final Color color;

  const AdminLineChart({super.key, required this.data, required this.color});

  @override
  State<AdminLineChart> createState() => _AdminLineChartState();
}

class _AdminLineChartState extends State<AdminLineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _LineChartPainter(
          data: widget.data,
          color: widget.color,
          progress: _anim.value,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<AdminTimeSeriesPoint> data;
  final Color color;
  final double progress;

  _LineChartPainter({
    required this.data,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final maxVal = data.map((d) => d.value).reduce(math.max);
    if (maxVal == 0) return;

    final pts = List.generate(data.length, (i) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - (data[i].value / maxVal) * size.height;
      return Offset(x, y);
    });

    final cutoff = (pts.length * progress).floor().clamp(0, pts.length - 1);
    if (cutoff == 0) return;

    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (var i = 1; i <= cutoff; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(pts[cutoff].dx, size.height)
      ..lineTo(pts[0].dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.25), color.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Dot at tip
    canvas.drawCircle(
      pts[cutoff],
      4,
      Paint()..color = color,
    );
    canvas.drawCircle(
      pts[cutoff],
      6,
      Paint()
        ..color = color.withOpacity(0.25)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.progress != progress || old.data != data;
}
