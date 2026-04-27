import 'package:supabase_flutter/supabase_flutter.dart';
import 'gamification_models.dart';

/// Service that handles all gamification operations via Supabase
class GamificationService {
  final SupabaseClient _client;

  GamificationService() : _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Get current user's stats. Creates initial record if needed.
  Future<UserStats> getUserStats() async {
    if (_userId == null) return const UserStats(userId: '');

    final response = await _client
        .from('user_stats')
        .select()
        .eq('user_id', _userId!)
        .maybeSingle();

    if (response == null) {
      // Create initial stats
      final name = _client.auth.currentUser?.userMetadata?['name'] ?? 'Discípulo';
      await _client.from('user_stats').insert({
        'user_id': _userId,
        'display_name': name,
      });
      return UserStats(userId: _userId!, displayName: name);
    }

    return UserStats.fromJson(response);
  }

  /// Record a quiz score and get back XP earned + updated stats
  Future<QuizResult> recordQuizScore({
    required String difficulty,
    required String category,
    required String gameMode,
    required int score,
    required int totalQuestions,
    int? timeSpentSeconds,
  }) async {
    if (_userId == null) {
      return const QuizResult(xpEarned: 0, newStreak: 0, newTotalXp: 0);
    }

    final response = await _client.rpc('record_quiz_score', params: {
      'p_user_id': _userId,
      'p_difficulty': difficulty,
      'p_category': category,
      'p_game_mode': gameMode,
      'p_score': score,
      'p_total_questions': totalQuestions,
      'p_time_spent': timeSpentSeconds,
    });

    if (response is List && response.isNotEmpty) {
      return QuizResult.fromJson(response[0]);
    }
    return const QuizResult(xpEarned: 0, newStreak: 0, newTotalXp: 0);
  }

  /// Log a non-quiz activity (bible reading, prayer, journal, etc.)
  Future<void> logActivity(String activityType, {int xp = 5}) async {
    if (_userId == null) return;

    await _client.rpc('update_user_streak', params: {
      'p_user_id': _userId,
      'p_xp': xp,
      'p_activity_type': activityType,
    });
  }

  /// Get the weekly leaderboard (top 50)
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    final response = await _client
        .from('weekly_leaderboard')
        .select()
        .order('weekly_xp', ascending: false)
        .limit(50);

    return (response as List)
        .asMap()
        .entries
        .map((e) => LeaderboardEntry.fromJson(e.value, e.key + 1))
        .toList();
  }

  /// Get all-time top players
  Future<List<UserStats>> getAllTimeLeaderboard() async {
    final response = await _client
        .from('user_stats')
        .select()
        .order('total_xp', ascending: false)
        .limit(50);

    return (response as List).map((e) => UserStats.fromJson(e)).toList();
  }

  /// Get current user's rank
  Future<int> getUserRank() async {
    if (_userId == null) return 0;

    final stats = await getUserStats();
    final response = await _client
        .from('user_stats')
        .select('user_id')
        .gte('total_xp', stats.totalXp);

    return (response as List).length;
  }

  /// Check if streak is at risk (last active was yesterday)
  Future<bool> isStreakAtRisk() async {
    final stats = await getUserStats();
    if (stats.lastActiveDate == null || stats.currentStreak == 0) return false;

    final today = DateTime.now();
    final lastActive = stats.lastActiveDate!;
    final diff = DateTime(today.year, today.month, today.day)
        .difference(DateTime(lastActive.year, lastActive.month, lastActive.day))
        .inDays;

    return diff == 1; // Yesterday = at risk, >1 = already lost
  }

  /// Update display name
  Future<void> updateDisplayName(String name) async {
    if (_userId == null) return;
    await _client
        .from('user_stats')
        .update({'display_name': name})
        .eq('user_id', _userId!);
  }

  /// Grant a free life for a perfect quiz round
  Future<void> grantFreeLife() async {
    if (_userId == null) return;
    await _client.rpc('increment_free_lives', params: {
      'p_user_id': _userId,
    });
  }

  /// Consume a free life (returns true if consumed, false if no lives)
  Future<bool> consumeFreeLife() async {
    if (_userId == null) return false;
    final stats = await getUserStats();
    if (stats.freeLives <= 0) return false;

    await _client
        .from('user_stats')
        .update({'free_lives': stats.freeLives - 1})
        .eq('user_id', _userId!);
    return true;
  }

  /// Log chapter reading activity with 50 XP
  Future<void> logChapterRead() async {
    await logActivity('bible_chapter', xp: 50);
  }
}
