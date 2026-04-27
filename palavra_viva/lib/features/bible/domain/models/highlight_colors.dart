import 'package:flutter/material.dart';

/// Highlight colors for verse marks, aligned with the app's brand palette.
abstract final class HighlightColors {
  static const String gold = 'gold';
  static const String sage = 'sage';
  static const String blue = 'blue';
  static const String rose = 'rose';

  static const List<String> all = [gold, sage, blue, rose];

  static Color toColor(String? name, {double opacity = 1.0}) {
    return switch (name) {
      'gold' => const Color(0xFFD4A853).withValues(alpha: opacity),
      'sage' => const Color(0xFF7EC8A0).withValues(alpha: opacity),
      'blue' => const Color(0xFF5B8DEF).withValues(alpha: opacity),
      'rose' => const Color(0xFFE8A0B4).withValues(alpha: opacity),
      _ => Colors.transparent,
    };
  }

  static String label(String name) {
    return switch (name) {
      'gold' => 'Dourado',
      'sage' => 'Verde',
      'blue' => 'Azul',
      'rose' => 'Rosa',
      _ => name,
    };
  }
}
