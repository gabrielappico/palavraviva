import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../domain/models/bible_book.dart';
import '../data/bible_repository.dart';
import '../domain/bible_progress_provider.dart';
import 'chapters_screen.dart';
import 'reading_plan_screen.dart';
import 'my_notes_screen.dart';

class BibleScreen extends ConsumerWidget {
  const BibleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final booksAsync = ref.watch(allBibleProvider);
    final progressAsync = ref.watch(bibleProgressProvider);
    final progressState =
        progressAsync.value ?? const BibleProgressState();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bíblia Sagrada'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          // Reading plan access
          IconButton(
            icon: const Icon(LucideIcons.target, color: AppColors.gold),
            tooltip: 'Plano de Leitura',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const ReadingPlanScreen(),
                ),
              );
            },
          ),
          // Notes access
          IconButton(
            icon: const Icon(LucideIcons.stickyNote, color: AppColors.gold),
            tooltip: 'Minhas Anotações',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const MyNotesScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: booksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (err, stack) => const Center(
          child: Text(
            'Erro ao carregar Bíblia',
            style: TextStyle(color: Colors.red),
          ),
        ),
        data: (books) {
          if (books.isEmpty) return const SizedBox.shrink();

          final oldTestament = books.take(39).toList();
          final newTestament = books.skip(39).toList();

          // Global stats
          final totalVersesRead = progressState.totalVersesRead;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Global progress card
              if (totalVersesRead > 0)
                SliverToBoxAdapter(
                  child: _GlobalProgressCard(
                    totalVersesRead: totalVersesRead,
                    books: books,
                    progressState: progressState,
                    isDark: isDark,
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Text(
                    'Antigo Testamento',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              _buildBookGrid(oldTestament, isDark, progressState),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    top: AppSpacing.xl,
                    bottom: AppSpacing.md,
                  ),
                  child: Text(
                    'Novo Testamento',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              _buildBookGrid(newTestament, isDark, progressState),
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookGrid(
    List<BibleBook> books,
    bool isDark,
    BibleProgressState progressState,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 2.5,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = books[index];
            final progress =
                progressState.bookProgress(book.abbrev, book.chapters);
            final isStarted = progressState.isBookStarted(book.abbrev);
            final isComplete = progress >= 1.0;

            return InkWell(
              onTap: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => ChaptersScreen(book: book),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isComplete
                        ? AppColors.success.withValues(alpha: 0.5)
                        : isStarted
                            ? AppColors.gold.withValues(alpha: 0.4)
                            : (isDark
                                ? AppColors.darkSurface2
                                : AppColors.lightSurface2),
                  ),
                ),
                child: Row(
                  children: [
                    // Abbreviation box
                    Container(
                      width: 48,
                      decoration: BoxDecoration(
                        color: isComplete
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppSpacing.radiusSm),
                          bottomLeft: Radius.circular(AppSpacing.radiusSm),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isComplete
                          ? const Icon(
                              LucideIcons.checkCircle,
                              color: AppColors.success,
                              size: 18,
                            )
                          : Text(
                              book.abbrev,
                              style: AppTypography.label.copyWith(
                                color: AppColors.gold,
                              ),
                            ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'book_title_${book.abbrev}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                book.name,
                                style: AppTypography.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Mini progress bar
                          if (isStarted && !isComplete) ...[
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.md,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 3,
                                  backgroundColor: isDark
                                      ? AppColors.darkSurface2
                                      : AppColors.lightSurface2,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppColors.gold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}

class _GlobalProgressCard extends StatelessWidget {
  const _GlobalProgressCard({
    required this.totalVersesRead,
    required this.books,
    required this.progressState,
    required this.isDark,
  });

  final int totalVersesRead;
  final List<BibleBook> books;
  final BibleProgressState progressState;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // Compute stats
    int completedBooks = 0;
    int startedBooks = 0;
    int totalChapters = 0;
    int completedChapters = 0;

    for (final book in books) {
      final progress = progressState.bookProgress(book.abbrev, book.chapters);
      totalChapters += book.chapters.length;
      completedChapters +=
          progressState.completedChaptersInBook(book.abbrev, book.chapters);
      if (progress >= 1.0) {
        completedBooks++;
      } else if (progressState.isBookStarted(book.abbrev)) {
        startedBooks++;
      }
    }

    final overallProgress =
        totalChapters > 0 ? completedChapters / totalChapters : 0.0;
    final overallPercent = (overallProgress * 100).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF13182B),
                    const Color(0xFF0F1528),
                  ]
                : [
                    AppColors.lightSurface,
                    AppColors.lightSurface2.withValues(alpha: 0.5),
                  ],
          ),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: isDark ? 0.15 : 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top section: Overall progress
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.md,
              ),
              child: Row(
                children: [
                  // Circular progress
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: CircularProgressIndicator(
                            value: overallProgress,
                            strokeWidth: 4,
                            strokeCap: StrokeCap.round,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.06),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.gold,
                            ),
                          ),
                        ),
                        Text(
                          '$overallPercent%',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sua Jornada Bíblica',
                          style: AppTypography.title.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$completedChapters de $totalChapters capítulos lidos',
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Linear progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: overallProgress,
                  minHeight: 4,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.06),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.gold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.black.withValues(alpha: 0.04),
            ),

            // Stats row
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: LucideIcons.bookOpen,
                      value: _formatNumber(totalVersesRead),
                      label: 'Versículos',
                      accentColor: AppColors.gold,
                      isDark: isDark,
                    ),
                  ),
                  _VerticalDivider(isDark: isDark),
                  Expanded(
                    child: _StatItem(
                      icon: LucideIcons.bookMarked,
                      value: '$startedBooks',
                      label: 'Em progresso',
                      accentColor: AppColors.celestialBlue,
                      isDark: isDark,
                    ),
                  ),
                  _VerticalDivider(isDark: isDark),
                  Expanded(
                    child: _StatItem(
                      icon: LucideIcons.checkCircle,
                      value: '$completedBooks',
                      label: 'Completos',
                      accentColor: AppColors.sageGreen,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return '$n';
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
    required this.isDark,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accentColor, size: 14),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.title.copyWith(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
            fontSize: 18,
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

