import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text('Sobre o App', style: AppTypography.heading3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxl),

            // --- Logo & Brand ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                        radius: 0.6,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.sparkles,
                      size: 64,
                      color: AppColors.gold,
                    ),
                  )
                  .animate()
                  .fade(duration: 800.ms)
                  .scale(begin: const Offset(0.8, 0.8), duration: 800.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'PALAVRA VIVA',
                    style: AppTypography.heading1.copyWith(
                      color: AppColors.gold,
                      letterSpacing: 4,
                    ),
                  ).animate().fade(delay: 200.ms, duration: 600.ms),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Versão 1.0.0',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ).animate().fade(delay: 300.ms, duration: 600.ms),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // --- Mission Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.heart, color: AppColors.gold, size: 28),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Nossa Missão',
                      style: AppTypography.heading3.copyWith(color: AppColors.gold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Palavra Viva nasceu com o propósito de aproximar pessoas da Palavra de Deus no cotidiano. '
                      'Seja através do versículo diário, das orações, do diário espiritual ou da inteligência artificial, '
                      'cada funcionalidade foi pensada para fortalecer sua caminhada de fé.',
                      style: AppTypography.bodySmall.copyWith(height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fade(delay: 400.ms, duration: 700.ms).slideY(begin: 0.1, duration: 700.ms),
            ),

            const SizedBox(height: AppSpacing.xl),

            // --- Features Summary ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'O QUE VOCÊ ENCONTRA',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.gold : AppColors.goldDark,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FeatureItem(icon: LucideIcons.bookOpen,    label: 'Bíblia Sagrada interativa', isDark: isDark),
                  _FeatureItem(icon: LucideIcons.sparkles,   label: 'Oração e intercessão guiada', isDark: isDark),
                  _FeatureItem(icon: LucideIcons.penTool,    label: 'Diário espiritual pessoal', isDark: isDark),
                  _FeatureItem(icon: Icons.auto_stories_rounded, label: 'Palavra.AI — conselheiro teológico', isDark: isDark),
                  _FeatureItem(icon: LucideIcons.lightbulb,  label: 'Quiz bíblico e dinâmicas de grupo', isDark: isDark),
                  _FeatureItem(icon: LucideIcons.mic,        label: 'Criador de pregações com IA', isDark: isDark),
                ],
              ).animate().fade(delay: 500.ms, duration: 700.ms),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // --- Divider ---
            Container(
              width: 1,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.gold.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // --- Developer Info ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  Text(
                    'Desenvolvido por',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'appicompany',
                    style: AppTypography.heading3.copyWith(color: AppColors.gold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'contato@appicompany.com',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // --- Support CTA ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: OutlinedButton.icon(
                onPressed: () => context.push('/support'),
                icon: const Icon(LucideIcons.helpCircle, size: 18, color: AppColors.gold),
                label: Text(
                  'Ajuda e Suporte',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.gold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.gold, width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppSpacing.xl),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 0),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // --- Quote ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Text(
                '"A tua palavra é lâmpada para os meus pés e luz para o meu caminho."\n— Salmos 119:105',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                      .withValues(alpha: 0.6),
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.gold),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: AppTypography.bodySmall),
          ),
        ],
      ),
    );
  }
}
