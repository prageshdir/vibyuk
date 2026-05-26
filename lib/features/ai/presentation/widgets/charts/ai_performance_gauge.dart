import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class AiPerformanceGauge extends StatefulWidget {
  final double value;
  final double maxValue;
  final String label;
  final String? sublabel;
  final Color color;
  final double size;

  const AiPerformanceGauge({
    super.key,
    required this.value,
    required this.maxValue,
    required this.label,
    this.sublabel,
    this.color = AppColors.primary,
    this.size = 120,
  });

  @override
  State<AiPerformanceGauge> createState() => _AiPerformanceGaugeState();
}

class _AiPerformanceGaugeState extends State<AiPerformanceGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.value / widget.maxValue).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _GaugePainter(
              progress: progress * _animation.value,
              color: widget.color,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: widget.size * 0.14,
                      fontWeight: FontWeight.w800,
                      color: widget.color,
                      height: 1,
                    ),
                  ),
                  if (widget.sublabel != null)
                    Text(
                      widget.sublabel!,
                      style: TextStyle(
                        fontSize: widget.size * 0.09,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _GaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    const startAngle = -math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          color.withValues(alpha: 0.7),
          color,
        ],
        transform: GradientRotation(startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * progress,
        false,
        progressPaint,
      );

      // Glow dot at end
      final endAngle = startAngle + sweepAngle * progress;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dotX, dotY), size.width * 0.06, glowPaint);
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(Offset(dotX, dotY), size.width * 0.04, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}
