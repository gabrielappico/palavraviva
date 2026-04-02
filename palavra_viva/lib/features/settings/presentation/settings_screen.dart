import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Text('Configurações', style: AppTypography.heading3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          _buildSectionHeader('Preferências', isDark),
          _SettingsTile(
            icon: LucideIcons.moon,
            title: 'Modo Escuro (Celestial)',
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                ref.read(themeProvider.notifier).toggleTheme();
              },
              activeThumbColor: AppColors.gold,
            ),
            isDark: isDark,
          ),
          _SettingsTile(
            icon: LucideIcons.bellRing,
            title: 'Notificações Devocionais',
            trailing: Switch(
              value: settings.devotionalNotifications,
              onChanged: (val) {
                ref.read(settingsProvider.notifier).toggleDevotionalNotifications(val);
              },
              activeThumbColor: AppColors.gold,
            ),
            isDark: isDark,
          ),
          _SettingsTile(
            icon: LucideIcons.type,
            title: 'Tamanho da Fonte',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getFontSizeName(settings.fontSize),
                  style: AppTypography.caption.copyWith(color: AppColors.gold),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.gold),
              ],
            ),
            onTap: () {
              _showFontSizeDialog(context, ref, isDark, settings.fontSize);
            },
            isDark: isDark,
          ),
          
          _buildSectionHeader('Conta', isDark),
          _SettingsTile(
            icon: LucideIcons.user,
            title: 'Meu Perfil',
            onTap: () {
              context.push('/profile');
            },
            isDark: isDark,
          ),
          
          _buildSectionHeader('Legal', isDark),
          _SettingsTile(
            icon: LucideIcons.shieldCheck,
            title: 'Privacidade e Termos',
            onTap: () {
              context.push('/terms');
            },
            isDark: isDark,
          ),
          _SettingsTile(
            icon: LucideIcons.helpCircle,
            title: 'Ajuda e Suporte',
            onTap: () {
              context.push('/support');
            },
            isDark: isDark,
          ),
          
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(LucideIcons.feather, size: 24, color: AppColors.gold.withValues(alpha: 0.5)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Palavra Viva v1.0.0',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  String _getFontSizeName(AppFontSize fontSize) {
    switch (fontSize) {
      case AppFontSize.small:
        return 'Pequena';
      case AppFontSize.medium:
        return 'Média';
      case AppFontSize.large:
        return 'Grande';
    }
  }

  void _showFontSizeDialog(BuildContext context, WidgetRef ref, bool isDark, AppFontSize currentSize) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text('Tamanho da Fonte', style: AppTypography.heading3),
              ),
              _FontSizeOption(
                title: 'Pequena',
                value: AppFontSize.small,
                groupValue: currentSize,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setFontSize(val!);
                  context.pop();
                },
                isDark: isDark,
              ),
              _FontSizeOption(
                title: 'Média',
                value: AppFontSize.medium,
                groupValue: currentSize,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setFontSize(val!);
                  context.pop();
                },
                isDark: isDark,
              ),
              _FontSizeOption(
                title: 'Grande',
                value: AppFontSize.large,
                groupValue: currentSize,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).setFontSize(val!);
                  context.pop();
                },
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.xl,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: isDark ? AppColors.gold : AppColors.goldDark,
          letterSpacing: 2.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon, 
          size: 20, 
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      trailing: trailing ?? (onTap != null ? Icon(LucideIcons.chevronRight, size: 18, color: isDark ? Colors.white38 : Colors.black38) : null),
      onTap: onTap,
    );
  }
}

class _FontSizeOption extends StatelessWidget {
  final String title;
  final AppFontSize value;
  final AppFontSize groupValue;
  final ValueChanged<AppFontSize?> onChanged;
  final bool isDark;

  const _FontSizeOption({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<AppFontSize>(
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.gold,
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.gold;
        }
        return isDark ? Colors.white54 : Colors.black54;
      }),
    );
  }
}
