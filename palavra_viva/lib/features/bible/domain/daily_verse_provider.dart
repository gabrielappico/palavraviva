import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/bible_reference.dart';
import '../data/bible_repository.dart';

final dailyVerseProvider = FutureProvider<DailyVerse?>((ref) async {
  final biblesRepo = ref.read(bibleRepositoryProvider);
  await biblesRepo.loadBible();

  const verses = [
    BibleReference(abbrev: 'jo', chapter: 3, startVerse: 16, endVerse: 16),
    BibleReference(abbrev: 'sl', chapter: 23, startVerse: 1, endVerse: 1),
    BibleReference(abbrev: 'rm', chapter: 8, startVerse: 28, endVerse: 28),
    BibleReference(abbrev: 'fp', chapter: 4, startVerse: 13, endVerse: 13),
    BibleReference(abbrev: 'pv', chapter: 3, startVerse: 5, endVerse: 6),
    BibleReference(abbrev: 'is', chapter: 41, startVerse: 10, endVerse: 10),
    BibleReference(abbrev: 'jr', chapter: 29, startVerse: 11, endVerse: 11),
    BibleReference(abbrev: 'sl', chapter: 46, startVerse: 1, endVerse: 1),
    BibleReference(abbrev: 'mt', chapter: 11, startVerse: 28, endVerse: 28),
    BibleReference(abbrev: 'jo', chapter: 14, startVerse: 6, endVerse: 6),
    BibleReference(abbrev: 'sl', chapter: 119, startVerse: 105, endVerse: 105),
    BibleReference(abbrev: 'rm', chapter: 12, startVerse: 2, endVerse: 2),
    BibleReference(abbrev: '1co', chapter: 13, startVerse: 4, endVerse: 7),
    BibleReference(abbrev: 'ef', chapter: 2, startVerse: 8, endVerse: 9),
    BibleReference(abbrev: '2co', chapter: 5, startVerse: 17, endVerse: 17),
    BibleReference(abbrev: 'gl', chapter: 5, startVerse: 22, endVerse: 23),
    BibleReference(abbrev: 'cl', chapter: 3, startVerse: 14, endVerse: 14),
    BibleReference(abbrev: 'ts', chapter: 5, startVerse: 16, endVerse: 18),
    BibleReference(abbrev: 'tm', chapter: 1, startVerse: 7, endVerse: 7),
    BibleReference(abbrev: 'hb', chapter: 11, startVerse: 1, endVerse: 1),
  ];

  final now = DateTime.now();

  // Deterministic seed based on date
  int seed = now.year * 1000 + now.month * 100 + now.day;
  int index = seed % verses.length;

  final refItem = verses[index];

  final book = biblesRepo.getBookByAbbrev(refItem.abbrev);
  if (book == null)
    throw Exception('Livro não encontrado para abbrev: ${refItem.abbrev}');

  final chapterText = book.chapters[refItem.chapter - 1];

  String verseText = '';
  if (refItem.endVerse != null && refItem.endVerse! > refItem.startVerse) {
    for (int i = refItem.startVerse; i <= refItem.endVerse!; i++) {
      verseText += '${chapterText[i - 1]} ';
    }
  } else {
    verseText = chapterText[refItem.startVerse - 1];
  }

  // Determine background image (1 to 4) dynamically
  final int bgIndex = (seed % 4) + 1;
  final bgAsset = 'assets/images/verse_bg_$bgIndex.png';

  final referenceText =
      '${book.name} ${refItem.chapter}:${refItem.startVerse}${refItem.endVerse != null && refItem.endVerse != refItem.startVerse ? '-${refItem.endVerse}' : ''}';

  return DailyVerse(
    text: verseText.trim(),
    reference: referenceText,
    bgAsset: bgAsset,
  );
});

class DailyVerse {
  final String text;
  final String reference;
  final String bgAsset;

  DailyVerse({
    required this.text,
    required this.reference,
    required this.bgAsset,
  });
}
