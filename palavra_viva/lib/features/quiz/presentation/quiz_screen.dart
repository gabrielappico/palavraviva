import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/quiz_provider.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gold),
          onPressed: () {
            ref.read(quizProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Text(
          'Quiz Bíblico IA',
          style: AppTypography.heading3.copyWith(color: AppColors.gold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: _buildBody(context, ref, quizState, isDark),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, QuizState state, bool isDark) {
    if (state.error != null) {
      return _buildError(ref, state.error!, isDark);
    }

    switch (state.status) {
      case QuizStatus.idle:
        return _buildIdle(ref, isDark);
      case QuizStatus.loading:
        return _buildLoading(isDark);
      case QuizStatus.playing:
        return _buildPlaying(context, ref, state, isDark);
      case QuizStatus.finished:
        return _buildFinished(context, ref, state, isDark);
    }
  }

  Widget _buildError(WidgetRef ref, String error, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertTriangle, size: 48, color: Colors.orange.shade400),
          const SizedBox(height: AppSpacing.md),
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () => ref.read(quizProvider.notifier).reset(),
            child: const Text('Tentar Novamente', style: TextStyle(color: Colors.black)),
          )
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildIdle(WidgetRef ref, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(LucideIcons.sparkles, size: 64, color: AppColors.gold)
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scaleXY(end: 1.1, duration: 1.seconds)
            .then()
            .scaleXY(end: 1 / 1.1),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Teste seus Conhecimentos',
          textAlign: TextAlign.center,
          style: AppTypography.heading2.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Perguntas únicas geradas por Inteligência Artificial toda vez que você joga.',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _DifficultyCard(
          title: 'Fácil',
          subtitle: 'Perguntas fáceis e diretas.',
          icon: LucideIcons.leaf,
          color: Colors.green.shade400,
          onTap: () => ref.read(quizProvider.notifier).generateQuestions('Fácil'),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
        const SizedBox(height: AppSpacing.md),
        _DifficultyCard(
          title: 'Médio',
          subtitle: 'Requer mais estudo das escrituras.',
          icon: LucideIcons.bookOpen,
          color: Colors.orange.shade400,
          onTap: () => ref.read(quizProvider.notifier).generateQuestions('Médio'),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
        const SizedBox(height: AppSpacing.md),
        _DifficultyCard(
          title: 'Difícil',
          subtitle: 'Apenas para teólogos experientes.',
          icon: LucideIcons.flame,
          color: Colors.red.shade400,
          onTap: () => ref.read(quizProvider.notifier).generateQuestions('Difícil'),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.gold),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Inspirando novas perguntas...\nIsso pode levar alguns segundos.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ).animate().fadeIn().slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildPlaying(BuildContext context, WidgetRef ref, QuizState state, bool isDark) {
    final q = state.questions[state.currentIndex];
    final colorSurface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final colorSurface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final colorTextPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${state.selectedDifficulty}',
              style: AppTypography.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold),
            ),
            Text(
              '${state.currentIndex + 1} / ${state.questions.length}',
              style: AppTypography.label.copyWith(color: AppColors.gold),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: (state.currentIndex + 1) / state.questions.length,
          backgroundColor: colorSurface2,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: AppSpacing.xl),
        
        // Question Card
        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: colorSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: colorSurface2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text(
            q.question,
            style: AppTypography.title.copyWith(height: 1.4, color: colorTextPrimary),
            textAlign: TextAlign.center,
          ),
        ).animate(key: ValueKey(state.currentIndex)).fadeIn().slideX(begin: 0.05),
        
        const SizedBox(height: AppSpacing.xl),
        
        // Options
        Expanded(
          child: ListView.separated(
            key: ValueKey(state.currentIndex), // Key resets animation on new question
            itemCount: q.options.length,
            separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final isCorrectOption = i == q.correctIndex;
              Color btnColor = colorSurface2;
              Color borderColor = Colors.transparent;

              if (state.isAnswered) {
                if (isCorrectOption) {
                  btnColor = Colors.green.shade800.withValues(alpha: isDark ? 0.4 : 0.8);
                  borderColor = Colors.greenAccent;
                } else if (!isCorrectOption && i != q.correctIndex) {
                  // This highlights the wrong option that might have been tapped
                  // Actually logic here needs improvement to show which one user tapped.
                  // For simplicity, we just red out everything that isn't correct.
                  btnColor = Colors.red.shade900.withValues(alpha: isDark ? 0.3 : 0.6);
                }
              }

              return InkWell(
                onTap: () => ref.read(quizProvider.notifier).answerQuestion(i),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Text(
                    q.options[i],
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: state.isAnswered && isCorrectOption ? Colors.white : colorTextPrimary, 
                      fontWeight: state.isAnswered && isCorrectOption ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (100 * i).ms).slideY(begin: 0.1);
            },
          ),
        ),
        
        // Next Button / Reference
        if (state.isAnswered)
          Column(
            children: [
              Text(
                'Confirmação: ${q.reference}',
                style: AppTypography.caption.copyWith(color: AppColors.gold, fontStyle: FontStyle.italic),
              ).animate().fadeIn().slideY(begin: 0.2),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                ),
                onPressed: () => ref.read(quizProvider.notifier).nextQuestion(),
                child: Text(
                  state.currentIndex == state.questions.length - 1 ? 'Ver Resultado' : 'Próxima Pergunta',
                  style: AppTypography.title.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ).animate().fadeIn().scale(),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
      ],
    );
  }

  Widget _buildFinished(BuildContext context, WidgetRef ref, QuizState state, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.award, color: AppColors.gold, size: 80)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(end: 1.1, duration: 1.seconds)
              .then()
              .scaleXY(end: 1 / 1.1),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Quiz Concluído!',
            style: AppTypography.heading2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Você acertou ${state.score} de ${state.questions.length}.',
            style: AppTypography.title.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            ),
            onPressed: () => ref.read(quizProvider.notifier).reset(),
            child: const Text('Jogar Novamente', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ).animate().fadeIn(delay: 400.ms).scale(),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.title.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }
}
