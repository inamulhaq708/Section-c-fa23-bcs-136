import 'dart:math';

import 'package:flutter/material.dart';
import '../utils/color_extensions.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  final List<List<Color>> palettes = [
    [Color(0xFF0D1B2A), Color(0xFF1B263B), Color(0xFF415A77)],
    [Color(0xFF16213E), Color(0xFF0F3460), Color(0xFFD4AF37)],
    [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF8B7355)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final t = _anim.value;
        final p = (t * (palettes.length)).floor();
        final next = (p + 1) % palettes.length;
        final localT = (t * palettes.length) - p;
        final a = palettes[p];
        final b = palettes[next];
        final List<Color> colors = List.generate(
          a.length,
          (i) => Color.lerp(a[i], b[i], localT)!,
        );
        final stops = [0.0, 0.5, 1.0];

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: stops,
            ),
          ),
          child: CustomPaint(
            painter: _GlowingOrbsPainter(t),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _GlowingOrbsPainter extends CustomPainter {
  final double t;
  _GlowingOrbsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    for (var i = 0; i < 3; i++) {
      final cx = size.width * (0.1 + i * 0.4 + sin((t + i) * (i + 1)) * 0.05);
      final cy = size.height * (0.2 + cos((t + i) * (i + 1)) * 0.05);
      paint.color = Color.lerp(
        Colors.white.withOpacityF(0.06),
        Colors.white.withOpacityF(0.12),
        i / 2,
      )!;
      final r = size.shortestSide * (0.18 - i * 0.03 + sin(t * (3 - i)) * 0.02);
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlowingOrbsPainter oldDelegate) =>
      oldDelegate.t != t;
}
