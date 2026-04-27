import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gamification_service.dart';
import '../services/gamification_models.dart';

final gamificationServiceProvider = Provider<GamificationService>((ref) {
  return GamificationService();
});

/// Current user stats (auto-refreshes)
final userStatsProvider = FutureProvider.autoDispose<UserStats>((ref) async {
  final service = ref.read(gamificationServiceProvider);
  return service.getUserStats();
});

/// Weekly leaderboard
final weeklyLeaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) async {
  final service = ref.read(gamificationServiceProvider);
  return service.getWeeklyLeaderboard();
});

/// All-time leaderboard
final allTimeLeaderboardProvider =
    FutureProvider.autoDispose<List<UserStats>>((ref) async {
  final service = ref.read(gamificationServiceProvider);
  return service.getAllTimeLeaderboard();
});

/// User rank
final userRankProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.read(gamificationServiceProvider);
  return service.getUserRank();
});

/// Streak at risk check
final streakAtRiskProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.read(gamificationServiceProvider);
  return service.isStreakAtRisk();
});
