import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserInsights {
  final String mostReadBook;
  final int mostReadCount;
  final int chaptersRead;
  final int booksStarted;
  final int prayersMonth;
  final int journalsMonth;
  final int quizzesMonth;
  final double quizAccuracy;
  final String favoriteCategory;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final int daysActive;
  final int totalActivities;

  const UserInsights({
    this.mostReadBook = '',
    this.mostReadCount = 0,
    this.chaptersRead = 0,
    this.booksStarted = 0,
    this.prayersMonth = 0,
    this.journalsMonth = 0,
    this.quizzesMonth = 0,
    this.quizAccuracy = 0,
    this.favoriteCategory = '',
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.daysActive = 0,
    this.totalActivities = 0,
  });

  factory UserInsights.fromJson(Map<String, dynamic> json) {
    return UserInsights(
      mostReadBook: json['most_read_book'] ?? '',
      mostReadCount: json['most_read_count'] ?? 0,
      chaptersRead: json['chapters_read'] ?? 0,
      booksStarted: json['books_started'] ?? 0,
      prayersMonth: json['prayers_month'] ?? 0,
      journalsMonth: json['journals_month'] ?? 0,
      quizzesMonth: json['quizzes_month'] ?? 0,
      quizAccuracy: (json['quiz_accuracy'] ?? 0).toDouble(),
      favoriteCategory: json['favorite_category'] ?? '',
      totalXp: json['total_xp'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      daysActive: json['days_active'] ?? 0,
      totalActivities: json['total_activities'] ?? 0,
    );
  }

  /// Map of book abbreviations to full names
  static const bookNames = {
    'gn': 'Gênesis', 'ex': 'Êxodo', 'lv': 'Levítico', 'nm': 'Números',
    'dt': 'Deuteronômio', 'js': 'Josué', 'jz': 'Juízes', 'rt': 'Rute',
    '1sm': '1 Samuel', '2sm': '2 Samuel', '1rs': '1 Reis', '2rs': '2 Reis',
    '1cr': '1 Crônicas', '2cr': '2 Crônicas', 'ed': 'Esdras', 'ne': 'Neemias',
    'et': 'Ester', 'jó': 'Jó', 'sl': 'Salmos', 'pv': 'Provérbios',
    'ec': 'Eclesiastes', 'ct': 'Cânticos', 'is': 'Isaías', 'jr': 'Jeremias',
    'lm': 'Lamentações', 'ez': 'Ezequiel', 'dn': 'Daniel', 'os': 'Oseias',
    'jl': 'Joel', 'am': 'Amós', 'ob': 'Obadias', 'jn': 'Jonas',
    'mq': 'Miqueias', 'na': 'Naum', 'hc': 'Habacuque', 'sf': 'Sofonias',
    'ag': 'Ageu', 'zc': 'Zacarias', 'ml': 'Malaquias',
    'mt': 'Mateus', 'mc': 'Marcos', 'lc': 'Lucas', 'jo': 'João',
    'at': 'Atos', 'rm': 'Romanos', '1co': '1 Coríntios', '2co': '2 Coríntios',
    'gl': 'Gálatas', 'ef': 'Efésios', 'fp': 'Filipenses', 'cl': 'Colossenses',
    '1ts': '1 Tessalonicenses', '2ts': '2 Tessalonicenses',
    '1tm': '1 Timóteo', '2tm': '2 Timóteo', 'tt': 'Tito', 'fm': 'Filemom',
    'hb': 'Hebreus', 'tg': 'Tiago', '1pe': '1 Pedro', '2pe': '2 Pedro',
    '1jo': '1 João', '2jo': '2 João', '3jo': '3 João', 'jd': 'Judas',
    'ap': 'Apocalipse',
  };

  String get mostReadBookName =>
      bookNames[mostReadBook.toLowerCase()] ?? mostReadBook;

  static const categoryNames = {
    'geral': 'Geral',
    'antigo_testamento': 'Antigo Testamento',
    'novo_testamento': 'Novo Testamento',
    'reis_profetas': 'Reis & Profetas',
    'parabolas': 'Parábolas de Jesus',
    'geografia': 'Geografia Bíblica',
    'profecias': 'Profecias',
    'proverbios': 'Provérbios & Sabedoria',
    'quem_disse': 'Quem disse?',
    'familias': 'Famílias da Bíblia',
    'numeros': 'Números na Bíblia',
    'batalhas': 'Batalhas Bíblicas',
  };

  String get favoriteCategoryName =>
      categoryNames[favoriteCategory] ?? favoriteCategory;
}

final userInsightsProvider = FutureProvider.autoDispose<UserInsights>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return const UserInsights();

  final response = await Supabase.instance.client.rpc(
    'get_user_insights',
    params: {'p_user_id': userId},
  );

  if (response is Map<String, dynamic>) {
    return UserInsights.fromJson(response);
  }
  return const UserInsights();
});
