import 'dart:math';
import 'package:flutter/material.dart';

class ScanOverlayWidget extends StatefulWidget {
  const ScanOverlayWidget({
    super.key,
    required this.statusText,
    this.isScanning = true,
  });

  final String statusText;
  final bool isScanning;

  @override
  State<ScanOverlayWidget> createState() => _ScanOverlayWidgetState();
}

class _ScanOverlayWidgetState extends State<ScanOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanSize = min(constraints.maxWidth * 0.7, 300.0);
        final scanLeft = (constraints.maxWidth - scanSize) / 2;
        final scanTop = (constraints.maxHeight - scanSize) / 2 - 40;
        final scanRect = Rect.fromLTWH(scanLeft, scanTop, scanSize, scanSize);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Dark overlay with cutout
            CustomPaint(
              painter: ScannerOverlayPainter(scanRect: scanRect),
              size: Size(constraints.maxWidth, constraints.maxHeight),
            ),

            // Corner brackets
            ..._buildCorners(scanRect),

            // Animated scan line
            if (widget.isScanning)
              AnimatedBuilder(
                animation: _scanLineAnimation,
                builder: (context, _) {
                  final lineY = scanRect.top + scanRect.height * _scanLineAnimation.value;
                  return Positioned(
                    left: scanRect.left + 4,
                    top: lineY,
                    width: scanRect.width - 8,
                    height: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.greenAccent.withOpacity(0),
                            Colors.greenAccent,
                            Colors.greenAccent.withOpacity(0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Status text below scan box
            Positioned(
              left: 0,
              right: 0,
              top: scanRect.bottom + 20,
              child: Text(
                widget.statusText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildCorners(Rect scanRect) {
    const bracketLength = 20.0;
    const bracketWidth = 3.0;
    const bracketColor = Colors.greenAccent;
    const offset = 0.0;

    return [
      // Top-left
      Positioned(
        left: scanRect.left + offset,
        top: scanRect.top + offset,
        child: CustomPaint(
          painter: _CornerPainter(
            corner: _Corner.topLeft,
            color: bracketColor,
            length: bracketLength,
            strokeWidth: bracketWidth,
          ),
          size: Size(bracketLength, bracketLength),
        ),
      ),
      // Top-right
      Positioned(
        left: scanRect.right - bracketLength - offset,
        top: scanRect.top + offset,
        child: CustomPaint(
          painter: _CornerPainter(
            corner: _Corner.topRight,
            color: bracketColor,
            length: bracketLength,
            strokeWidth: bracketWidth,
          ),
          size: Size(bracketLength, bracketLength),
        ),
      ),
      // Bottom-left
      Positioned(
        left: scanRect.left + offset,
        top: scanRect.bottom - bracketLength - offset,
        child: CustomPaint(
          painter: _CornerPainter(
            corner: _Corner.bottomLeft,
            color: bracketColor,
            length: bracketLength,
            strokeWidth: bracketWidth,
          ),
          size: Size(bracketLength, bracketLength),
        ),
      ),
      // Bottom-right
      Positioned(
        left: scanRect.right - bracketLength - offset,
        top: scanRect.bottom - bracketLength - offset,
        child: CustomPaint(
          painter: _CornerPainter(
            corner: _Corner.bottomRight,
            color: bracketColor,
            length: bracketLength,
            strokeWidth: bracketWidth,
          ),
          size: Size(bracketLength, bracketLength),
        ),
      ),
    ];
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerPainter extends CustomPainter {
  final _Corner corner;
  final Color color;
  final double length;
  final double strokeWidth;

  const _CornerPainter({
    required this.corner,
    required this.color,
    required this.length,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    switch (corner) {
      case _Corner.topLeft:
        canvas.drawLine(Offset(0, length), const Offset(0, 0), paint);
        canvas.drawLine(const Offset(0, 0), Offset(length, 0), paint);
        break;
      case _Corner.topRight:
        canvas.drawLine(Offset(size.width - length, 0), Offset(size.width, 0), paint);
        canvas.drawLine(Offset(size.width, 0), Offset(size.width, length), paint);
        break;
      case _Corner.bottomLeft:
        canvas.drawLine(Offset(0, size.height - length), Offset(0, size.height), paint);
        canvas.drawLine(Offset(0, size.height), Offset(length, size.height), paint);
        break;
      case _Corner.bottomRight:
        canvas.drawLine(
          Offset(size.width - length, size.height),
          Offset(size.width, size.height),
          paint,
        );
        canvas.drawLine(
          Offset(size.width, size.height - length),
          Offset(size.width, size.height),
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) =>
      oldDelegate.corner != corner ||
      oldDelegate.color != color ||
      oldDelegate.length != length ||
      oldDelegate.strokeWidth != strokeWidth;
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect scanRect;

  ScannerOverlayPainter({required this.scanRect});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dark overlay everywhere except scanRect
    final paint = Paint()..color = Colors.black54;
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(scanRect, const Radius.circular(8)),
          ),
      ),
      paint,
    );
    // Draw green border
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(8)),
      Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) =>
      oldDelegate.scanRect != scanRect;
}
