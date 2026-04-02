import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  static const _activities = [
    {
      'title': 'O Mapa do Tesouro Perdido',
      'duration': '15-20 min',
      'group': 'Pequenos grupos',
      'description': 'Esconda versículos pela sala com pistas bíblicas. O primeiro grupo a encontrar todos e montar a mensagem secreta vence.',
    },
    {
      'title': 'O Cego e o Guia',
      'duration': '10-15 min',
      'group': 'Em duplas',
      'description': 'Um participante é vendado e o outro deve guiá-ao através de um percurso de obstáculos apenas usando a voz. Lição sobre confiar na voz de Deus e não na própria visão.',
    },
    {
      'title': 'Tribunal do Acusador',
      'duration': '25-30 min',
      'group': 'Geral',
      'description': 'Encene um tribunal onde alguém é acusado de seus pecados, até que o "Advogado Fiel" entra em cena pagando a fiança e libertando o réu. Fortalece o conceito da Graça.',
    },
    {
      'title': 'Espelho da Alma',
      'duration': '10 min',
      'group': 'Individual / Círculo',
      'description': 'Passe uma caixa com um "prêmio valioso" dentro. Ao abrir, a pessoa vê um espelho. Reflexão: O seu valor não está nas coisas, mas quem você é para o Criador.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.celestialBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Dinâmicas Jovem',
          style: AppTypography.heading3.copyWith(color: AppColors.celestialBlue),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: AppSpacing.screenPadding,
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final dyn = _activities[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: GlassCard(
              padding: AppSpacing.cardPadding,
              borderColor: AppColors.celestialBlue.withValues(alpha: 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dyn['title']!,
                          style: AppTypography.title.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      const Icon(LucideIcons.users, color: AppColors.celestialBlue, size: 20),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 14, color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.8) : AppColors.lightTextSecondary.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text(dyn['duration']!, style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                      const SizedBox(width: AppSpacing.md),
                      Icon(LucideIcons.userPlus, size: 14, color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.8) : AppColors.lightTextSecondary.withValues(alpha: 0.8)),
                      const SizedBox(width: 4),
                      Text(dyn['group']!, style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    dyn['description']!,
                    style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
