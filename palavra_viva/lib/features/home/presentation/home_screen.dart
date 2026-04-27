import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../bible/domain/verse_share_provider.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gold_button.dart';
import '../../bible/domain/daily_verse_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/gamification_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Header(),
                    const SizedBox(height: 20),
                    const _GamificationCard(),
                    const SizedBox(height: 32),
                    const _VerseOfTheDay()
                        .animate()
                        .fade(duration: 800.ms)
                        .slideY(
                          begin: 0.1,
                          duration: 800.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 48),
                    const _DiscoverHeader().animate().fade(delay: 200.ms),
                    const SizedBox(height: 24),
                    const _FeaturesGrid()
                        .animate()
                        .fade(delay: 300.ms, duration: 800.ms)
                        .slideY(
                          begin: 0.1,
                          duration: 800.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 64),
                    const _AestheticQuote().animate().fade(
                      delay: 500.ms,
                      duration: 1000.ms,
                    ),
                    const SizedBox(height: 120), // Bottom padding for FAB/nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  void _showMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface2
                      : AppColors.lightSurface2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ListTile(
                leading: const Icon(
                  LucideIcons.settings,
                  color: AppColors.gold,
                ),
                title: Text('Configurações', style: AppTypography.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/settings');
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.info, color: AppColors.gold),
                title: Text('Sobre o App', style: AppTypography.bodyMedium),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/about');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfile(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata;
    final avatarUrl = meta?['avatar_url'];
    final name = meta?['name'] ?? 'Discípulo';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface2
                      : AppColors.lightSurface2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              CircleAvatar(
                radius: 40,
                backgroundColor: isDark
                    ? AppColors.darkSurface2
                    : AppColors.lightSurface2,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? Text(
                        initial,
                        style: AppTypography.heading1.copyWith(
                          color: AppColors.gold,
                          fontSize: 32,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(name, style: AppTypography.heading2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Membro do Palavra Viva',
                style: AppTypography.caption.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              GoldButton(
                label: 'Editar Perfil',
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/profile');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata;
    final avatarUrl = meta?['avatar_url'];
    final name = meta?['name'] ?? 'Discípulo';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _showMenu(context),
              child: const Icon(
                LucideIcons.menu,
                color: AppColors.gold,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Palavra Viva',
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.gold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  'A PAZ SEJA COM VOCÊ',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showProfile(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppColors.darkSurface2
                    : AppColors.lightSurface2,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      initial,
                      style: AppTypography.heading3.copyWith(
                        color: AppColors.gold,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerseOfTheDay extends ConsumerWidget {
  const _VerseOfTheDay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyVerseAsync = ref.watch(dailyVerseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'VERSÍCULO DO DIA',
            style: AppTypography.caption.copyWith(
              color: AppColors.gold,
              fontSize: 10,
              letterSpacing: 3,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        dailyVerseAsync.when(
          data: (dailyVerse) {
            if (dailyVerse == null) return const SizedBox.shrink();
            return _buildVerseCard(context, ref, dailyVerse);
          },
          loading: () => Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: AppColors.celestialBlue.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Erro: $error\n$stack',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }

  Widget _buildVerseCard(
    BuildContext context,
    WidgetRef ref,
    DailyVerse verse,
  ) {
    final shareCount = ref.watch(verseShareCountProvider(verse.verseKey));

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                verse.bgAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1a1a2e),
                          Color(0xFF16213e),
                          Color(0xFF0f3460),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Dark overlay gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.quote,
                    color: AppColors.gold.withValues(alpha: 0.7),
                    size: 32,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    verse.text,
                    style: AppTypography.heading1.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          verse.reference.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (shareCount > 0) ...[
                            Text(
                              _formatCount(shareCount),
                              style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          GestureDetector(
                            onTap: () {
                              incrementVerseShare(ref, verse.verseKey);
                              SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      '"${verse.text}"\n\n— ${verse.reference}\n\nCompartilhado pelo Palavra Viva 🕊️',
                                  subject:
                                      'Versículo do Dia — ${verse.reference}',
                                ),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.3),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.share2,
                                color: AppColors.gold,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      'Descobrir',
      style: AppTypography.heading2.copyWith(
        color: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
      ),
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid();

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final aspectRatio = textScale > 1.1 ? 0.75 : 0.85;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: aspectRatio,
      children: [
        _FeatureCard(
          title: 'Palavra.AI',
          description: 'Conselheiro Teológico',
          icon: const Icon(
            LucideIcons.sparkles,
            color: AppColors.gold,
            size: 24,
          ),
          color: AppColors.gold,
          onTap: () => context.go('/chat'),
        ),
        _FeatureCard(
          title: 'Bíblia',
          description: 'Leitura Interativa',
          icon: const Icon(
            Icons.auto_stories_rounded,
            color: AppColors.celestialBlue,
            size: 24,
          ),
          color: AppColors.celestialBlue,
          onTap: () => context.go('/bible'),
        ),
        _FeatureCard(
          title: 'Orações',
          description: 'Pedidos de Intercessão',
          icon: const FaIcon(
            FontAwesomeIcons.handsPraying,
            color: AppColors.gold,
            size: 24,
          ),
          color: AppColors.gold,
          onTap: () => context.go('/pray'),
        ),
        _FeatureCard(
          title: 'Diário',
          description: 'Reflexões Pessoais',
          icon: const Icon(
            LucideIcons.penTool,
            color: AppColors.celestialBlue,
            size: 24,
          ),
          color: AppColors.celestialBlue,
          onTap: () => context.go('/journal'),
        ),
        _FeatureCard(
          title: 'Confissão',
          description: 'Espaço seguro e privado',
          icon: const Icon(LucideIcons.shield, color: AppColors.gold, size: 24),
          color: AppColors.gold,
          onTap: () => context.push('/confession'),
        ),
        _FeatureCard(
          title: 'Pregações',
          description: 'Crie sermões completos',
          icon: const Icon(
            LucideIcons.mic,
            color: AppColors.celestialBlue,
            size: 24,
          ),
          color: AppColors.celestialBlue,
          onTap: () => context.push('/sermons'),
        ),
        _FeatureCard(
          title: 'Quiz',
          description: 'Teste seus saberes',
          icon: const Icon(
            LucideIcons.lightbulb,
            color: AppColors.gold,
            size: 24,
          ),
          color: AppColors.gold,
          onTap: () => context.push('/quiz'),
        ),
        _FeatureCard(
          title: 'Dinâmicas',
          description: 'Atividades para grupos',
          icon: const Icon(
            LucideIcons.users,
            color: AppColors.celestialBlue,
            size: 24,
          ),
          color: AppColors.celestialBlue,
          onTap: () => context.push('/activities'),
        ),
        _FeatureCard(
          title: 'Meus Insights',
          description: 'Suas estatísticas',
          icon: const Icon(
            LucideIcons.barChart3,
            color: AppColors.gold,
            size: 24,
          ),
          color: AppColors.gold,
          onTap: () => context.push('/insights'),
        ),
        _FeatureCard(
          title: 'Compartilhar',
          description: 'Convide amigos',
          icon: const Icon(
            LucideIcons.share2,
            color: AppColors.celestialBlue,
            size: 24,
          ),
          color: AppColors.celestialBlue,
          onTap: () => SharePlus.instance.share(
            ShareParams(
              text:
                  '✝️ Conhece o Palavra Viva?\n\n'
                  'Um app cristão com Bíblia interativa, quiz bíblico, '
                  'conselheiro teológico com IA, diário espiritual e muito mais.\n\n'
                  '📲 Android: https://play.google.com/store/apps/details?id=com.palavraviva.app\n'
                  '🍎 iPhone: https://apps.apple.com/app/palavra-viva/id0000000000',
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final Widget icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final cardPadding = textScale > 1.1 ? 16.0 : 24.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isDark ? AppColors.darkSurface2 : AppColors.lightSurface2)
                .withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(child: icon),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTypography.title.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AestheticQuote extends StatelessWidget {
  const _AestheticQuote();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          width: 1,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.gold.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '"Um coração calmo é o melhor lugar para Deus falar."',
            textAlign: TextAlign.center,
            style: AppTypography.heading3.copyWith(
              fontStyle: FontStyle.italic,
              color:
                  (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)
                      .withValues(alpha: 0.6),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _GamificationCard extends ConsumerWidget {
  const _GamificationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return ref
        .watch(userStatsProvider)
        .when(
          data: (stats) {
            if (stats.totalXp == 0 && stats.currentStreak == 0)
              return const SizedBox.shrink();
            return GestureDetector(
              onTap: () => context.push('/leaderboard'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    // Level circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gold.withValues(alpha: 0.2),
                            AppColors.gold.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${stats.level}',
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title + progress
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stats.title,
                            style: AppTypography.label.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: stats.levelProgress,
                              backgroundColor: surface2,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.gold,
                              ),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${stats.totalXp} / ${stats.xpForNextLevel} XP',
                            style: AppTypography.caption.copyWith(
                              color: subColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Streak + XP compact
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (stats.currentStreak > 0)
                          _MiniChip(
                            icon: LucideIcons.flame,
                            text: '${stats.currentStreak}d',
                            color: Colors.orange.shade300,
                          ),
                        if (stats.currentStreak > 0) const SizedBox(height: 4),
                        if (stats.freeLives > 0)
                          _MiniChip(
                            icon: LucideIcons.heart,
                            text: '${stats.freeLives}',
                            color: const Color(0xFF81C784),
                          ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Icon(LucideIcons.chevronRight, size: 14, color: subColor),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
