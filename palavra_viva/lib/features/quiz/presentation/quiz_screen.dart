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
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
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
          'Quiz Bíblico',
          style: AppTypography.heading3.copyWith(color: AppColors.gold),
        ),
        centerTitle: true,
        actions: [
          // Streak badge
          ref
              .watch(userStatsProvider)
              .when(
                data: (stats) => stats.currentStreak > 0
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🕊️', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              '${stats.currentStreak}',
                              style: AppTypography.label.copyWith(
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: _buildBody(context, ref, quizState, isDark),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    QuizState state,
    bool isDark,
  ) {
    if (state.error != null) return _buildError(ref, state.error!, isDark);
    switch (state.status) {
      case QuizStatus.idle:
        return _QuizSetup(isDark: isDark);
      case QuizStatus.loading:
        return _buildLoading(isDark);
      case QuizStatus.playing:
        return _buildPlaying(context, ref, state, isDark);
      case QuizStatus.finished:
        return _QuizResult(state: state, isDark: isDark);
    }
  }

  Widget _buildError(WidgetRef ref, String error, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.alertTriangle,
            size: 48,
            color: Colors.orange.shade400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            error,
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            onPressed: () => ref.read(quizProvider.notifier).reset(),
            child: const Text('Voltar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ).animate().fadeIn().scale(),
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
            'Gerando perguntas com IA...',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaying(
    BuildContext context,
    WidgetRef ref,
    QuizState state,
    bool isDark,
  ) {
    final q = state.questions[state.currentIndex];
    final colorSurface = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final colorSurface2 = isDark
        ? AppColors.darkSurface2
        : AppColors.lightSurface2;
    final colorText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header: mode info + progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (state.selectedCategory != null)
                  Text(
                    '${state.selectedCategory!.emoji} ',
                    style: const TextStyle(fontSize: 16),
                  ),
                Text(
                  state.selectedDifficulty ?? '',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (state.gameMode == GameMode.marathon)
              Row(
                children: [
                  Text(
                    '❤️ ${state.marathonLives}  ',
                    style: AppTypography.caption.copyWith(
                      color: Colors.red.shade300,
                    ),
                  ),
                  Text(
                    '${state.currentIndex + 1}',
                    style: AppTypography.label.copyWith(color: AppColors.gold),
                  ),
                ],
              )
            else
              Text(
                '${state.currentIndex + 1} / ${state.questions.length}',
                style: AppTypography.label.copyWith(color: AppColors.gold),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Timer bar for timed mode
        if (state.gameMode == GameMode.timed) ...[
          LinearProgressIndicator(
            value: state.timeRemaining / 15,
            backgroundColor: colorSurface2,
            valueColor: AlwaysStoppedAnimation(
              state.timeRemaining <= 5 ? Colors.red : AppColors.gold,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${state.timeRemaining}s',
              style: AppTypography.caption.copyWith(
                color: state.timeRemaining <= 5 ? Colors.red : AppColors.gold,
              ),
            ),
          ),
        ] else
          LinearProgressIndicator(
            value: state.gameMode == GameMode.marathon
                ? 1.0
                : (state.currentIndex + 1) / state.questions.length,
            backgroundColor: colorSurface2,
            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
            borderRadius: BorderRadius.circular(4),
          ),

        const SizedBox(height: AppSpacing.lg),

        // Question card
        Container(
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: colorSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: colorSurface2),
              ),
              child: Text(
                q.question,
                style: AppTypography.title.copyWith(
                  height: 1.4,
                  color: colorText,
                ),
                textAlign: TextAlign.center,
              ),
            )
            .animate(key: ValueKey(state.currentIndex))
            .fadeIn()
            .slideX(begin: 0.05),

        const SizedBox(height: AppSpacing.lg),

        // Options
        Expanded(
          child: ListView.separated(
            key: ValueKey(state.currentIndex),
            itemCount: q.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              Color btnColor = colorSurface2;
              Color borderColor = Colors.transparent;
              Color textColor = colorText;

              if (state.isAnswered) {
                if (i == q.correctIndex) {
                  btnColor = Colors.green.shade800.withValues(
                    alpha: isDark ? 0.4 : 0.8,
                  );
                  borderColor = Colors.greenAccent;
                  textColor = Colors.white;
                } else if (i == state.selectedAnswer) {
                  btnColor = Colors.red.shade900.withValues(
                    alpha: isDark ? 0.4 : 0.6,
                  );
                  borderColor = Colors.red.shade400;
                  textColor = Colors.white;
                } else {
                  btnColor = colorSurface2.withValues(alpha: 0.5);
                }
              }

              return InkWell(
                onTap: state.isAnswered
                    ? null
                    : () => ref.read(quizProvider.notifier).answerQuestion(i),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Text(
                    q.options[i],
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: (80 * i).ms).slideY(begin: 0.1);
            },
          ),
        ),

        // Next button + reference
        if (state.isAnswered) ...[
          Text(
            '📖 ${q.reference}',
            style: AppTypography.caption.copyWith(
              color: AppColors.gold,
              fontStyle: FontStyle.italic,
            ),
          ).animate().fadeIn(),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            onPressed: () => ref.read(quizProvider.notifier).nextQuestion(),
            child: Text(
              state.gameMode == GameMode.marathon && state.marathonLives <= 0
                  ? 'Ver Resultado'
                  : state.currentIndex == state.questions.length - 1 &&
                        state.gameMode != GameMode.marathon
                  ? 'Ver Resultado'
                  : 'Próxima Pergunta',
              style: AppTypography.title.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).animate().fadeIn().scale(),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

// --- Setup Screen (category + mode + difficulty selection) ---

class _QuizSetup extends ConsumerStatefulWidget {
  final bool isDark;
  const _QuizSetup({required this.isDark});

  @override
  ConsumerState<_QuizSetup> createState() => _QuizSetupState();
}

class _QuizSetupState extends ConsumerState<_QuizSetup> {
  int _step = 0; // 0=category, 1=mode, 2=difficulty

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final quizState = ref.watch(quizProvider);

    if (_step == 0) return _buildCategorySelect(isDark);
    if (_step == 1) return _buildModeSelect(isDark);
    return _buildDifficultySelect(isDark, quizState);
  }

  Widget _buildCategorySelect(bool isDark) {
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha o tema',
          style: AppTypography.heading2.copyWith(color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecione a categoria das perguntas',
          style: AppTypography.caption.copyWith(color: subColor),
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: quizCategories.length,
            itemBuilder: (context, i) {
              final cat = quizCategories[i];
              final bg = isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface;
              final border = isDark
                  ? AppColors.darkSurface2
                  : AppColors.lightSurface2;

              return InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () {
                  ref.read(quizProvider.notifier).selectCategory(cat);
                  setState(() => _step = 1);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 6),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (50 * i).ms).slideY(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelect(bool isDark) {
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final modes = [
      (
        GameMode.classic,
        'Clássico',
        '5 perguntas, sem tempo',
        LucideIcons.bookOpen,
        Colors.green.shade400,
      ),
      (
        GameMode.timed,
        'Contra o Tempo',
        '5 perguntas, 15s cada',
        LucideIcons.timer,
        Colors.orange.shade400,
      ),
      (
        GameMode.marathon,
        'Maratona',
        'Infinito até errar',
        LucideIcons.flame,
        Colors.red.shade400,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _step = 0),
          child: Row(
            children: [
              const Icon(
                LucideIcons.arrowLeft,
                size: 16,
                color: AppColors.gold,
              ),
              const SizedBox(width: 8),
              Text(
                'Voltar',
                style: AppTypography.caption.copyWith(color: AppColors.gold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Modo de Jogo',
          style: AppTypography.heading2.copyWith(color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          'Como você quer jogar?',
          style: AppTypography.caption.copyWith(color: subColor),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...modes.asMap().entries.map((e) {
          final (mode, title, sub, icon, color) = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _OptionCard(
              title: title,
              subtitle: sub,
              icon: icon,
              color: color,
              onTap: () {
                ref.read(quizProvider.notifier).selectGameMode(mode);
                setState(() => _step = 2);
              },
            ).animate().fadeIn(delay: (100 * e.key).ms).slideY(begin: 0.2),
          );
        }),
      ],
    );
  }

  Widget _buildDifficultySelect(bool isDark, QuizState quizState) {
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final difficulties = [
      (
        'Fácil',
        'Perguntas fáceis e diretas.',
        LucideIcons.leaf,
        Colors.green.shade400,
      ),
      (
        'Médio',
        'Requer mais estudo das escrituras.',
        LucideIcons.bookOpen,
        Colors.orange.shade400,
      ),
      (
        'Difícil',
        'Apenas para teólogos experientes.',
        LucideIcons.flame,
        Colors.red.shade400,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _step = 1),
          child: Row(
            children: [
              const Icon(
                LucideIcons.arrowLeft,
                size: 16,
                color: AppColors.gold,
              ),
              const SizedBox(width: 8),
              Text(
                'Voltar',
                style: AppTypography.caption.copyWith(color: AppColors.gold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Dificuldade',
          style: AppTypography.heading2.copyWith(color: textColor),
        ),
        const SizedBox(height: 4),
        Text(
          '${quizState.selectedCategory?.emoji ?? ""} ${quizState.selectedCategory?.name ?? ""} • ${quizState.gameMode == GameMode.classic
              ? "Clássico"
              : quizState.gameMode == GameMode.timed
              ? "Contra o Tempo"
              : "Maratona"}',
          style: AppTypography.caption.copyWith(color: subColor),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...difficulties.asMap().entries.map((e) {
          final (title, sub, icon, color) = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _OptionCard(
              title: title,
              subtitle: sub,
              icon: icon,
              color: color,
              onTap: () =>
                  ref.read(quizProvider.notifier).generateQuestions(title),
            ).animate().fadeIn(delay: (100 * e.key).ms).slideY(begin: 0.2),
          );
        }),
      ],
    );
  }
}

// --- Result Screen ---

class _QuizResult extends ConsumerWidget {
  final QuizState state;
  final bool isDark;
  const _QuizResult({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final total = state.gameMode == GameMode.marathon
        ? state.currentIndex + 1
        : state.questions.length;
    final result = state.lastResult;
    final isPerfect = state.score == total && total > 0;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                  isPerfect ? LucideIcons.crown : LucideIcons.award,
                  color: AppColors.gold,
                  size: 72,
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(end: 1.1, duration: 1.seconds),
            const SizedBox(height: AppSpacing.lg),
            Text(
              isPerfect ? '🏆 Perfeito!' : 'Quiz Concluído!',
              style: AppTypography.heading2.copyWith(color: textColor),
            ).animate().fadeIn(),
            const SizedBox(height: AppSpacing.sm),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final threshold = total > 0 ? (i + 1) / 5 * total : 0;
                return Icon(
                  state.score >= threshold
                      ? LucideIcons.star
                      : Icons.star_border_rounded,
                  color: state.score >= threshold ? AppColors.gold : subColor,
                  size: 28,
                );
              }),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.sm),

            Text(
              '${state.score} / $total acertos',
              style: AppTypography.title.copyWith(color: subColor),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppSpacing.xl),

            // XP & Stats card
            if (result != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: surface2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatBadge(
                          label: 'XP Ganho',
                          value: '+${result.xpEarned}',
                          icon: '⭐',
                        ),
                        _StatBadge(
                          label: 'Streak',
                          value: '${result.newStreak} dias',
                          icon: '🕊️',
                        ),
                        _StatBadge(
                          label: 'XP Total',
                          value: _formatXp(result.newTotalXp),
                          icon: '📊',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Title progress
                    ref
                        .watch(userStatsProvider)
                        .when(
                          data: (stats) => Column(
                            children: [
                              Text(
                                '${stats.titleEmoji} ${stats.title}',
                                style: AppTypography.label.copyWith(
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: stats.levelProgress,
                                backgroundColor: surface2,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.gold,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Nível ${stats.level} · ${stats.totalXp} / ${stats.xpForNextLevel} XP',
                                style: AppTypography.caption.copyWith(
                                  color: subColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            // Free life earned banner
            if (result != null && result.earnedFreeLife)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: AppSpacing.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎮', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '+1 Vida Grátis!',
                      style: AppTypography.label.copyWith(
                        color: const Color(0xFF81C784),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Jogue sem anúncio',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF81C784).withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).scaleXY(begin: 0.9),

            const SizedBox(height: AppSpacing.xl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.gold),
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      LucideIcons.trophy,
                      color: AppColors.gold,
                      size: 18,
                    ),
                    label: Text(
                      'Ranking',
                      style: AppTypography.body.copyWith(color: AppColors.gold),
                    ),
                    onPressed: () => context.push('/leaderboard'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      LucideIcons.rotateCcw,
                      color: Colors.black,
                      size: 18,
                    ),
                    label: Text(
                      'Jogar',
                      style: AppTypography.body.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => ref.read(quizProvider.notifier).reset(),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 10000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return xp.toString();
  }
}

class _StatBadge extends StatelessWidget {
  final String label, value, icon;
  const _StatBadge({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.label.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
          ),
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
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
