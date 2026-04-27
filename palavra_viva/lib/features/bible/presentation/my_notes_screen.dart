import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/models/bible_book.dart';
import '../data/bible_repository.dart';
import '../domain/bible_progress_provider.dart';
import '../domain/models/highlight_colors.dart';
import '../domain/models/verse_mark.dart';
import 'reading_screen.dart';

class MyNotesScreen extends ConsumerStatefulWidget {
  const MyNotesScreen({super.key});
  @override ConsumerState<MyNotesScreen> createState() => _MyNotesScreenState();
}

class _MyNotesScreenState extends ConsumerState<MyNotesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  @override void initState() { super.initState(); _tabCtrl = TabController(length: 2, vsync: this); }
  @override void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressState = ref.watch(bibleProgressProvider).value ?? const BibleProgressState();
    final books = ref.watch(allBibleProvider).value ?? [];

    final notes = progressState.allNotes;
    final highlights = progressState.allHighlights;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Minhas Anotações'),
        backgroundColor: Colors.transparent, elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          tabs: [
            Tab(text: 'Notas (${notes.length})'),
            Tab(text: 'Destaques (${highlights.length})'),
          ],
        ),
      ),
      body: TabBarView(controller: _tabCtrl, children: [
        _MarksList(marks: notes, books: books, type: _ListType.notes, isDark: isDark),
        _MarksList(marks: highlights, books: books, type: _ListType.highlights, isDark: isDark),
      ]),
    );
  }
}

enum _ListType { notes, highlights }

class _MarksList extends StatelessWidget {
  const _MarksList({required this.marks, required this.books, required this.type, required this.isDark});
  final List<VerseMark> marks;
  final List<BibleBook> books;
  final _ListType type;
  final bool isDark;

  BibleBook? _findBook(String abbrev) {
    try { return books.firstWhere((b) => b.abbrev == abbrev); } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    if (marks.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(type == _ListType.notes ? LucideIcons.penTool : LucideIcons.highlighter, size: 48, color: AppColors.gold.withValues(alpha: 0.3)),
        const SizedBox(height: AppSpacing.lg),
        Text(type == _ListType.notes ? 'Nenhuma anotação ainda' : 'Nenhum destaque ainda', style: AppTypography.body.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Text('Toque em um versículo para começar', style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled)),
      ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: marks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final mark = marks[index];
        final book = _findBook(mark.bookAbbrev);
        final bookName = book?.name ?? mark.bookAbbrev;
        final ref = '$bookName ${mark.chapter}:${mark.verse}';

        // Try to get verse text
        String? verseText;
        if (book != null && mark.chapter <= book.chapters.length) {
          final ch = book.chapters[mark.chapter - 1];
          if (mark.verse <= ch.length) verseText = ch[mark.verse - 1];
        }

        return GestureDetector(
          onTap: () {
            if (book != null) {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (_) => ReadingScreen(book: book, chapterIndex: mark.chapter - 1),
              ));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: mark.highlightColor != null
                  ? Border.all(color: HighlightColors.toColor(mark.highlightColor, opacity: 0.4))
                  : Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Reference header
              Row(children: [
                if (mark.highlightColor != null)
                  Container(width: 10, height: 10, margin: const EdgeInsets.only(right: AppSpacing.sm), decoration: BoxDecoration(color: HighlightColors.toColor(mark.highlightColor), shape: BoxShape.circle)),
                Text(ref, style: AppTypography.label.copyWith(color: AppColors.gold)),
                const Spacer(),
                Text(_formatDate(mark.updatedAt), style: AppTypography.caption.copyWith(color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled, fontSize: 10)),
              ]),
              // Verse text
              if (verseText != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text('"$verseText"', maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.bibleVerse.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary, fontStyle: FontStyle.italic, fontSize: 13)),
              ],
              // Note
              if (type == _ListType.notes && mark.note != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: isDark ? AppColors.darkBackground : AppColors.lightBackground, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                  child: Text(mark.note!, style: AppTypography.bodySmall.copyWith(color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary), maxLines: 4, overflow: TextOverflow.ellipsis),
                ),
              ],
            ]),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
