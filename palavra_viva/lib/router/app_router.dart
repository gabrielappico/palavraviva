import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';
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
import '../features/activities/presentation/activities_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/profile_screen.dart';
import '../features/settings/presentation/terms_screen.dart';
import '../features/settings/presentation/support_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
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
      path: '/activities',
      builder: (context, state) => const ActivitiesScreen(),
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
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkSurface : AppColors.lightSurface).withValues(alpha: 0.75),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _NavItem(
                      icon: LucideIcons.bookOpen,
                      label: 'Bíblia',
                      isActive: navigationShell.currentIndex == 0,
                      onTap: () => navigationShell.goBranch(0),
                    ),
                    _NavItem(
                      icon: LucideIcons.heart,
                      label: 'Orar',
                      isActive: navigationShell.currentIndex == 1,
                      onTap: () => navigationShell.goBranch(1),
                    ),
                    _CenterActionItem(
                      icon: LucideIcons.home,
                      isActive: navigationShell.currentIndex == 2,
                      onTap: () => navigationShell.goBranch(2),
                    ),
                    _NavItem(
                      icon: LucideIcons.edit,
                      label: 'Diário',
                      isActive: navigationShell.currentIndex == 3,
                      onTap: () => navigationShell.goBranch(3),
                    ),
                    _NavItem(
                      icon: LucideIcons.messageSquare,
                      label: 'Palavra.AI',
                      isActive: navigationShell.currentIndex == 4,
                      onTap: () => navigationShell.goBranch(4),
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
    final inactiveColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final color = isActive ? activeColor : inactiveColor;

    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 64,
          height: AppSpacing.touchTarget + 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? activeColor.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 11,
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
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? AppColors.gold : (isDark ? AppColors.darkSurface2 : AppColors.lightBackground),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.black : AppColors.gold,
            size: 28,
          ),
        ),
      ),
    );
  }
}
