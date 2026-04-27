import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../domain/activity_model.dart';
import '../application/activities_provider.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activity});

  final DynamicActivity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(activityFavoritesProvider);
    final isFav = favorites.contains(activity.id);
    final catColor = activity.category.color;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            expandedHeight: 200,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                      .withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.arrowLeft,
                    color: AppColors.celestialBlue, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                        .withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFav ? LucideIcons.heartOff : LucideIcons.heart,
                    color: isFav ? AppColors.error : AppColors.celestialBlue,
                    size: 20,
                  ),
                ),
                onPressed: () => ref
                    .read(activityFavoritesProvider.notifier)
                    .toggle(activity.id),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                        .withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.share2,
                      color: AppColors.celestialBlue, size: 20),
                ),
                onPressed: () => _share(context),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      catColor.withValues(alpha: 0.3),
                      catColor.withValues(alpha: 0.05),
                      isDark ? AppColors.darkBackground : AppColors.lightBackground,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    activity.category.icon,
                    size: 72,
                    color: catColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ),

          // ── Title Section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(activity.category.icon,
                            size: 14, color: catColor),
                        const SizedBox(width: 6),
                        Text(
                          activity.category.label,
                          style: AppTypography.caption.copyWith(
                            color: catColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.md),

                  // Title
                  Text(
                    activity.title,
                    style: AppTypography.heading2.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    activity.subtitle,
                    style: AppTypography.body.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // Info row
                  Row(
                    children: [
                      _DetailInfoChip(
                        icon: LucideIcons.clock,
                        label: activity.duration,
                        color: catColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _DetailInfoChip(
                        icon: LucideIcons.users,
                        label: activity.groupSize.label,
                        color: catColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _DetailInfoChip(
                        icon: LucideIcons.gauge,
                        label: activity.difficulty.label,
                        color: catColor,
                        isDark: isDark,
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // Description
                  Text(
                    activity.description,
                    style: AppTypography.body.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      height: 1.6,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 250.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Bible Verse Card ──
                  GlassCard(
                    padding: AppSpacing.cardPadding,
                    borderColor: AppColors.gold.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.bookOpen,
                                size: 16, color: AppColors.gold),
                            const SizedBox(width: 8),
                            Text(
                              'Versículo Base',
                              style: AppTypography.label.copyWith(
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '"${activity.bibleVerse}"',
                          style: AppTypography.bibleVerse.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '— ${activity.bibleReference}',
                            style: AppTypography.bibleReference.copyWith(
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Steps ──
                  _SectionTitle(
                      icon: LucideIcons.listOrdered,
                      title: 'Passo a Passo',
                      color: catColor,
                      isDark: isDark),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(activity.steps.length, (i) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: AppTypography.caption.copyWith(
                                  color: catColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 4),
                              child: Text(
                                activity.steps[i],
                                style:
                                    AppTypography.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(
                            duration: 300.ms,
                            delay: (400 + i * 80).ms)
                        .slideX(begin: 0.05, end: 0);
                  }),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Materials ──
                  if (activity.materials.isNotEmpty) ...[
                    _SectionTitle(
                        icon: LucideIcons.package2,
                        title: 'Materiais Necessários',
                        color: catColor,
                        isDark: isDark),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: activity.materials.map((mat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSurface2
                                : AppColors.lightSurface2,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.check,
                                  size: 14, color: AppColors.sageGreen),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  mat,
                                  style: AppTypography.caption.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // ── Leader Tip ──
                  GlassCard(
                    padding: AppSpacing.cardPadding,
                    borderColor:
                        AppColors.sageGreen.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.lightbulb,
                                size: 16,
                                color: AppColors.sageGreen),
                            const SizedBox(width: 8),
                            Text(
                              'Dica do Líder',
                              style: AppTypography.label.copyWith(
                                color: AppColors.sageGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          activity.leaderTip,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 600.ms),

                  const SizedBox(height: AppSpacing.xxxl),

                  // ── Share Button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _share(context),
                      icon: const Icon(LucideIcons.share2, size: 18),
                      label: const Text('Compartilhar Dinâmica'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: catColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd),
                        ),
                        textStyle: AppTypography.button,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms, delay: 700.ms),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _share(BuildContext context) {
    final text = '''
🎯 *${activity.title}*
${activity.subtitle}

${activity.description}

📖 *${activity.bibleReference}*
"${activity.bibleVerse}"

⏱ ${activity.duration} | 👥 ${activity.groupSize.label}

📋 *Passo a passo:*
${activity.steps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

${activity.materials.isNotEmpty ? '📦 *Materiais:* ${activity.materials.join(', ')}' : ''}

💡 *Dica:* ${activity.leaderTip}

— Enviado pelo app Palavra Viva ✝️
''';
    SharePlus.instance.share(ShareParams(text: text));
  }
}

// ── Section Title ──
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.title.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Detail Info Chip ──
class _DetailInfoChip extends StatelessWidget {
  const _DetailInfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
