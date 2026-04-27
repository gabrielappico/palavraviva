import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/bible_progress_repository.dart';
import 'models/verse_mark.dart';
import 'models/reading_plan.dart';
import '../../../core/services/gamification_service.dart';

// ── Repository provider ──
final bibleProgressRepoProvider = Provider<BibleProgressRepository>((ref) {
  return BibleProgressRepository(Supabase.instance.client);
});

// ── Main progress provider ──
final bibleProgressProvider =
    AsyncNotifierProvider<BibleProgressNotifier, BibleProgressState>(
  BibleProgressNotifier.new,
);

// ── Reading plan provider ──
final readingPlanProvider =
    AsyncNotifierProvider<ReadingPlanNotifier, ReadingPlan?>(
  ReadingPlanNotifier.new,
);

// ══════════════════════════════════════════════
// STATE
// ══════════════════════════════════════════════

class BibleProgressState {
  /// Nested map: bookAbbrev → chapter → verse → VerseMark
  final Map<String, Map<int, Map<int, VerseMark>>> marks;

  const BibleProgressState({this.marks = const {}});

  /// Get marks for a specific chapter.
  Map<int, VerseMark> chapterMarks(String bookAbbrev, int chapter) {
    return marks[bookAbbrev]?[chapter] ?? {};
  }

  /// Get a specific verse mark.
  VerseMark? verseMark(String bookAbbrev, int chapter, int verse) {
    return marks[bookAbbrev]?[chapter]?[verse];
  }

  /// Count read verses in a chapter.
  int readVersesInChapter(String bookAbbrev, int chapter) {
    final cm = chapterMarks(bookAbbrev, chapter);
    return cm.values.where((m) => m.isRead).length;
  }

  /// Check if at least one verse is read in a chapter.
  bool isChapterStarted(String bookAbbrev, int chapter) {
    return readVersesInChapter(bookAbbrev, chapter) > 0;
  }

  /// Check if all verses in a chapter are read.
  bool isChapterComplete(String bookAbbrev, int chapter, int totalVerses) {
    return readVersesInChapter(bookAbbrev, chapter) >= totalVerses;
  }

  /// Progress fraction for a chapter (0.0 to 1.0).
  double chapterProgress(String bookAbbrev, int chapter, int totalVerses) {
    if (totalVerses == 0) return 0.0;
    return readVersesInChapter(bookAbbrev, chapter) / totalVerses;
  }

  /// Count complete chapters in a book.
  int completedChaptersInBook(String bookAbbrev, List<List<String>> chapters) {
    int count = 0;
    for (int i = 0; i < chapters.length; i++) {
      if (isChapterComplete(bookAbbrev, i + 1, chapters[i].length)) {
        count++;
      }
    }
    return count;
  }

  /// Progress fraction for a book (0.0 to 1.0).
  double bookProgress(String bookAbbrev, List<List<String>> chapters) {
    if (chapters.isEmpty) return 0.0;
    return completedChaptersInBook(bookAbbrev, chapters) / chapters.length;
  }

  /// Whether at least one chapter in the book has any progress.
  bool isBookStarted(String bookAbbrev) {
    return marks[bookAbbrev]?.isNotEmpty ?? false;
  }

  /// Total verses read across all books.
  int get totalVersesRead {
    int count = 0;
    for (final book in marks.values) {
      for (final chapter in book.values) {
        count += chapter.values.where((m) => m.isRead).length;
      }
    }
    return count;
  }

  /// All notes across all books (for notes screen).
  List<VerseMark> get allNotes {
    final notes = <VerseMark>[];
    for (final book in marks.values) {
      for (final chapter in book.values) {
        notes.addAll(chapter.values.where((m) => m.note != null && m.note!.isNotEmpty));
      }
    }
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// All highlights across all books.
  List<VerseMark> get allHighlights {
    final highlights = <VerseMark>[];
    for (final book in marks.values) {
      for (final chapter in book.values) {
        highlights.addAll(chapter.values.where((m) => m.highlightColor != null));
      }
    }
    highlights.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return highlights;
  }

  /// Creates a new state with updated mark.
  BibleProgressState withMark(VerseMark mark) {
    final newMarks = Map<String, Map<int, Map<int, VerseMark>>>.from(marks);

    newMarks.putIfAbsent(mark.bookAbbrev, () => {});
    newMarks[mark.bookAbbrev]!.putIfAbsent(mark.chapter, () => {});
    newMarks[mark.bookAbbrev]![mark.chapter]![mark.verse] = mark;

    return BibleProgressState(marks: newMarks);
  }

  /// Creates a new state without a specific mark.
  BibleProgressState withoutMark(String bookAbbrev, int chapter, int verse) {
    final newMarks = Map<String, Map<int, Map<int, VerseMark>>>.from(marks);

    newMarks[bookAbbrev]?[chapter]?.remove(verse);
    if (newMarks[bookAbbrev]?[chapter]?.isEmpty ?? false) {
      newMarks[bookAbbrev]?.remove(chapter);
    }
    if (newMarks[bookAbbrev]?.isEmpty ?? false) {
      newMarks.remove(bookAbbrev);
    }

    return BibleProgressState(marks: newMarks);
  }
}

// ══════════════════════════════════════════════
// NOTIFIER
// ══════════════════════════════════════════════

class BibleProgressNotifier extends AsyncNotifier<BibleProgressState> {
  @override
  Future<BibleProgressState> build() async {
    final repo = ref.read(bibleProgressRepoProvider);
    final allMarks = await repo.fetchAllVerseMarks();
    return _buildState(allMarks);
  }

  BibleProgressState _buildState(List<VerseMark> allMarks) {
    final map = <String, Map<int, Map<int, VerseMark>>>{};

    for (final mark in allMarks) {
      map.putIfAbsent(mark.bookAbbrev, () => {});
      map[mark.bookAbbrev]!.putIfAbsent(mark.chapter, () => {});
      map[mark.bookAbbrev]![mark.chapter]![mark.verse] = mark;
    }

    return BibleProgressState(marks: map);
  }

  /// Toggle read status for a verse.
  Future<void> toggleRead({
    required String bookAbbrev,
    required int chapter,
    required int verse,
  }) async {
    final currentState = state.value ?? const BibleProgressState();
    final existing = currentState.verseMark(bookAbbrev, chapter, verse);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(bibleProgressRepoProvider);

    if (existing != null) {
      final updated = existing.copyWith(isRead: !existing.isRead);
      if (!updated.hasData) {
        state = AsyncData(currentState.withoutMark(bookAbbrev, chapter, verse));
        await repo.deleteVerseMark(updated);
      } else {
        state = AsyncData(currentState.withMark(updated));
        await repo.upsertVerseMark(updated);
      }
    } else {
      final mark = VerseMark.create(
        userId: userId,
        bookAbbrev: bookAbbrev,
        chapter: chapter,
        verse: verse,
        isRead: true,
      );
      state = AsyncData(currentState.withMark(mark));
      await repo.upsertVerseMark(mark);
    }
  }

  /// Set highlight color for a verse.
  Future<void> setHighlight({
    required String bookAbbrev,
    required int chapter,
    required int verse,
    required String? color,
  }) async {
    final currentState = state.value ?? const BibleProgressState();
    final existing = currentState.verseMark(bookAbbrev, chapter, verse);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(bibleProgressRepoProvider);

    if (existing != null) {
      final updated = color == null
          ? existing.copyWith(clearHighlight: true)
          : existing.copyWith(highlightColor: color, isRead: true);
      if (!updated.hasData) {
        state = AsyncData(currentState.withoutMark(bookAbbrev, chapter, verse));
        await repo.deleteVerseMark(updated);
      } else {
        state = AsyncData(currentState.withMark(updated));
        await repo.upsertVerseMark(updated);
      }
    } else if (color != null) {
      final mark = VerseMark.create(
        userId: userId,
        bookAbbrev: bookAbbrev,
        chapter: chapter,
        verse: verse,
        highlightColor: color,
        isRead: true,
      );
      state = AsyncData(currentState.withMark(mark));
      await repo.upsertVerseMark(mark);
    }
  }

  /// Set/update note for a verse.
  Future<void> setNote({
    required String bookAbbrev,
    required int chapter,
    required int verse,
    required String? noteText,
  }) async {
    final currentState = state.value ?? const BibleProgressState();
    final existing = currentState.verseMark(bookAbbrev, chapter, verse);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(bibleProgressRepoProvider);

    final effectiveNote = (noteText?.trim().isEmpty ?? true) ? null : noteText!.trim();

    if (existing != null) {
      final updated = effectiveNote == null
          ? existing.copyWith(clearNote: true)
          : existing.copyWith(note: effectiveNote);
      if (!updated.hasData) {
        state = AsyncData(currentState.withoutMark(bookAbbrev, chapter, verse));
        await repo.deleteVerseMark(updated);
      } else {
        state = AsyncData(currentState.withMark(updated));
        await repo.upsertVerseMark(updated);
      }
    } else if (effectiveNote != null) {
      final mark = VerseMark.create(
        userId: userId,
        bookAbbrev: bookAbbrev,
        chapter: chapter,
        verse: verse,
        note: effectiveNote,
      );
      state = AsyncData(currentState.withMark(mark));
      await repo.upsertVerseMark(mark);
    }
  }

  /// Mark all verses in a chapter as read.
  Future<void> markChapterAsRead({
    required String bookAbbrev,
    required int chapter,
    required int totalVerses,
  }) async {
    final currentState = state.value ?? const BibleProgressState();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(bibleProgressRepoProvider);
    final existingMarks = currentState.chapterMarks(bookAbbrev, chapter);

    final savedMarks = await repo.markChapterAsRead(
      bookAbbrev: bookAbbrev,
      chapter: chapter,
      totalVerses: totalVerses,
      existingMarks: existingMarks,
    );

    var newState = currentState;
    for (final mark in savedMarks) {
      newState = newState.withMark(mark);
    }
    state = AsyncData(newState);

    // Track activity for streak + 50 XP for chapter read
    try {
      await GamificationService().logChapterRead();
    } catch (_) {}
  }
}

// ══════════════════════════════════════════════
// READING PLAN NOTIFIER
// ══════════════════════════════════════════════

class ReadingPlanNotifier extends AsyncNotifier<ReadingPlan?> {
  @override
  Future<ReadingPlan?> build() async {
    final repo = ref.read(bibleProgressRepoProvider);
    return repo.fetchActivePlan();
  }

  Future<void> createPlan({
    required String title,
    required DateTime targetDate,
    int chaptersAtStart = 0,
  }) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final repo = ref.read(bibleProgressRepoProvider);
    final plan = ReadingPlan.create(
      userId: userId,
      title: title,
      targetDate: targetDate,
      chaptersAtStart: chaptersAtStart,
    );

    final saved = await repo.createPlan(plan);
    state = AsyncData(saved);
  }

  Future<void> deactivatePlan() async {
    final current = state.value;
    if (current == null) return;

    final repo = ref.read(bibleProgressRepoProvider);
    await repo.deactivatePlan(current.id);
    state = const AsyncData(null);
  }
}
