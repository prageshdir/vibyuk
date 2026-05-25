import 'package:flutter/material.dart';

enum SocialProvider { google, apple, phone }

class SocialAuthButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.provider,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(context),
                  const SizedBox(width: 12),
                  Text(
                    _label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    switch (provider) {
      case SocialProvider.google:
        return _GoogleIcon();
      case SocialProvider.apple:
        return Icon(Icons.apple, size: 22, color: Theme.of(context).colorScheme.onSurface);
      case SocialProvider.phone:
        return Icon(Icons.phone_outlined, size: 20, color: Theme.of(context).colorScheme.primary);
    }
  }

  String get _label => switch (provider) {
        SocialProvider.google => 'Continue with Google',
        SocialProvider.apple => 'Continue with Apple',
        SocialProvider.phone => 'Continue with Phone',
      };
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Simplified Google G logo using arcs
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.4,
      2.0,
      true,
      paint,
    );
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.6,
      1.0,
      true,
      paint,
    );
    paint.color = const Color(0xFFFBBC04);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      2.6,
      0.8,
      true,
      paint,
    );
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.4,
      0.9,
      true,
      paint,
    );

    // White center circle to create ring effect
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
