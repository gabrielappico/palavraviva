import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  // ── UI Font (Outfit) ──
  static TextStyle get heading1 => GoogleFonts.outfit(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get heading2 => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get heading3 => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get title => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get body => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get bodySmall => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get button => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextStyle get label => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  // ── Bible / Reading Font (Merriweather) ──
  static TextStyle get bibleText => GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.8,
      );

  static TextStyle get bibleTextLight => GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        height: 1.8,
      );

  static TextStyle get bibleVerse => GoogleFonts.merriweather(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.7,
      );

  static TextStyle get bibleReference => GoogleFonts.merriweather(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      );
}
