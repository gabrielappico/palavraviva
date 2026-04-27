import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/gamification_models.dart';
import '../../../core/providers/gamification_provider.dart';
import '../application/insights_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.barChart3, color: AppColors.gold, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text('Meus Insights', style: AppTypography.heading3),
          ],
        ),
        centerTitle: true,
      ),
      body: ref.watch(userInsightsProvider).when(
        data: (insights) => _InsightsBody(insights: insights),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (_, _) => Center(
          child: Text('Não foi possível carregar insights',
              style: AppTypography.body.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
        ),
      ),
    );
  }
}

class _InsightsBody extends ConsumerWidget {
  const _InsightsBody({required this.insights});
  final UserInsights insights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final stats = ref.watch(userStatsProvider).asData?.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card — Level summary
          if (stats != null)
            _HeroCard(stats: stats, isDark: isDark)
                .animate().fadeIn(duration: 500.ms).slideY(begin: 0.15),

          const SizedBox(height: AppSpacing.xl),

          // Section: Leitura
          _SectionTitle(icon: LucideIcons.bookOpen, title: 'Leitura')
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _InsightTile(
                  emoji: '📖',
                  value: insights.mostReadBookName.isNotEmpty
                      ? insights.mostReadBookName
                      : '—',
                  label: 'Livro mais lido',
                  subtitle: insights.mostReadCount > 0
                      ? '${insights.mostReadCount} versículos'
                      : null,
                  color: const Color(0xFF4FC3F7),
                  surface: surface,
                  textColor: textColor,
                  subColor: subColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _InsightTile(
                  emoji: '📚',
                  value: '${insights.chaptersRead}',
                  label: 'Capítulos lidos',
                  subtitle: '${insights.booksStarted} livros',
                  color: const Color(0xFF81C784),
                  surface: surface,
                  textColor: textColor,
                  subColor: subColor,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          const SizedBox(height: AppSpacing.xl),

          // Section: Quiz
          _SectionTitle(icon: LucideIcons.brain, title: 'Quiz')
              .animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _InsightTile(
                  emoji: '🎯',
                  value: '${insights.quizAccuracy.toStringAsFixed(0)}%',
                  label: 'Precisão',
                  subtitle: insights.quizzesMonth > 0
                      ? '${insights.quizzesMonth} este mês'
                      : null,
                  color: _accuracyColor(insights.quizAccuracy),
                  surface: surface,
                  textColor: textColor,
                  subColor: subColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _InsightTile(
                  emoji: '🏷️',
                  value: insights.favoriteCategoryName.isNotEmpty
                      ? insights.favoriteCategoryName
                      : '—',
                  label: 'Categoria favorita',
                  color: const Color(0xFFFFB74D),
                  surface: surface,
                  textColor: textColor,
                  subColor: subColor,
                  smallValue: true,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

          const SizedBox(height: AppSpacing.xl),

          // Section: Fé Diária
          _SectionTitle(icon: LucideIcons.heart, title: 'Fé Diária')
              .animate().fadeIn(delay: 500.ms),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _InsightTile(
                  emoji: '🙏',
                  value: '${insights.prayersMonth}',
                  label: 'Orações este mês',
                  color: const Color(0xFFCE93D8),
                  surface: surface,
                  textColor: textColor,
                  subColor: subColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _InsightTile(
                  emoji: '✍️',
                  value: '${insights.journalsMonth}',
                  label: 'Reflexões este mês',
                  color: const Color(0xFFA1887F),
                  surface: surface,
                  textColor: textColor,
                  subColor: subColor,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),

          const SizedBox(height: AppSpacing.xl),

          // Section: Jornada
          _SectionTitle(icon: LucideIcons.trendingUp, title: 'Jornada')
              .animate().fadeIn(delay: 700.ms),
          const SizedBox(height: AppSpacing.md),

          _JourneyStrip(insights: insights, isDark: isDark)
              .animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Color _accuracyColor(double accuracy) {
    if (accuracy >= 80) return const Color(0xFF81C784);
    if (accuracy >= 50) return const Color(0xFFFFB74D);
    return const Color(0xFFE57373);
  }
}

// ═══════════════════════════════════════════════
// HERO CARD — Level + XP Summary
// ═══════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.stats, required this.isDark});
  final UserStats stats;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.08),
            surface,
            AppColors.celestialBlue.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Column(
        children: [
          // Level circle + title
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gold.withValues(alpha: 0.3),
                      AppColors.gold.withValues(alpha: 0.08),
                    ],
                  ),
                  border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.5), width: 2.5),
                ),
                child: Center(
                  child: Text('${stats.level}',
                      style: AppTypography.heading2.copyWith(
                          color: AppColors.gold,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${stats.titleEmoji} ${stats.title}',
                        style: AppTypography.title.copyWith(
                            color: AppColors.gold, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${_formatXp(stats.totalXp)} XP acumulados',
                        style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stats.levelProgress,
              backgroundColor: isDark
                  ? AppColors.darkSurface2
                  : AppColors.lightSurface2,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nível ${stats.level}',
                  style: AppTypography.caption.copyWith(
                      color: AppColors.gold, fontSize: 11)),
              Text(stats.level < UserStats.maxLevel
                  ? '${stats.totalXp} / ${stats.xpForNextLevel} XP → Nível ${stats.level + 1}'
                  : 'Nível máximo alcançado! 🏆',
                  style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 10000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return xp.toString();
  }
}

// ═══════════════════════════════════════════════
// INSIGHT TILE
// ═══════════════════════════════════════════════

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
    required this.surface,
    required this.textColor,
    required this.subColor,
    this.subtitle,
    this.smallValue = false,
  });

  final String emoji, value, label;
  final Color color, surface, textColor, subColor;
  final String? subtitle;
  final bool smallValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: smallValue
                ? AppTypography.label.copyWith(
                    color: textColor, fontWeight: FontWeight.bold, fontSize: 13)
                : AppTypography.heading3.copyWith(
                    color: textColor, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.caption.copyWith(
                  color: subColor, fontSize: 11)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: AppTypography.caption.copyWith(
                    color: color, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// JOURNEY STRIP
// ═══════════════════════════════════════════════

class _JourneyStrip extends StatelessWidget {
  const _JourneyStrip({required this.insights, required this.isDark});
  final UserInsights insights;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _JourneyStat(
            icon: LucideIcons.flame,
            value: '${insights.currentStreak}',
            label: 'Streak atual',
            color: Colors.orange.shade300,
            textColor: textColor,
            subColor: subColor,
          ),
          _divider(),
          _JourneyStat(
            icon: LucideIcons.trophy,
            value: '${insights.longestStreak}',
            label: 'Maior streak',
            color: AppColors.gold,
            textColor: textColor,
            subColor: subColor,
          ),
          _divider(),
          _JourneyStat(
            icon: LucideIcons.calendarCheck,
            value: '${insights.daysActive}',
            label: 'Dias ativos',
            color: const Color(0xFF81C784),
            textColor: textColor,
            subColor: subColor,
          ),
          _divider(),
          _JourneyStat(
            icon: LucideIcons.activity,
            value: '${insights.totalActivities}',
            label: 'Atividades',
            color: const Color(0xFF4FC3F7),
            textColor: textColor,
            subColor: subColor,
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06),
    );
  }
}

class _JourneyStat extends StatelessWidget {
  const _JourneyStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    required this.subColor,
  });

  final IconData icon;
  final String value, label;
  final Color color, textColor, subColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 6),
        Text(value,
            style: AppTypography.label.copyWith(
                color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label,
            style: AppTypography.caption.copyWith(
                color: subColor, fontSize: 9)),
      ],
    );
  }
}

// ═══════════════════════════════════════════════
// SECTION TITLE
// ═══════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 8),
        Text(title,
            style: AppTypography.label.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ],
    );
  }
}
