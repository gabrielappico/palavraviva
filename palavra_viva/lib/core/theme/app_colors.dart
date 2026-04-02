import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Dark Mode (default) ──
  static const darkBackground = Color(0xFF0A0E1A);
  static const darkSurface = Color(0xFF141B2D);
  static const darkSurface2 = Color(0xFF1E2740);

  // ── Light Mode ──
  static const lightBackground = Color(0xFFF5F3EE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFEDE9E0);

  // ── Brand ──
  static const gold = Color(0xFFD4A853);
  static const goldLight = Color(0xFFE8C875);
  static const goldDark = Color(0xFFB08830);
  static const celestialBlue = Color(0xFF5B8DEF);
  static const celestialBlueDark = Color(0xFF3A6FCC);
  static const sageGreen = Color(0xFF7EC8A0);

  // ── Semantic ──
  static const error = Color(0xFFE85D5D);
  static const success = Color(0xFF5DC87B);
  static const warning = Color(0xFFE8B84D);

  // ── Text Dark ──
  static const darkTextPrimary = Color(0xFFE8ECF4);
  static const darkTextSecondary = Color(0xFF8A93A6);
  static const darkTextDisabled = Color(0xFF505A6E);

  // ── Text Light ──
  static const lightTextPrimary = Color(0xFF1A1A2E);
  static const lightTextSecondary = Color(0xFF6B7280);
  static const lightTextDisabled = Color(0xFF9CA3AF);

  // ── Gradient helpers ──
  static const celestialGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0E1A), Color(0xFF141B2D)],
  );

  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4A853), Color(0xFFE8C875)],
  );

  static const headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F1528), Colors.transparent],
  );
}
