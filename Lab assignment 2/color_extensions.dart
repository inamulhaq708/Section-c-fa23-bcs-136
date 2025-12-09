import 'package:flutter/material.dart';

extension ColorOpacityHelper on Color {
  Color withOpacityF(double opacity) =>
      withAlpha((opacity * 255).clamp(0, 255).toInt());
}
