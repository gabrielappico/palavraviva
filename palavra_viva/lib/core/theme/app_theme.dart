import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.darkSurface,
          primary: AppColors.gold,
          secondary: AppColors.celestialBlue,
          tertiary: AppColors.sageGreen,
          error: AppColors.error,
          onPrimary: AppColors.darkBackground,
          onSecondary: AppColors.darkTextPrimary,
          onSurface: AppColors.darkTextPrimary,
          onError: AppColors.darkTextPrimary,
          surfaceContainerHighest: AppColors.darkSurface2,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.title.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.darkBackground,
            minimumSize: const Size(double.infinity, AppSpacing.touchTarget),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle: AppTypography.button,
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            minimumSize: const Size(double.infinity, AppSpacing.touchTarget),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            side: const BorderSide(color: AppColors.gold, width: 1.5),
            textStyle: AppTypography.button,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface2,
          hintStyle: AppTypography.body.copyWith(
            color: AppColors.darkTextSecondary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkSurface2,
          thickness: 1,
          space: 1,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextSecondary,
          size: 24,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.heading1.copyWith(color: AppColors.darkTextPrimary),
          displayMedium: AppTypography.heading2.copyWith(color: AppColors.darkTextPrimary),
          displaySmall: AppTypography.heading3.copyWith(color: AppColors.darkTextPrimary),
          titleLarge: AppTypography.title.copyWith(color: AppColors.darkTextPrimary),
          bodyLarge: AppTypography.body.copyWith(color: AppColors.darkTextPrimary),
          bodyMedium: AppTypography.bodySmall.copyWith(color: AppColors.darkTextPrimary),
          bodySmall: AppTypography.caption.copyWith(color: AppColors.darkTextSecondary),
          labelLarge: AppTypography.button.copyWith(color: AppColors.darkTextPrimary),
          labelMedium: AppTypography.label.copyWith(color: AppColors.darkTextPrimary),
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          surface: AppColors.lightSurface,
          primary: AppColors.goldDark,
          secondary: AppColors.celestialBlueDark,
          tertiary: AppColors.sageGreen,
          error: AppColors.error,
          onPrimary: AppColors.lightSurface,
          onSecondary: AppColors.lightTextPrimary,
          onSurface: AppColors.lightTextPrimary,
          onError: AppColors.lightSurface,
          surfaceContainerHighest: AppColors.lightSurface2,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.title.copyWith(
            color: AppColors.lightTextPrimary,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedItemColor: AppColors.goldDark,
          unselectedItemColor: AppColors.lightTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.goldDark,
            foregroundColor: AppColors.lightSurface,
            minimumSize: const Size(double.infinity, AppSpacing.touchTarget),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle: AppTypography.button,
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurface2,
          hintStyle: AppTypography.body.copyWith(
            color: AppColors.lightTextSecondary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.goldDark, width: 1.5),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.heading1.copyWith(color: AppColors.lightTextPrimary),
          displayMedium: AppTypography.heading2.copyWith(color: AppColors.lightTextPrimary),
          displaySmall: AppTypography.heading3.copyWith(color: AppColors.lightTextPrimary),
          titleLarge: AppTypography.title.copyWith(color: AppColors.lightTextPrimary),
          bodyLarge: AppTypography.body.copyWith(color: AppColors.lightTextPrimary),
          bodyMedium: AppTypography.bodySmall.copyWith(color: AppColors.lightTextPrimary),
          bodySmall: AppTypography.caption.copyWith(color: AppColors.lightTextSecondary),
          labelLarge: AppTypography.button.copyWith(color: AppColors.lightTextPrimary),
          labelMedium: AppTypography.label.copyWith(color: AppColors.lightTextPrimary),
        ),
      );
}
