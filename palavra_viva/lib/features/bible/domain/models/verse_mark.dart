import 'package:uuid/uuid.dart';

class VerseMark {
  final String id;
  final String userId;
  final String bookAbbrev;
  final int chapter;
  final int verse;
  final bool isRead;
  final String? highlightColor;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VerseMark({
    required this.id,
    required this.userId,
    required this.bookAbbrev,
    required this.chapter,
    required this.verse,
    this.isRead = false,
    this.highlightColor,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VerseMark.create({
    required String userId,
    required String bookAbbrev,
    required int chapter,
    required int verse,
    bool isRead = false,
    String? highlightColor,
    String? note,
  }) {
    final now = DateTime.now();
    return VerseMark(
      id: const Uuid().v4(),
      userId: userId,
      bookAbbrev: bookAbbrev,
      chapter: chapter,
      verse: verse,
      isRead: isRead,
      highlightColor: highlightColor,
      note: note,
      createdAt: now,
      updatedAt: now,
    );
  }

  VerseMark copyWith({
    bool? isRead,
    String? highlightColor,
    String? note,
    bool clearHighlight = false,
    bool clearNote = false,
  }) {
    return VerseMark(
      id: id,
      userId: userId,
      bookAbbrev: bookAbbrev,
      chapter: chapter,
      verse: verse,
      isRead: isRead ?? this.isRead,
      highlightColor: clearHighlight ? null : (highlightColor ?? this.highlightColor),
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Whether this mark has any meaningful data worth keeping.
  bool get hasData => isRead || highlightColor != null || note != null;

  /// Unique key for local cache lookup.
  String get cacheKey => '$bookAbbrev:$chapter:$verse';

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'book_abbrev': bookAbbrev,
    'chapter': chapter,
    'verse': verse,
    'is_read': isRead,
    'highlight_color': highlightColor,
    'note': note,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory VerseMark.fromJson(Map<String, dynamic> json) => VerseMark(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    bookAbbrev: json['book_abbrev'] as String,
    chapter: json['chapter'] as int,
    verse: json['verse'] as int,
    isRead: json['is_read'] as bool? ?? false,
    highlightColor: json['highlight_color'] as String?,
    note: json['note'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}
