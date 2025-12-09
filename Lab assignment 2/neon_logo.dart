import 'package:flutter/material.dart';
import '../utils/color_extensions.dart';

class NeonLogo extends StatelessWidget {
  final double size;
  const NeonLogo({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final accent = Theme.of(context).colorScheme.secondary;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing ring
          CustomPaint(
            size: Size(size, size),
            painter: _NeonRingPainter(primary: primary, accent: accent),
          ),
          // Inner icon (crescent moon)
          Transform.rotate(
            angle: -0.08,
            child: CustomPaint(
              size: Size(size * 0.5, size * 0.5),
              painter: _NeonMoonPainter(accent: accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonRingPainter extends CustomPainter {
  final Color primary;
  final Color accent;
  _NeonRingPainter({required this.primary, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.3;

    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [primary.withOpacityF(0.06), accent.withOpacityF(0.12)],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.4));

    canvas.drawCircle(center, radius * 1.4, glowPaint);

    // Ring stroke using gradient
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..shader = SweepGradient(
        colors: [primary, accent, primary],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _NeonRingPainter oldDelegate) => false;
}

class _NeonMoonPainter extends CustomPainter {
  final Color accent;
  _NeonMoonPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = accent;
    final r = size.width / 2;
    final c = Offset(size.width / 2, size.height / 2);
    final moon = Path()..addOval(Rect.fromCircle(center: c, radius: r * 0.85));
    final cut = Path()
      ..addOval(
        Rect.fromCircle(center: c.translate(r * 0.35, 0), radius: r * 0.65),
      );

    final m = Path.combine(PathOperation.difference, moon, cut);
    canvas.drawPath(
      m,
      paint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      m,
      paint
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withOpacityF(0.12)
        ..strokeWidth = size.width * 0.02,
    );
  }

  @override
  bool shouldRepaint(covariant _NeonMoonPainter oldDelegate) => false;
}
