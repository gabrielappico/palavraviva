import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
import '../core/services/gamification_service.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/bible/presentation/bible_screen.dart';
import '../features/prayer/presentation/prayer_screen.dart';
import '../features/journal/presentation/journal_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/confession/presentation/confession_screen.dart';
import '../features/sermons/presentation/sermons_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/quiz/presentation/quiz_screen.dart';
import '../features/quiz/presentation/leaderboard_screen.dart';
import '../features/activities/presentation/activities_screen.dart';
import '../features/activities/presentation/activity_detail_screen.dart';
import '../features/activities/domain/activity_model.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/profile_screen.dart';
import '../features/settings/presentation/terms_screen.dart';
import '../features/settings/presentation/support_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/insights/presentation/insights_screen.dart';
import 'dart:ui';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthRoute = state.uri.path == '/auth';
    final isSplash = state.uri.path == '/splash';
    final isResetPassword = state.uri.path == '/reset-password';

    if (isSplash || isResetPassword) return null;

    if (session == null && !isAuthRoute) {
      return '/auth';
    }

    if (session != null && isAuthRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/bible',
              builder: (context, state) => const BibleScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pray',
              builder: (context, state) => const PrayerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/journal',
              builder: (context, state) => const JournalScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/confession',
      builder: (context, state) => const ConfessionScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/sermons',
      builder: (context, state) => const SermonsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/quiz',
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/activities',
      builder: (context, state) => const ActivitiesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/activity-detail',
      builder: (context, state) => ActivityDetailScreen(
        activity: state.extra! as DynamicActivity,
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/terms',
      builder: (context, state) => const TermsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/support',
      builder: (context, state) => const SupportScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/insights',
      builder: (context, state) => const InsightsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
  ],
);

class _ScaffoldWithNavBar extends StatefulWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<_ScaffoldWithNavBar> {
  @override
  void initState() {
    super.initState();
    _logAppOpen();
  }

  Future<void> _logAppOpen() async {
    try {
      await GamificationService().logActivity('app_open', xp: 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: keyboardOpen ? const SizedBox.shrink() : Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              .withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(32.0),
          border: Border.all(
            color: isDark
                ? AppColors.gold.withValues(alpha: 0.15)
                : AppColors.gold.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: LucideIcons.bookOpen,
                        label: 'Bíblia',
                        isActive: widget.navigationShell.currentIndex == 0,
                        onTap: () => widget.navigationShell.goBranch(0, initialLocation: widget.navigationShell.currentIndex == 0),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: LucideIcons.heart,
                        label: 'Orar',
                        isActive: widget.navigationShell.currentIndex == 1,
                        onTap: () => widget.navigationShell.goBranch(1, initialLocation: widget.navigationShell.currentIndex == 1),
                      ),
                    ),
                    _CenterActionItem(
                      icon: LucideIcons.home,
                      isActive: widget.navigationShell.currentIndex == 2,
                      onTap: () => widget.navigationShell.goBranch(2, initialLocation: widget.navigationShell.currentIndex == 2),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: LucideIcons.edit,
                        label: 'Diário',
                        isActive: widget.navigationShell.currentIndex == 3,
                        onTap: () => widget.navigationShell.goBranch(3, initialLocation: widget.navigationShell.currentIndex == 3),
                      ),
                    ),
                    Expanded(
                      child: _NavItem(
                        icon: LucideIcons.messageSquare,
                        label: 'Palavra.AI',
                        isActive: widget.navigationShell.currentIndex == 4,
                        onTap: () => widget.navigationShell.goBranch(4, initialLocation: widget.navigationShell.currentIndex == 4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.gold : AppColors.goldDark;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final color = isActive ? activeColor : inactiveColor;

    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: AppSpacing.touchTarget + 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pill background + scaled icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isActive ? 18 : 16,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: isActive ? 1.18 : 1.0),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, scale, _) => Transform.scale(
                    scale: scale,
                    child: Icon(icon, color: color, size: 22),
                  ),
                ),
              ),
              // Animated text
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: isActive ? 11 : 10.5,
                ),
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              // Gold dot indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.zero,
                width: isActive ? 4 : 0,
                height: isActive ? 4 : 0,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [BoxShadow(color: activeColor.withValues(alpha: 0.5), blurRadius: 6)]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterActionItem extends StatelessWidget {
  const _CenterActionItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Início',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: isActive ? 1.1 : 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, scale, _) => Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: isActive ? AppColors.goldGradient : null,
                color: isActive ? null : (isDark ? AppColors.darkSurface2 : AppColors.lightBackground),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: isActive ? 0.8 : 0.4),
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.black : AppColors.gold,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
