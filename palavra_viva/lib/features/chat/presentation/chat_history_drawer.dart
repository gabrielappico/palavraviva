import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/chat_provider.dart';
import '../domain/chat_conversation.dart';

class ChatHistoryDrawer extends ConsumerWidget {
  const ChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversations = chatState.conversations;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.messagesSquare,
                    color: AppColors.gold,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Conversas',
                      style: AppTypography.heading3,
                    ),
                  ),
                  // New conversation button
                  _NewChatButton(onTap: () {
                    ref.read(chatProvider.notifier).startNewConversation();
                    Navigator.of(context).pop();
                  }),
                ],
              ),
            ),

            Divider(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
              height: 1,
            ),

            // Conversations list
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma conversa ainda',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextDisabled
                              : AppColors.lightTextDisabled,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final isActive =
                            conversation.id == chatState.activeConversation.id;
                        return _ConversationTile(
                          conversation: conversation,
                          isActive: isActive,
                          canDelete: conversations.length > 1,
                          onTap: () {
                            ref
                                .read(chatProvider.notifier)
                                .switchConversation(conversation.id);
                            Navigator.of(context).pop();
                          },
                          onDelete: () {
                            _showDeleteConfirmation(
                                context, ref, conversation.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, String conversationId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Apagar conversa?',
          style: AppTypography.title,
        ),
        content: Text(
          'Esta ação não pode ser desfeita.',
          style: AppTypography.bodySmall.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: AppTypography.label.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatProvider.notifier).deleteConversation(conversationId);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Apagar',
              style: AppTypography.label.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewChatButton extends StatelessWidget {
  const _NewChatButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: const Icon(
            LucideIcons.plus,
            color: AppColors.darkBackground,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.isActive,
    required this.canDelete,
    required this.onTap,
    required this.onDelete,
  });

  final ChatConversation conversation;
  final bool isActive;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inHours < 1) return '${diff.inMinutes}min';
    if (diff.inDays == 0) return DateFormat('HH:mm').format(date);
    if (diff.inDays == 1) return 'Ontem';
    if (diff.inDays < 7) return DateFormat('EEEE', 'pt_BR').format(date);
    return DateFormat('dd/MM', 'pt_BR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? (isDark
                      ? AppColors.gold.withValues(alpha: 0.08)
                      : AppColors.gold.withValues(alpha: 0.06))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: isActive
                  ? Border.all(
                      color: AppColors.gold.withValues(alpha: 0.2),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Chat icon
                Icon(
                  isActive ? LucideIcons.messageCircle : LucideIcons.messageSquare,
                  color: isActive
                      ? AppColors.gold
                      : (isDark
                          ? AppColors.darkTextDisabled
                          : AppColors.lightTextDisabled),
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.md),

                // Title & preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.title,
                              style: AppTypography.label.copyWith(
                                color: isActive
                                    ? (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary)
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            _formatDate(conversation.updatedAt),
                            style: AppTypography.caption.copyWith(
                              color: isDark
                                  ? AppColors.darkTextDisabled
                                  : AppColors.lightTextDisabled,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (conversation.preview.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          conversation.preview,
                          style: AppTypography.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextDisabled
                                : AppColors.lightTextDisabled,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Delete button
                if (canDelete)
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        LucideIcons.trash2,
                        size: 14,
                        color: isDark
                            ? AppColors.darkTextDisabled
                            : AppColors.lightTextDisabled,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
