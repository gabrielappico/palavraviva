import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/models/bible_book.dart';
import '../domain/bible_progress_provider.dart';
import '../domain/models/highlight_colors.dart';
import 'verse_action_sheet.dart';
import 'verse_note_editor.dart';

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({
    super.key,
    required this.book,
    required this.chapterIndex,
  });

  final BibleBook book;
  final int chapterIndex;

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  double _fontSizeTheme = 18.0;

  int get _chapterNumber => widget.chapterIndex + 1;
  List<String> get _verses => widget.book.chapters[widget.chapterIndex];

  void _showVerseActions(int verseIndex) {
    final verseNumber = verseIndex + 1;
    final verseText = _verses[verseIndex];
    final progressState = ref.read(bibleProgressProvider).value;
    final mark = progressState?.verseMark(
      widget.book.abbrev,
      _chapterNumber,
      verseNumber,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VerseActionSheet(
        bookName: widget.book.name,
        bookAbbrev: widget.book.abbrev,
        chapter: _chapterNumber,
        verseNumber: verseNumber,
        verseText: verseText,
        currentMark: mark,
        onToggleRead: () {
          ref.read(bibleProgressProvider.notifier).toggleRead(
                bookAbbrev: widget.book.abbrev,
                chapter: _chapterNumber,
                verse: verseNumber,
              );
        },
        onHighlight: (color) {
          ref.read(bibleProgressProvider.notifier).setHighlight(
                bookAbbrev: widget.book.abbrev,
                chapter: _chapterNumber,
                verse: verseNumber,
                color: color,
              );
        },
        onNote: () => _showNoteEditor(verseIndex),
      ),
    );
  }

  void _showNoteEditor(int verseIndex) {
    final verseNumber = verseIndex + 1;
    final verseText = _verses[verseIndex];
    final progressState = ref.read(bibleProgressProvider).value;
    final mark = progressState?.verseMark(
      widget.book.abbrev,
      _chapterNumber,
      verseNumber,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VerseNoteEditor(
        bookName: widget.book.name,
        chapter: _chapterNumber,
        verseNumber: verseNumber,
        verseText: verseText,
        initialNote: mark?.note,
        onSave: (note) {
          ref.read(bibleProgressProvider.notifier).setNote(
                bookAbbrev: widget.book.abbrev,
                chapter: _chapterNumber,
                verse: verseNumber,
                noteText: note,
              );
        },
      ),
    );
  }

  void _markAllAsRead() {
    ref.read(bibleProgressProvider.notifier).markChapterAsRead(
          bookAbbrev: widget.book.abbrev,
          chapter: _chapterNumber,
          totalVerses: _verses.length,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.book.name} $_chapterNumber — Todos os versículos marcados como lidos!',
        ),
        backgroundColor: AppColors.gold.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressAsync = ref.watch(bibleProgressProvider);
    final progressState =
        progressAsync.value ?? const BibleProgressState();

    final readCount =
        progressState.readVersesInChapter(widget.book.abbrev, _chapterNumber);
    final totalVerses = _verses.length;
    final isChapterComplete =
        progressState.isChapterComplete(widget.book.abbrev, _chapterNumber, totalVerses);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF070A12) : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Hero(
              tag: 'book_title_${widget.book.abbrev}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  widget.book.name,
                  style: AppTypography.heading3.copyWith(fontSize: 20),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Capítulo $_chapterNumber',
                  style: AppTypography.caption.copyWith(color: AppColors.gold),
                ),
                if (readCount > 0) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isChapterComplete
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      isChapterComplete
                          ? '✓ Completo'
                          : '$readCount/$totalVerses',
                      style: AppTypography.caption.copyWith(
                        color: isChapterComplete
                            ? AppColors.success
                            : AppColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          // Mark all as read
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            onSelected: (value) {
              if (value == 'mark_all') _markAllAsRead();
              if (value == 'font') _showFontSizeSheet();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all',
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.checkCircle,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Marcar tudo como lido',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'font',
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.type,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tamanho da fonte',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        itemCount: _verses.length,
        itemBuilder: (context, index) {
          final verseText = _verses[index];
          final verseNumber = index + 1;
          final mark = progressState.verseMark(
            widget.book.abbrev,
            _chapterNumber,
            verseNumber,
          );

          final isRead = mark?.isRead ?? false;
          final highlightColor = mark?.highlightColor;
          final hasNote = mark?.note != null && mark!.note!.isNotEmpty;

          return GestureDetector(
            onTap: () => _showVerseActions(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: highlightColor != null
                    ? HighlightColors.toColor(
                        highlightColor,
                        opacity: isDark ? 0.12 : 0.15,
                      )
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: highlightColor != null
                    ? Border.all(
                        color: HighlightColors.toColor(
                          highlightColor,
                          opacity: 0.25,
                        ),
                      )
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verse content (expanded)
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bibleText.copyWith(
                          color: isDark
                              ? (isRead
                                  ? AppColors.darkTextPrimary
                                      .withValues(alpha: 0.7)
                                  : AppColors.darkTextPrimary)
                              : (isRead
                                  ? AppColors.lightTextPrimary
                                      .withValues(alpha: 0.7)
                                  : AppColors.lightTextPrimary),
                          fontSize: _fontSizeTheme,
                          height: 1.8,
                        ),
                        children: [
                          TextSpan(
                            text: '$verseNumber  ',
                            style: TextStyle(
                              color: isRead
                                  ? AppColors.success.withValues(alpha: 0.8)
                                  : AppColors.gold.withValues(alpha: 0.8),
                              fontSize: _fontSizeTheme * 0.75,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: verseText),
                        ],
                      ),
                    ),
                  ),

                  // Indicators
                  if (isRead || hasNote)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.sm,
                        top: 4,
                      ),
                      child: Column(
                        children: [
                          if (isRead)
                            Icon(
                              LucideIcons.check,
                              size: 14,
                              color:
                                  AppColors.success.withValues(alpha: 0.6),
                            ),
                          if (hasNote) ...[
                            if (isRead) const SizedBox(height: 4),
                            Icon(
                              LucideIcons.stickyNote,
                              size: 13,
                              color:
                                  AppColors.gold.withValues(alpha: 0.6),
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
      ),
    );
  }

  void _showFontSizeSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tamanho da Fonte', style: AppTypography.title),
            StatefulBuilder(builder: (context, setModalState) {
              return Slider(
                value: _fontSizeTheme,
                min: 14.0,
                max: 28.0,
                activeColor: AppColors.gold,
                inactiveColor: AppColors.gold.withValues(alpha: 0.2),
                onChanged: (val) {
                  setState(() => _fontSizeTheme = val);
                  setModalState(() => _fontSizeTheme = val);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
