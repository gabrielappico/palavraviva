import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../domain/activity_model.dart';
import '../application/activities_provider.dart';

class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final activities = ref.watch(filteredActivitiesProvider);
    final weeklyActivity = ref.watch(weeklyActivityProvider);
    final favorites = ref.watch(activityFavoritesProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: const Icon(
                LucideIcons.arrowLeft,
                color: AppColors.celestialBlue,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Dinâmicas Jovem',
              style: AppTypography.heading3.copyWith(
                color: AppColors.celestialBlue,
              ),
            ),
            centerTitle: true,
          ),

          // ── Weekly Featured ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: _WeeklyFeaturedCard(
                activity: weeklyActivity,
                isDark: isDark,
                onTap: () =>
                    context.push('/activity-detail', extra: weeklyActivity),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
            ),
          ),

          // ── Category Chips ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: ActivityCategory.values.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final cat = ActivityCategory.values[index];
                  final isSelected = cat == selectedCategory;
                  return _CategoryChip(
                    category: cat,
                    isSelected: isSelected,
                    isDark: isDark,
                    onTap: () =>
                        ref.read(selectedCategoryProvider.notifier).select(cat),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

          // ── Activities List ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final activity = activities[index];
                final isFav = favorites.contains(activity.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child:
                      _ActivityCard(
                            activity: activity,
                            isDark: isDark,
                            isFavorite: isFav,
                            onTap: () => context.push(
                              '/activity-detail',
                              extra: activity,
                            ),
                            onFavoriteTap: () => ref
                                .read(activityFavoritesProvider.notifier)
                                .toggle(activity.id),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                          .slideX(begin: 0.05, end: 0),
                );
              }, childCount: activities.length),
            ),
          ),

          // Bottom safe area
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Weekly Featured Card ──
class _WeeklyFeaturedCard extends StatelessWidget {
  const _WeeklyFeaturedCard({
    required this.activity,
    required this.isDark,
    required this.onTap,
  });

  final DynamicActivity activity;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              activity.category.color.withValues(alpha: 0.25),
              activity.category.color.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: activity.category.color.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: activity.category.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        LucideIcons.sparkles,
                        size: 12,
                        color: activity.category.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Dinâmica da Semana',
                        style: AppTypography.caption.copyWith(
                          color: activity.category.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  activity.category.icon,
                  color: activity.category.color.withValues(alpha: 0.6),
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              activity.title,
              style: AppTypography.title.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              activity.subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _InfoChip(
                  icon: LucideIcons.clock,
                  text: activity.duration,
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.sm),
                _InfoChip(
                  icon: LucideIcons.users,
                  text: activity.groupSize.label,
                  isDark: isDark,
                ),
                const Spacer(),
                Icon(
                  LucideIcons.arrowRight,
                  size: 18,
                  color: activity.category.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity Card ──
class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.isDark,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final DynamicActivity activity;
  final bool isDark;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: AppSpacing.cardPadding,
        borderColor: activity.category.color.withValues(alpha: 0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: activity.category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    activity.category.icon,
                    color: activity.category.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: AppTypography.title.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity.subtitle,
                        style: AppTypography.caption.copyWith(
                          color: activity.category.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isFavorite ? LucideIcons.heartOff : LucideIcons.heart,
                      key: ValueKey(isFavorite),
                      color: isFavorite
                          ? AppColors.error
                          : (isDark
                                ? AppColors.darkTextDisabled
                                : AppColors.lightTextDisabled),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              activity.description,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _InfoChip(
                  icon: LucideIcons.clock,
                  text: activity.duration,
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.sm),
                _InfoChip(
                  icon: LucideIcons.users,
                  text: activity.groupSize.label,
                  isDark: isDark,
                ),
                const SizedBox(width: AppSpacing.sm),
                _DifficultyBadge(
                  difficulty: activity.difficulty,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Chip ──
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final ActivityCategory category;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.2)
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: isSelected
                ? category.color.withValues(alpha: 0.5)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06)),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 14,
              color: isSelected
                  ? category.color
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: AppTypography.caption.copyWith(
                color: isSelected
                    ? category.color
                    : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info Chip ──
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  final IconData icon;
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark
        ? AppColors.darkTextSecondary.withValues(alpha: 0.8)
        : AppColors.lightTextSecondary.withValues(alpha: 0.8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.caption.copyWith(color: color, fontSize: 11),
        ),
      ],
    );
  }
}

// ── Difficulty Badge ──
class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty, required this.isDark});

  final ActivityDifficulty difficulty;
  final bool isDark;

  Color get _color {
    switch (difficulty) {
      case ActivityDifficulty.easy:
        return AppColors.sageGreen;
      case ActivityDifficulty.medium:
        return AppColors.warning;
      case ActivityDifficulty.elaborate:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        difficulty.label,
        style: AppTypography.caption.copyWith(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
