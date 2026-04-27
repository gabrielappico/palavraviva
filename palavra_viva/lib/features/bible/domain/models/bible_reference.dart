class BibleReference {
  final String abbrev; // e.g. "sl"
  final int chapter; // 1-based index
  final int startVerse; // 1-based index
  final int? endVerse; // 1-based index, nullable if only one verse

  const BibleReference({
    required this.abbrev,
    required this.chapter,
    required this.startVerse,
    this.endVerse,
  });
}
