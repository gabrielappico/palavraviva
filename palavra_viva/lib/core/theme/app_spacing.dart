import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  // Touch target minimum (Android 48dp)
  static const double touchTarget = 48;

  // Border radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  // Commonly used EdgeInsets
  static const screenPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const cardPadding = EdgeInsets.all(lg);
  static const listItemPadding = EdgeInsets.symmetric(horizontal: lg, vertical: md);
}
