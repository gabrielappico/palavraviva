import 'dart:convert';
import 'dart:io';

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

void main() {
  try {
    final file = File('assets/data/pt_nvi.json');
    if (!file.existsSync()) {
      print('Arquivo não existe!');
      return;
    }
    final jsonString = file.readAsStringSync();
    final List<dynamic> jsonList = json.decode(jsonString);
    final books = jsonList.map((j) => BibleBook.fromJson(j)).toList();
    print('Livros carregados: \${books.length}');
    
    // Test the specific verse logic
    final refAbbrev = 'jo';
    final refChapter = 3;
    final startVerse = 16;
    
    final book = books.firstWhere((b) => b.abbrev == refAbbrev, orElse: () => throw Exception('Book not found'));
    print('Encontrou livro: \${book.name}');
    final chapterText = book.chapters[refChapter - 1];
    print('Versículo 16: \${chapterText[startVerse - 1]}');
    
  } catch (e, stack) {
    print('Erro: \$e');
    print(stack);
  }
}
