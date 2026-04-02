import 'package:uuid/uuid.dart';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  /// Factory factory para instanciar rapidamente uma nota nova com ID imutável e timestamp exato.
  factory JournalEntry.create({
    required String title,
    required String content,
  }) {
    return JournalEntry(
      id: const Uuid().v4(), // Identificador univesal único do registro.
      title: title,
      content: content,
      date: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'date': date.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<dynamic, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}
