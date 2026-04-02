import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class VerseCard extends StatelessWidget {
  const VerseCard({
    super.key,
    required this.text,
    required this.reference,
    this.onTap,
    this.showDivider = true,
  });

  final String text;
  final String reference;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDivider)
              Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Text(
              '"$text"',
              style: AppTypography.bibleVerse.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '— $reference',
              style: AppTypography.bibleReference.copyWith(
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
