import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/fade_in_text.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gold_button.dart';
import '../application/prayer_provider.dart';

class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen>
    with SingleTickerProviderStateMixin {
  static const _emotions = [
    'Gratidão e louvor',
    'Angústia profunda',
    'Ansiedade com o amanhã',
    'Enfraquecido e cansado',
    'Buscando direção divina',
    'Luta contra uma tentação',
    'Medo do futuro',
    'Paz no coração',
  ];

  String? _selectedEmotion;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prayerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunhão'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: state.prayerText != null
            ? _buildPrayerResult(state.prayerText!, isDark)
            : _buildPrayerSelector(state.isLoading, state.error, isDark),
      ),
    );
  }

  Widget _buildPrayerSelector(bool isLoading, String? error, bool isDark) {
    return CustomScrollView(
      key: const ValueKey('selector'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated icon header
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.08);
                      final glowAlpha = 0.15 + (_pulseController.value * 0.2);
                      return Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold.withValues(alpha: 0.08),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: glowAlpha),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Transform.scale(
                          scale: scale,
                          child: const Icon(
                            LucideIcons.heart,
                            color: AppColors.gold,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Title
                Text(
                  'Como está o seu',
                  style: AppTypography.heading2.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  'coração agora?',
                  style: AppTypography.heading1
                      .copyWith(color: AppColors.gold, height: 1.1),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Escolha o que melhor descreve seu sentimento para receber uma direção espiritual gerada pela Palavra.',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border:
                          Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertCircle,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            error,
                            style: AppTypography.bodySmall
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
        // Emotion grid
        SliverPadding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 2.2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final label = _emotions[index];
                final isSelected = _selectedEmotion == label;
                return _EmotionCard(
                  label: label,
                  isSelected: isSelected,
                  isLoading: isLoading,
                  index: index,
                  onTap: () {
                    setState(() {
                      _selectedEmotion =
                          isSelected ? null : label;
                    });
                  },
                );
              },
              childCount: _emotions.length,
            ),
          ),
        ),
        // Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.lg,
              100,
            ),
            child: GoldButton(
              label: 'Gerar Oração',
              icon: LucideIcons.sparkles,
              isLoading: isLoading,
              onPressed: _selectedEmotion == null
                  ? null
                  : () {
                      ref
                          .read(prayerProvider.notifier)
                          .generatePrayer(_selectedEmotion!);
                    },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerResult(String prayer, bool isDark) {
    return Padding(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Animated dove/heart header
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final glowAlpha =
                          0.12 + (_pulseController.value * 0.18);
                      return Container(
                        width: 60,
                        height: 60,
                        margin: const EdgeInsets.only(
                            bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              AppColors.gold.withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold
                                  .withValues(alpha: glowAlpha),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(LucideIcons.heart,
                            color: AppColors.gold, size: 26),
                      );
                    },
                  ),
                  // Prayer card
                  GlassCard(
                    borderColor:
                        AppColors.gold.withValues(alpha: 0.25),
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: FadeInText(
                      text: prayer,
                      style: AppTypography.bibleText.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontSize: 18,
                        height: 1.75,
                      ),
                      charDelay:
                          const Duration(milliseconds: 15),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Actions row
          Row(
            children: [
              Expanded(
                child: GoldButton(
                  label: 'Amém',
                  isOutlined: true,
                  onPressed: () {
                    setState(() => _selectedEmotion = null);
                    ref.read(prayerProvider.notifier).reset();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // New prayer button
              SizedBox(
                height: AppSpacing.touchTarget,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {});
                    ref.read(prayerProvider.notifier).reset();
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkSurface2
                          : AppColors.lightSurface2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd),
                    ),
                  ),
                  icon: Icon(LucideIcons.refreshCw,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                  label: Text(
                    'Nova',
                    style: AppTypography.label.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A premium emotion selection card with emoji, label, and animated selection state.
class _EmotionCard extends StatelessWidget {
  const _EmotionCard({
    required this.label,
    required this.isSelected,
    required this.isLoading,
    required this.index,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isLoading;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(end: isSelected ? 1.03 : 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gold.withValues(alpha: 0.12)
                : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected
                  ? AppColors.gold.withValues(alpha: 0.6)
                  : (isDark
                      ? AppColors.darkSurface2
                      : AppColors.lightSurface2),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.label.copyWith(
                    color: isSelected
                        ? AppColors.gold
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Selection indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isSelected ? 20 : 0,
                child: isSelected
                    ? const Icon(LucideIcons.check,
                        color: AppColors.gold, size: 16)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
