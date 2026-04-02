import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/gold_button.dart';
import '../application/journal_provider.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  void _openEditor(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor:
          Colors.transparent, // Modal customizado usando container interno
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          height:
              MediaQuery.of(context).size.height *
              0.9, // 90% da tela para escrever
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F121C)
                : AppColors.lightBackground, // Base muito escura linda
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              // Tracinho de drag
              Container(
                margin: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  bottom: AppSpacing.md,
                ),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      // Titulo Input Focus
                      TextField(
                        controller: titleController,
                        style: AppTypography.heading2.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Título da Reflexão...',
                          hintStyle: AppTypography.heading2.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(
                                    alpha: 0.5,
                                  )
                                : Colors.grey,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        height: 1,
                        color: AppColors.gold.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Corpo Devocional Input Limitless
                      Expanded(
                        child: TextField(
                          controller: contentController,
                          maxLines: null,
                          expands: true,
                          style: AppTypography.bodyMedium.copyWith(height: 1.6),
                          decoration: InputDecoration(
                            hintText:
                                'Escreva de onde vem a fonte das suas águas. Deixe fluir...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : Colors.grey,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Rodapé: Salvar
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.gold.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 240,
                    child: GoldButton(
                      label: 'Selar Memória',
                      icon: LucideIcons.bookMarked,
                      onPressed: () {
                        ref
                            .read(journalProvider.notifier)
                            .addEntry(
                              titleController.text,
                              contentController.text,
                            );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider).entries;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário Espiritual'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.penTool, color: AppColors.gold),
            onPressed: () => _openEditor(context, ref),
            tooltip: 'Escrever Nova Reflexão',
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.feather,
                    size: 60,
                    color: AppColors.gold.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Seu pergaminho está em branco.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: SizedBox(
                      width: 240,
                      child: GoldButton(
                        label: 'Escrever 1ª Reflexão',
                        icon: LucideIcons.penTool,
                        onPressed: () => _openEditor(context, ref),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: 120, // Padding massivo embaixo para a Floating Button
                top: AppSpacing.md,
              ),
              itemCount: entries.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final formatter = DateFormat(
                  'dd MMM, yyyy',
                ); // Padrao de visualização de Data

                return InkWell(
                  onTap: () {
                    // Visão focada do diário pode ser implementada em popup depois
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkSurface2
                            : AppColors.lightSurface2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                entry.title,
                                style: AppTypography.title.copyWith(
                                  fontSize: 18,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                LucideIcons.trash2,
                                size: 18,
                                color: AppColors.error.withValues(alpha: 0.7),
                              ),
                              onPressed: () {
                                ref
                                    .read(journalProvider.notifier)
                                    .removeEntry(entry.id);
                              },
                            ),
                          ],
                        ),
                        Text(
                          formatter.format(entry.date),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          entry.content,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
