import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../data/bible_repository.dart';
import '../domain/bible_progress_provider.dart';
import '../domain/models/reading_plan.dart';

class ReadingPlanScreen extends ConsumerWidget {
  const ReadingPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planAsync = ref.watch(readingPlanProvider);
    final progressAsync = ref.watch(bibleProgressProvider);
    final booksAsync = ref.watch(allBibleProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Plano de Leitura'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: planAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (_, _) => const Center(child: Text('Erro ao carregar plano')),
        data: (plan) {
          if (plan == null) return _EmptyState(isDark: isDark);
          final progressState =
              progressAsync.value ?? const BibleProgressState();
          final books = booksAsync.value ?? [];
          int totalCh = 0, completedCh = 0;
          for (final b in books) {
            totalCh += b.chapters.length;
            completedCh += progressState.completedChaptersInBook(
              b.abbrev,
              b.chapters,
            );
          }
          final progress = totalCh > 0 ? completedCh / totalCh : 0.0;
          final remaining = totalCh - completedCh;
          final daysRem = plan.daysRemaining;
          final dailyTarget = daysRem > 0
              ? (remaining / daysRem).ceil()
              : remaining;
          final chapsDuringPlan = (completedCh - plan.chaptersAtStart).clamp(
            0,
            completedCh,
          );
          final avg = plan.daysElapsed > 0
              ? (chapsDuringPlan / plan.daysElapsed)
              : 0.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PlanHeader(
                  plan: plan,
                  progress: progress,
                  completed: completedCh,
                  total: totalCh,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _Stat(
                        icon: LucideIcons.flame,
                        val: '${plan.daysElapsed}',
                        label: 'Dias ativos',
                        color: AppColors.gold,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _Stat(
                        icon: LucideIcons.target,
                        val: '$dailyTarget',
                        label: 'Cap./dia (meta)',
                        color: AppColors.celestialBlue,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _Stat(
                        icon: LucideIcons.trendingUp,
                        val: avg.toStringAsFixed(1),
                        label: 'Cap./dia (média)',
                        color: AppColors.sageGreen,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _RemainingInfo(
                  remaining: remaining,
                  daysRem: daysRem,
                  dailyTarget: dailyTarget,
                  avg: avg,
                  plan: plan,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _confirmDeactivate(context, ref),
                    icon: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    label: Text(
                      'Encerrar plano',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Encerrar plano?',
          style: AppTypography.title.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          'Seu progresso será mantido, mas a meta será removida.',
          style: AppTypography.body.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(readingPlanProvider.notifier).deactivatePlan();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Encerrar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.plan,
    required this.progress,
    required this.completed,
    required this.total,
    required this.isDark,
  });
  final ReadingPlan plan;
  final double progress;
  final int completed, total;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.12),
            AppColors.celestialBlue.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.flame, color: AppColors.gold, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                plan.title,
                style: AppTypography.title.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${(progress * 100).toStringAsFixed(2)}%',
            style: AppTypography.heading1.copyWith(
              color: AppColors.gold,
              fontSize: 42,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark
                  ? AppColors.darkSurface2
                  : AppColors.lightSurface2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$completed de $total capítulos',
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.val,
    required this.label,
    required this.color,
    required this.isDark,
  });
  final IconData icon;
  final String val, label;
  final Color color;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppSpacing.xs),
          Text(
            val,
            style: AppTypography.title.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RemainingInfo extends StatelessWidget {
  const _RemainingInfo({
    required this.remaining,
    required this.daysRem,
    required this.dailyTarget,
    required this.avg,
    required this.plan,
    required this.isDark,
  });
  final int remaining, daysRem, dailyTarget;
  final double avg;
  final ReadingPlan plan;
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    final onTrack = avg >= dailyTarget;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.bookOpen, color: AppColors.gold, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Faltam $remaining capítulos',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                LucideIcons.calendar,
                color: AppColors.celestialBlue,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                daysRem > 0
                    ? 'Faltam $daysRem dias para a meta'
                    : plan.isExpired
                    ? 'Prazo expirado — continue lendo!'
                    : 'Último dia!',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          if (dailyTarget > 0 && daysRem > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: (onTrack ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    onTrack ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                    size: 14,
                    color: onTrack ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      onTrack
                          ? 'No ritmo! Continue assim.'
                          : 'Leia mais ${(dailyTarget - avg).toStringAsFixed(0)} cap./dia',
                      style: AppTypography.caption.copyWith(
                        color: onTrack ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.bookOpen,
                color: AppColors.gold,
                size: 36,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Crie seu Plano de Leitura',
              style: AppTypography.heading3.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Defina uma meta e acompanhe\nsua jornada pela Palavra.',
              style: AppTypography.body.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () => _showCreate(context),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Criar Plano'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreate(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CreatePlanSheet(),
  );
}

class _CreatePlanSheet extends ConsumerStatefulWidget {
  const _CreatePlanSheet();
  @override
  ConsumerState<_CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends ConsumerState<_CreatePlanSheet> {
  double _days = 365;
  String _title = 'Bíblia em 1 Ano';
  int get _chapPerDay => (1189 / _days).ceil();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkTextDisabled
                        : AppColors.lightTextDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Criar Plano de Leitura',
                style: AppTypography.heading3.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Em quanto tempo deseja ler a Bíblia?',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildPresets(isDark),
              const SizedBox(height: AppSpacing.xl),
              Text(
                '${_days.round()} dias',
                style: AppTypography.heading3.copyWith(color: AppColors.gold),
                textAlign: TextAlign.center,
              ),
              Slider(
                value: _days,
                min: 30,
                max: 730,
                divisions: 70,
                activeColor: AppColors.gold,
                inactiveColor: AppColors.gold.withValues(alpha: 0.2),
                onChanged: (v) => setState(() {
                  _days = v;
                  _title = 'Bíblia em ${_days.round()} dias';
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$_chapPerDay',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          'capítulos/dia',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppColors.gold.withValues(alpha: 0.2),
                    ),
                    Column(
                      children: [
                        Text(
                          '1.189',
                          style: AppTypography.heading3.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'capítulos total',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  final progressState =
                      ref.read(bibleProgressProvider).value ??
                      const BibleProgressState();
                  final books = ref.read(allBibleProvider).value ?? [];
                  int currentCompleted = 0;
                  for (final b in books) {
                    currentCompleted += progressState.completedChaptersInBook(
                      b.abbrev,
                      b.chapters,
                    );
                  }
                  ref
                      .read(readingPlanProvider.notifier)
                      .createPlan(
                        title: _title,
                        targetDate: DateTime.now().add(
                          Duration(days: _days.round()),
                        ),
                        chaptersAtStart: currentCompleted,
                      );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text('Começar Plano', style: AppTypography.button),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresets(bool isDark) {
    const presets = [
      (90, '3 meses'),
      (180, '6 meses'),
      (365, '1 ano'),
      (730, '2 anos'),
    ];
    return Row(
      children: presets.map((p) {
        final sel = (_days - p.$1).abs() < 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: GestureDetector(
              onTap: () => setState(() {
                _days = p.$1.toDouble();
                _title = 'Bíblia em ${p.$2}';
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: sel
                        ? AppColors.gold
                        : (isDark
                              ? AppColors.darkSurface2
                              : AppColors.lightSurface2),
                  ),
                ),
                child: Text(
                  p.$2,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: sel
                        ? AppColors.gold
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
