import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/journal_entry.dart';

final journalProvider = NotifierProvider<JournalNotifier, JournalState>(JournalNotifier.new);

class JournalState {
  final List<JournalEntry> entries;

  const JournalState({this.entries = const []});

  JournalState copyWith({
    List<JournalEntry>? entries,
  }) {
    return JournalState(
      entries: entries ?? this.entries,
    );
  }
}

class JournalNotifier extends Notifier<JournalState> {
  static const _boxName = 'journalBox';

  @override
  JournalState build() {
    // Como abrimos o box no main(), podemos ler sincronicamente!
    final box = Hive.box(_boxName);
    
    // Converte os valores do Box (que estão em JSON/Map dinâmico) de volta para Modelo
    final List<JournalEntry> loaded = box.values.whereType<Map>().map((dynamic map) {
      return JournalEntry.fromJson(map as Map<dynamic, dynamic>);
    }).toList();

    // Ordem cronológica decrescente (mais novos no topo)
    loaded.sort((a, b) => b.date.compareTo(a.date));

    return JournalState(entries: loaded);
  }

  Future<void> addEntry(String title, String content) async {
    if (title.trim().isEmpty && content.trim().isEmpty) return;
    
    final newEntry = JournalEntry.create(title: title, content: content);
    
    // Salva no banco de dados local
    final box = Hive.box(_boxName);
    await box.add(newEntry.toJson());

    // Atualiza a View de forma reativa
    state = state.copyWith(
      entries: [newEntry, ...state.entries],
    );
  }

  Future<void> removeEntry(String id) async {
    final box = Hive.box(_boxName);
    
    // Em boxes não-tipados como Box<dynamic>, precisamos achar a key localizando o ID
    int? keyToDelete;
    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map && value['id'] == id) {
        keyToDelete = key;
        break;
      }
    }

    if (keyToDelete != null) {
      await box.delete(keyToDelete);
    }

    state = state.copyWith(
      entries: state.entries.where((e) => e.id != id).toList(),
    );
  }
}
