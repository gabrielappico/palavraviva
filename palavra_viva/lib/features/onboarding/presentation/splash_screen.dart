import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Exibe o espetáculo majestoso e redireciona ao ecossistema
    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          context.go('/home');
        } else {
          context.go('/auth');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Forçar paleta dark para a Splash mesmo se o device for light. É uma escolha artística de imersão.
    return Scaffold(
      backgroundColor: const Color(0xFF04060A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Brilhante Celestial
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                  radius: 0.6, // Esfumaça para fora como uma nebulosa dourada
                ),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 72,
                color: AppColors.gold,
              ),
            )
            .animate()
            .fade(duration: 1000.ms, curve: Curves.easeOut)
            .scale(begin: const Offset(0.8, 0.8), duration: 1000.ms, curve: Curves.easeOutCubic)
            .then()
            .shimmer(duration: 1600.ms, color: Colors.white.withValues(alpha: 0.4)),

            const SizedBox(height: AppSpacing.xl),

            // Título Sagrado
            Text(
              'PALAVRA VIVA',
              style: AppTypography.heading1.copyWith(
                color: AppColors.gold,
                fontSize: 32,
                letterSpacing: 4,
              ),
            )
            .animate()
            .fade(delay: 800.ms, duration: 800.ms)
            .slideY(begin: 0.2, duration: 800.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: AppSpacing.md),

            // Slogan Subliminar
            Text(
              'A sabedoria eterna, sempre presente.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkTextSecondary,
                letterSpacing: 1.5,
              ),
            )
            .animate()
            .fade(delay: 1500.ms, duration: 1000.ms),
          ],
        ),
      ),
    );
  }
}
