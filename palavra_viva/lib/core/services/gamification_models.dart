/// Represents a user's gamification stats (XP, streak, rank)
class UserStats {
  final String userId;
  final String displayName;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;
  final bool streakFreezeAvailable;
  final int quizzesPlayed;
  final int quizzesPerfect;
  final int totalCorrectAnswers;
  final int totalQuestionsAnswered;
  final int freeLives;

  const UserStats({
    required this.userId,
    this.displayName = 'Discípulo',
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
    this.streakFreezeAvailable = false,
    this.quizzesPlayed = 0,
    this.quizzesPerfect = 0,
    this.totalCorrectAnswers = 0,
    this.totalQuestionsAnswered = 0,
    this.freeLives = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['user_id'] ?? '',
      displayName: json['display_name'] ?? 'Discípulo',
      totalXp: json['total_xp'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.tryParse(json['last_active_date'])
          : null,
      streakFreezeAvailable: json['streak_freeze_available'] ?? false,
      quizzesPlayed: json['quizzes_played'] ?? 0,
      quizzesPerfect: json['quizzes_perfect'] ?? 0,
      totalCorrectAnswers: json['total_correct_answers'] ?? 0,
      totalQuestionsAnswered: json['total_questions_answered'] ?? 0,
      freeLives: json['free_lives'] ?? 0,
    );
  }

  // ══════════════════════════════════════════════
  // 33-LEVEL SYSTEM
  // XP curve: level N requires N*(N-1)*20 cumulative XP
  // Level 33 = 21,120 XP total (age of Jesus)
  // ══════════════════════════════════════════════

  static const int maxLevel = 33;

  /// Cumulative XP required for a given level (1-indexed)
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    if (level > maxLevel) return xpForLevel(maxLevel);
    return level * (level - 1) * 20;
  }

  /// Current level derived from total XP (1 to 33)
  int get level {
    for (int lvl = maxLevel; lvl >= 1; lvl--) {
      if (totalXp >= xpForLevel(lvl)) return lvl;
    }
    return 1;
  }

  /// XP threshold for the current level
  int get xpForCurrentLevel => xpForLevel(level);

  /// XP threshold for the next level
  int get xpForNextLevel => xpForLevel((level + 1).clamp(1, maxLevel));

  /// Progress fraction within the current level (0.0 to 1.0)
  double get levelProgress {
    if (level >= maxLevel) return 1.0;
    final current = xpForCurrentLevel;
    final next = xpForNextLevel;
    if (next == current) return 1.0;
    return (totalXp - current) / (next - current);
  }

  /// Spiritual title based on level range
  String get title {
    if (level >= 31) return 'Teólogo';
    if (level >= 26) return 'Apóstolo';
    if (level >= 21) return 'Profeta';
    if (level >= 16) return 'Sacerdote';
    if (level >= 11) return 'Levita';
    if (level >= 6) return 'Discípulo';
    return 'Ovelha';
  }

  /// Emoji for current title
  String get titleEmoji {
    if (level >= 31) return '📜';
    if (level >= 26) return '✝️';
    if (level >= 21) return '🔮';
    if (level >= 16) return '⛪';
    if (level >= 11) return '🕯️';
    if (level >= 6) return '🙏';
    return '🐑';
  }

  /// Streak multiplier based on current streak
  double get streakMultiplier {
    if (currentStreak >= 30) return 3.0;
    if (currentStreak >= 14) return 2.5;
    if (currentStreak >= 7) return 2.0;
    if (currentStreak >= 3) return 1.5;
    return 1.0;
  }

  /// Accuracy percentage
  double get accuracy {
    if (totalQuestionsAnswered == 0) return 0;
    return totalCorrectAnswers / totalQuestionsAnswered * 100;
  }
}

/// Represents a leaderboard entry
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int totalXp;
  final int currentStreak;
  final int weeklyXp;
  final int weeklyQuizzes;
  final int weeklyCorrect;
  final int weeklyTotal;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.totalXp = 0,
    this.currentStreak = 0,
    this.weeklyXp = 0,
    this.weeklyQuizzes = 0,
    this.weeklyCorrect = 0,
    this.weeklyTotal = 0,
    this.rank = 0,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank) {
    return LeaderboardEntry(
      userId: json['user_id'] ?? '',
      displayName: json['display_name'] ?? 'Discípulo',
      totalXp: json['total_xp'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      weeklyXp: json['weekly_xp'] ?? 0,
      weeklyQuizzes: json['weekly_quizzes'] ?? 0,
      weeklyCorrect: json['weekly_correct'] ?? 0,
      weeklyTotal: json['weekly_total'] ?? 0,
      rank: rank,
    );
  }

  /// Level derived from total XP (same formula as UserStats)
  int get level {
    for (int lvl = UserStats.maxLevel; lvl >= 1; lvl--) {
      if (totalXp >= UserStats.xpForLevel(lvl)) return lvl;
    }
    return 1;
  }

  /// Title based on level (same logic as UserStats)
  String get title {
    if (level >= 31) return 'Teólogo';
    if (level >= 26) return 'Apóstolo';
    if (level >= 21) return 'Profeta';
    if (level >= 16) return 'Sacerdote';
    if (level >= 11) return 'Levita';
    if (level >= 6) return 'Discípulo';
    return 'Ovelha';
  }
}

/// Quiz result returned from database after recording a score
class QuizResult {
  final int xpEarned;
  final int newStreak;
  final int newTotalXp;
  final bool earnedFreeLife;

  const QuizResult({
    required this.xpEarned,
    required this.newStreak,
    required this.newTotalXp,
    this.earnedFreeLife = false,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      xpEarned: json['xp_earned'] ?? 0,
      newStreak: json['new_streak'] ?? 0,
      newTotalXp: json['new_total_xp'] ?? 0,
      earnedFreeLife: json['earned_free_life'] ?? false,
    );
  }
}
