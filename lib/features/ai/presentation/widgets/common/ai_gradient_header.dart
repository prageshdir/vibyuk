import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vibyuk/core/theme/app_colors.dart';

class AiGradientHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final double height;

  const AiGradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.height = 180,
  });

  @override
  State<AiGradientHeader> createState() => _AiGradientHeaderState();
}

class _AiGradientHeaderState extends State<AiGradientHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Animated mesh gradient
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => CustomPaint(
                painter: _MeshGradientPainter(_controller.value),
              ),
            ),
          ),
          // Frosted glass overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.tertiary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.tertiary.withOpacity(0.6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.tertiary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'AI POWERED',
                                  style: TextStyle(
                                    color: AppColors.tertiary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MeshGradientPainter extends CustomPainter {
  final double t;

  _MeshGradientPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Base gradient
    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF3A0CA3),
        Color(0xFF7B2FFF),
        Color(0xFF4CC9F0),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Animated orb 1
    final orb1X = size.width * (0.2 + 0.3 * math.sin(t * 2 * math.pi));
    final orb1Y = size.height * (0.3 + 0.2 * math.cos(t * 2 * math.pi));
    paint.shader = RadialGradient(
      colors: [
        AppColors.secondary.withOpacity(0.5),
        AppColors.secondary.withOpacity(0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(orb1X, orb1Y),
      radius: size.width * 0.35,
    ));
    canvas.drawCircle(Offset(orb1X, orb1Y), size.width * 0.35, paint);

    // Animated orb 2
    final orb2X =
        size.width * (0.7 + 0.2 * math.cos(t * 2 * math.pi + 1.5));
    final orb2Y = size.height * (0.5 + 0.3 * math.sin(t * 2 * math.pi + 1));
    paint.shader = RadialGradient(
      colors: [
        AppColors.tertiary.withOpacity(0.4),
        AppColors.tertiary.withOpacity(0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(orb2X, orb2Y),
      radius: size.width * 0.3,
    ));
    canvas.drawCircle(Offset(orb2X, orb2Y), size.width * 0.3, paint);
  }

  @override
  bool shouldRepaint(_MeshGradientPainter old) => old.t != t;
}
