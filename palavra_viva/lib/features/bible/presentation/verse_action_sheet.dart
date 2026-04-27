import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../domain/models/highlight_colors.dart';
import '../domain/models/verse_mark.dart';

class VerseActionSheet extends StatelessWidget {
  const VerseActionSheet({
    super.key,
    required this.bookName,
    required this.bookAbbrev,
    required this.chapter,
    required this.verseNumber,
    required this.verseText,
    required this.currentMark,
    required this.onToggleRead,
    required this.onHighlight,
    required this.onNote,
  });

  final String bookName;
  final String bookAbbrev;
  final int chapter;
  final int verseNumber;
  final String verseText;
  final VerseMark? currentMark;
  final VoidCallback onToggleRead;
  final void Function(String? color) onHighlight;
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRead = currentMark?.isRead ?? false;
    final currentHighlight = currentMark?.highlightColor;
    final hasNote = currentMark?.note != null && currentMark!.note!.isNotEmpty;
    final reference = '$bookName $chapter:$verseNumber';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkTextDisabled
                        : AppColors.lightTextDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Verse preview
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      verseText,
                      style: AppTypography.bibleVerse.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '— $reference',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Mark as read
              _ActionTile(
                icon: isRead ? LucideIcons.checkCircle : LucideIcons.circle,
                label: isRead ? 'Lido' : 'Marcar como Lido',
                trailing: isRead
                    ? const Icon(
                        LucideIcons.check,
                        color: AppColors.success,
                        size: 18,
                      )
                    : null,
                isDark: isDark,
                onTap: () {
                  onToggleRead();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Highlight colors
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destacar',
                      style: AppTypography.label.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        ...HighlightColors.all.map((colorName) {
                          final isSelected = currentHighlight == colorName;
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.md,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                onHighlight(isSelected ? null : colorName);
                                Navigator.pop(context);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: HighlightColors.toColor(colorName),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark ? Colors.white : Colors.black)
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: HighlightColors.toColor(
                                              colorName,
                                              opacity: 0.4,
                                            ),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        LucideIcons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }),
                        // Remove highlight
                        if (currentHighlight != null)
                          GestureDetector(
                            onTap: () {
                              onHighlight(null);
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkTextDisabled
                                      : AppColors.lightTextDisabled,
                                ),
                              ),
                              child: Icon(
                                LucideIcons.x,
                                size: 16,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Add note
              _ActionTile(
                icon: hasNote ? LucideIcons.fileEdit : LucideIcons.penTool,
                label: hasNote ? 'Editar Anotação' : 'Adicionar Anotação',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  onNote();
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Copy
              _ActionTile(
                icon: LucideIcons.copy,
                label: 'Copiar Versículo',
                isDark: isDark,
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: '"$verseText"\n— $reference'),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Versículo copiado!'),
                      backgroundColor: AppColors.gold.withValues(alpha: 0.9),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),

              // Share
              _ActionTile(
                icon: LucideIcons.share2,
                label: 'Compartilhar',
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context);
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          '"$verseText"\n\n— $reference\n\nCompartilhado pelo Palavra Viva 🕊️',
                      subject: reference,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
