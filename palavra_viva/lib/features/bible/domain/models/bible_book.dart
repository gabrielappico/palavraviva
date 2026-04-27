class BibleBook {
  final String abbrev;
  final String name;
  final List<List<String>> chapters;

  BibleBook({
    required this.abbrev,
    required this.name,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      abbrev: json['abbrev'] as String,
      name: json['name'] as String,
      chapters: (json['chapters'] as List)
          .map((chapter) => List<String>.from(chapter))
          .toList(),
    );
  }
}
