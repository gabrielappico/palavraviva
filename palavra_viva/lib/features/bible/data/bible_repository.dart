import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/bible_book.dart';

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepository();
});

final allBibleProvider = FutureProvider<List<BibleBook>>((ref) async {
  final repo = ref.read(bibleRepositoryProvider);
  await repo.loadBible();
  return repo.books;
});

class BibleRepository {
  List<BibleBook>? _books;

  Future<void> loadBible() async {
    if (_books != null) return;
    
    try {
      print('Iniciando leitura do arquivo JSON...');
      final String jsonString = await rootBundle.loadString('assets/data/pt_nvi.json', cache: false);
      print('Arquivo lido. Bytes: ${jsonString.length}. Fazendo parse...');
      
      final List<dynamic> jsonList = json.decode(jsonString);
      print('Parse concluído. Mapeando para os modelos...');
      
      _books = jsonList.map((json) => BibleBook.fromJson(json)).toList();
      print('Bíblia totalmente carregada com sucesso!');
    } catch (e, stack) {
      print('Erro ao carregar a Bíblia: $e');
      throw Exception('Falha ao carregar Bíblia: $e\n$stack');
    }
  }

  List<BibleBook> get books => _books ?? [];

  BibleBook? getBookByAbbrev(String abbrev) {
    if (_books == null) return null;
    try {
      return _books!.firstWhere((book) => book.abbrev == abbrev);
    } catch (e) {
      return null;
    }
  }
}
