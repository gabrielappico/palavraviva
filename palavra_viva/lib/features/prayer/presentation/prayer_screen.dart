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

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  final List<String> _emotions = [
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
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: state.prayerText != null
              ? _buildPrayerResult(state.prayerText!, isDark)
              : _buildPrayerSelector(state.isLoading, state.error, isDark),
        ),
      ),
    );
  }

  Widget _buildPrayerSelector(bool isLoading, String? error, bool isDark) {
    return CustomScrollView(
      key: const ValueKey('selector'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Como está o seu',
                  style: AppTypography.heading2.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    height: 1.1,
                  ),
                ),
                Text(
                  'coração agora?',
                  style: AppTypography.heading1.copyWith(color: AppColors.gold, height: 1.1),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Escolha o que melhor descreve seu sentimento para receber uma direção espiritual gerada pela Palavra.',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: Text(
                      error,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.md,
                  children: _emotions.map((emotion) {
                    final isSelected = _selectedEmotion == emotion;
                    return ChoiceChip(
                      label: Text(emotion),
                      selected: isSelected,
                      onSelected: isLoading ? null : (selected) {
                        setState(() {
                          _selectedEmotion = selected ? emotion : null;
                        });
                      },
                      labelStyle: AppTypography.label.copyWith(
                        color: isSelected
                            ? AppColors.darkBackground
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                      selectedColor: AppColors.gold,
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.gold
                            : (isDark ? AppColors.darkSurface2 : AppColors.lightSurface2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.huge),
                GoldButton(
                  label: 'Gerar Oração',
                  icon: LucideIcons.sparkles,
                  isLoading: isLoading,
                  onPressed: _selectedEmotion == null
                      ? null
                      : () {
                          ref.read(prayerProvider.notifier).generatePrayer(_selectedEmotion!);
                        },
                ),
              ],
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
              child: GlassCard(
                borderColor: AppColors.gold.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    const Icon(LucideIcons.heart, color: AppColors.gold, size: 28),
                    const SizedBox(height: AppSpacing.lg),
                    FadeInText(
                      text: prayer,
                      style: AppTypography.bibleText.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontSize: 18,
                        height: 1.7,
                      ),
                      charDelay: const Duration(milliseconds: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GoldButton(
            label: 'Amém',
            isOutlined: true,
            onPressed: () {
              setState(() {
                _selectedEmotion = null;
              });
              ref.read(prayerProvider.notifier).reset();
            },
          ),
        ],
      ),
    );
  }
}
