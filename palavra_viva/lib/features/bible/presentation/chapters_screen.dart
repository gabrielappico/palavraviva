import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/models/bible_book.dart';
import '../domain/bible_progress_provider.dart';
import 'reading_screen.dart';

class ChaptersScreen extends ConsumerWidget {
  final BibleBook book;

  const ChaptersScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressAsync = ref.watch(bibleProgressProvider);
    final progressState =
        progressAsync.value ?? const BibleProgressState();

    final completedChapters =
        progressState.completedChaptersInBook(book.abbrev, book.chapters);
    final totalChapters = book.chapters.length;
    final bookProgress =
        progressState.bookProgress(book.abbrev, book.chapters);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.name),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Progress header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (completedChapters > 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (completedChapters >= totalChapters)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      margin: const EdgeInsets.only(
                                        right: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            LucideIcons.checkCircle,
                                            color: AppColors.success,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Completo',
                                            style:
                                                AppTypography.caption.copyWith(
                                              color: AppColors.success,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Text(
                                      '$completedChapters de $totalChapters capítulos',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: bookProgress,
                                  minHeight: 4,
                                  backgroundColor: isDark
                                      ? AppColors.darkSurface2
                                      : AppColors.lightSurface2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    completedChapters >= totalChapters
                                        ? AppColors.success
                                        : AppColors.gold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text(
                    'Selecione um capítulo',
                    style: AppTypography.heading3.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chapter grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chapterNumber = index + 1;
                  final totalVerses = book.chapters[index].length;
                  final isComplete = progressState.isChapterComplete(
                    book.abbrev,
                    chapterNumber,
                    totalVerses,
                  );
                  final isStarted = progressState.isChapterStarted(
                    book.abbrev,
                    chapterNumber,
                  );
                  final progress = progressState.chapterProgress(
                    book.abbrev,
                    chapterNumber,
                    totalVerses,
                  );

                  return _ChapterTile(
                    chapterNumber: chapterNumber,
                    isComplete: isComplete,
                    isStarted: isStarted,
                    progress: progress,
                    isDark: isDark,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReadingScreen(
                            book: book,
                            chapterIndex: index,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: book.chapters.length,
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.xxxl),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  const _ChapterTile({
    required this.chapterNumber,
    required this.isComplete,
    required this.isStarted,
    required this.progress,
    required this.isDark,
    required this.onTap,
  });

  final int chapterNumber;
  final bool isComplete;
  final bool isStarted;
  final double progress;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Visual states
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isComplete) {
      bgColor = AppColors.success.withValues(alpha: isDark ? 0.12 : 0.1);
      borderColor = AppColors.success.withValues(alpha: 0.5);
      textColor = AppColors.success;
    } else if (isStarted) {
      bgColor = AppColors.gold.withValues(alpha: isDark ? 0.08 : 0.06);
      borderColor = AppColors.gold.withValues(alpha: 0.5);
      textColor = AppColors.gold;
    } else {
      bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
      borderColor = AppColors.gold.withValues(alpha: 0.3);
      textColor = AppColors.gold;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Chapter number
            Text(
              '$chapterNumber',
              style: AppTypography.title.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Complete checkmark
            if (isComplete)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  LucideIcons.checkCircle,
                  size: 12,
                  color: AppColors.success.withValues(alpha: 0.7),
                ),
              ),

            // Partial progress dot
            if (isStarted && !isComplete)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
