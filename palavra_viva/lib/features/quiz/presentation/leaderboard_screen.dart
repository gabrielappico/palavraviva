import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/gamification_provider.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
        title: Text('🏆 Ranking', style: AppTypography.heading3.copyWith(color: AppColors.gold)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          tabs: const [Tab(text: 'Semanal'), Tab(text: 'Geral')],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildUserCard(isDark),
            _buildStatsRow(isDark),
            _buildPositionIndicator(isDark, currentUserId),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWeeklyTab(isDark, currentUserId),
                  _buildAllTimeTab(isDark, currentUserId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // USER CARD with level progress bar
  // ══════════════════════════════════════════════

  Widget _buildUserCard(bool isDark) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ref.watch(userStatsProvider).when(
      data: (stats) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.1),
              ),
              child: Center(child: Text(stats.titleEmoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stats.displayName,
                      style: AppTypography.title.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
                  const SizedBox(height: 2),
                  Text('Nv. ${stats.level} · ${stats.title} · ${stats.totalXp} XP',
                      style: AppTypography.caption.copyWith(color: AppColors.gold, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: stats.levelProgress,
                            backgroundColor: surface2,
                            valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${stats.totalXp} / ${stats.xpForNextLevel} XP',
                          style: AppTypography.caption.copyWith(color: subColor, fontSize: 9, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('🕊️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text('${stats.currentStreak}',
                    style: AppTypography.label.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold)),
              ]),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: -0.1),
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ══════════════════════════════════════════════
  // STATS ROW (3 chips)
  // ══════════════════════════════════════════════

  Widget _buildStatsRow(bool isDark) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ref.watch(userStatsProvider).when(
      data: (stats) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _StatChip(value: '${stats.totalXp}', label: 'XP TOTAL', surface: surface, border: surface2, subColor: subColor),
              const SizedBox(width: 8),
              _StatChip(value: '${stats.currentStreak}', label: 'STREAK', surface: surface, border: surface2, subColor: subColor),
              const SizedBox(width: 8),
              _StatChip(value: '${stats.level}', label: 'NÍVEL', surface: surface, border: surface2, subColor: subColor),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  // ══════════════════════════════════════════════
  // POSITION INDICATOR
  // ══════════════════════════════════════════════

  Widget _buildPositionIndicator(bool isDark, String? currentUserId) {
    final isWeekly = _tabController.index == 0;

    int total = 0;
    int myPos = 0;

    if (isWeekly) {
      final data = ref.watch(weeklyLeaderboardProvider).asData?.value;
      if (data != null) {
        total = data.length;
        for (int i = 0; i < data.length; i++) {
          if (data[i].userId == currentUserId) { myPos = i + 1; break; }
        }
      }
    } else {
      final data = ref.watch(allTimeLeaderboardProvider).asData?.value;
      if (data != null) {
        total = data.length;
        for (int i = 0; i < data.length; i++) {
          if (data[i].userId == currentUserId) { myPos = i + 1; break; }
        }
      }
    }

    if (total == 0) return const SizedBox(height: 8);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📍', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            myPos > 0 ? 'Sua posição: #$myPos de $total' : '$total participantes',
            style: AppTypography.label.copyWith(color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  // ══════════════════════════════════════════════
  // TAB CONTENT
  // ══════════════════════════════════════════════

  Widget _buildWeeklyTab(bool isDark, String? currentUserId) {
    return ref.watch(weeklyLeaderboardProvider).when(
      data: (entries) {
        if (entries.isEmpty) {
          return _buildEmpty(isDark, 'Nenhum quiz jogado esta semana.\nSeja o primeiro!');
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final entry = entries[i];
            final isMe = entry.userId == currentUserId;
            return _LeaderboardTile(
              rank: i + 1,
              name: entry.displayName,
              xp: entry.weeklyXp,
              streak: entry.currentStreak,
              title: entry.title,
              level: entry.level,
              isCurrentUser: isMe,
              isDark: isDark,
            ).animate().fadeIn(delay: (35 * i).ms).slideX(begin: 0.04);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (_, __) => _buildEmpty(isDark, 'Erro ao carregar ranking'),
    );
  }

  Widget _buildAllTimeTab(bool isDark, String? currentUserId) {
    return ref.watch(allTimeLeaderboardProvider).when(
      data: (users) {
        if (users.isEmpty) {
          return _buildEmpty(isDark, 'Nenhum jogador ainda.\nComece a jogar!');
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final user = users[i];
            final isMe = user.userId == currentUserId;
            return _LeaderboardTile(
              rank: i + 1,
              name: user.displayName,
              xp: user.totalXp,
              streak: user.currentStreak,
              title: user.title,
              level: user.level,
              isCurrentUser: isMe,
              isDark: isDark,
            ).animate().fadeIn(delay: (35 * i).ms).slideX(begin: 0.04);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (_, __) => _buildEmpty(isDark, 'Erro ao carregar ranking'),
    );
  }

  Widget _buildEmpty(bool isDark, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(msg, textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// STAT CHIP
// ══════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color surface;
  final Color border;
  final Color subColor;

  const _StatChip({
    required this.value, required this.label,
    required this.surface, required this.border,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTypography.heading3.copyWith(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTypography.caption.copyWith(color: subColor, fontSize: 9, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// LEADERBOARD TILE
// ══════════════════════════════════════════════

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final int streak;
  final String title;
  final int level;
  final bool isCurrentUser;
  final bool isDark;

  const _LeaderboardTile({
    required this.rank, required this.name, required this.xp,
    required this.streak, required this.title, required this.level,
    required this.isCurrentUser, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final String rankDisplay;
    if (rank == 1) {
      rankDisplay = '🥇';
    } else if (rank == 2) {
      rankDisplay = '🥈';
    } else if (rank == 3) {
      rankDisplay = '🥉';
    } else {
      rankDisplay = '#$rank';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.gold.withValues(alpha: 0.08) : surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isCurrentUser ? AppColors.gold.withValues(alpha: 0.3) : surface2,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(rankDisplay,
                textAlign: TextAlign.center,
                style: rank <= 3
                    ? const TextStyle(fontSize: 20)
                    : AppTypography.label.copyWith(color: subColor, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isCurrentUser ? '$name (Você)' : name,
                    style: AppTypography.body.copyWith(
                        color: isCurrentUser ? AppColors.gold : textColor,
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13)),
                Text('Nv.$level · $title',
                    style: AppTypography.caption.copyWith(color: subColor, fontSize: 10)),
              ],
            ),
          ),
          if (streak > 0) ...[
            Text('🕊️$streak', style: AppTypography.caption.copyWith(color: subColor, fontSize: 11)),
            const SizedBox(width: 10),
          ],
          Text('${_formatXp(xp)} XP',
              style: AppTypography.label.copyWith(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 10000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return xp.toString();
  }
}
