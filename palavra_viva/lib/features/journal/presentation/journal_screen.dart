import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/gold_button.dart';
import '../application/journal_provider.dart';
import '../domain/journal_entry.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  void _openEditor(BuildContext context, WidgetRef ref, {JournalEntry? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final contentController = TextEditingController(text: existing?.content ?? '');
    final isEditing = existing != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _JournalEditorSheet(
        titleController: titleController,
        contentController: contentController,
        isEditing: isEditing,
        onSave: () {
          if (isEditing) {
            ref.read(journalProvider.notifier).removeEntry(existing.id);
          }
          ref.read(journalProvider.notifier).addEntry(
                titleController.text,
                contentController.text,
              );
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showEntryDetail(BuildContext context, WidgetRef ref, JournalEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatter = DateFormat("EEEE, dd 'de' MMMM 'de' yyyy", 'pt_BR');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0A0D16) : AppColors.lightBackground,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXl),
            ),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatter.format(entry.date),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(LucideIcons.edit3, size: 18),
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _openEditor(context, ref, existing: entry);
                          },
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: Icon(LucideIcons.trash2, size: 18, color: AppColors.error.withValues(alpha: 0.7)),
                          onPressed: () {
                            ref.read(journalProvider.notifier).removeEntry(entry.id);
                            Navigator.of(context).pop();
                          },
                          tooltip: 'Excluir',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: AppTypography.heading2.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        entry.content,
                        style: AppTypography.bodyMedium.copyWith(
                          height: 1.8,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
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
          ? _buildEmptyState(context, ref, isDark)
          : _buildEntryList(context, ref, entries, isDark),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated feather icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              ),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.feather,
                  size: 36,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Seu pergaminho está em branco.',
              textAlign: TextAlign.center,
              style: AppTypography.heading3.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Comece registrando os movimentos do seu coração e espírito.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            GoldButton(
              label: 'Escrever 1ª Reflexão',
              icon: LucideIcons.penTool,
              onPressed: () => _openEditor(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryList(
    BuildContext context,
    WidgetRef ref,
    List<JournalEntry> entries,
    bool isDark,
  ) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: 100,
        top: AppSpacing.md,
      ),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _JournalCard(
          entry: entry,
          isDark: isDark,
          onTap: () => _showEntryDetail(context, ref, entry),
          onDelete: () => ref.read(journalProvider.notifier).removeEntry(entry.id),
        );
      },
    );
  }
}

// ─── Journal Entry Card ─────────────────────────────────────────────

class _JournalCard extends StatelessWidget {
  const _JournalCard({
    required this.entry,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  final JournalEntry entry;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM, yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date row with gold accent
            Row(
              children: [
                Container(
                  width: 3,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  formatter.format(entry.date),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  timeFormatter.format(entry.date),
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                        : AppColors.lightTextSecondary.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Title
            Text(
              entry.title,
              style: AppTypography.title.copyWith(fontSize: 17),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Content preview
            Text(
              entry.content,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Editor Bottom Sheet ────────────────────────────────────────────

class _JournalEditorSheet extends StatefulWidget {
  const _JournalEditorSheet({
    required this.titleController,
    required this.contentController,
    required this.isEditing,
    required this.onSave,
  });

  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool isEditing;
  final VoidCallback onSave;

  @override
  State<_JournalEditorSheet> createState() => _JournalEditorSheetState();
}

class _JournalEditorSheetState extends State<_JournalEditorSheet> {
  late final FocusNode _titleFocus;
  late final FocusNode _contentFocus;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _titleFocus = FocusNode();
    _contentFocus = FocusNode();
    _charCount = widget.contentController.text.length;
    widget.contentController.addListener(_updateCount);
    // Auto-focus title on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditing) {
        _contentFocus.requestFocus();
      } else {
        _titleFocus.requestFocus();
      }
    });
  }

  void _updateCount() {
    setState(() => _charCount = widget.contentController.text.length);
  }

  @override
  void dispose() {
    widget.contentController.removeListener(_updateCount);
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  bool get _canSave =>
      widget.titleController.text.trim().isNotEmpty &&
      widget.contentController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateFormat("dd 'de' MMMM, yyyy", 'pt_BR').format(DateTime.now());

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0D16) : AppColors.lightBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.xs),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.calendar, size: 14, color: AppColors.gold),
                      const SizedBox(width: 6),
                      Text(
                        now,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close
                IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    size: 20,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Divider
          Container(height: 1, color: AppColors.gold.withValues(alpha: 0.08)),
          // Editor body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    // Title
                    TextField(
                      controller: widget.titleController,
                      focusNode: _titleFocus,
                      style: AppTypography.heading2.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _contentFocus.requestFocus(),
                      decoration: InputDecoration(
                        hintText: 'Título da Reflexão...',
                        hintStyle: AppTypography.heading2.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                              : Colors.grey.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(height: 1, color: AppColors.gold.withValues(alpha: 0.06)),
                    const SizedBox(height: AppSpacing.md),
                    // Content
                    TextField(
                      controller: widget.contentController,
                      focusNode: _contentFocus,
                      maxLines: null,
                      minLines: 10,
                      style: AppTypography.bodyMedium.copyWith(height: 1.7),
                      decoration: InputDecoration(
                        hintText: 'Deixe fluir o que Deus colocou no seu coração...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : Colors.grey,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.gold.withValues(alpha: 0.08)),
              ),
            ),
            child: Row(
              children: [
                // Char count
                Text(
                  '$_charCount caracteres',
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                        : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                // Save button
                Expanded(
                  flex: 2,
                  child: ListenableBuilder(
                    listenable: Listenable.merge([
                      widget.titleController,
                      widget.contentController,
                    ]),
                    builder: (context, _) => GoldButton(
                      label: widget.isEditing ? 'Atualizar' : 'Selar Memória',
                      icon: LucideIcons.bookMarked,
                      onPressed: _canSave ? widget.onSave : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
