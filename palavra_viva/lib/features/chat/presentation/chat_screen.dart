import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ai_typing_indicator.dart';
import '../../../core/widgets/fade_in_text.dart';
import '../../../core/widgets/glass_card.dart';
import '../application/chat_provider.dart';
import '../domain/chat_message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  void _sendMessage() {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _textController.clear();
    
    // Auto-scroll depois de enviar
    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Se houver nova animação ou load, scroll
    if (chatState.isTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 24),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.sparkles, color: AppColors.gold, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text('Palavra.AI', style: AppTypography.heading3),
          ],
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      body: Column(
        children: [
          // Área de Mensagens
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
              itemBuilder: (context, index) {
                // Se for o último e está digitando, mostre o indicador
                if (index == chatState.messages.length) {
                  return const _AiTypingBubble();
                }
                
                final message = chatState.messages[index];
                // Aplica a animação FadeInApenas na ÚLTIMA msg do AI recém gerada
                final bool isLastAndAi = (index == chatState.messages.length - 1) && !message.isUser;
                
                return _ChatBubble(
                  message: message,
                  isAnimated: isLastAndAi,
                );
              },
            ),
          ),

          // Alerta de erro
          if (chatState.error != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertCircle, color: AppColors.error, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      chatState.error!,
                      style: AppTypography.caption.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),

          // Caixa de Entrada Customizada
          Container(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.sm,
              top: AppSpacing.sm,
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 
                  ? AppSpacing.sm 
                  : 110.0, // Espaço para a Bottom Navigation Bar Flutuante
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    style: AppTypography.bodySmall,
                    decoration: InputDecoration(
                      hintText: 'Pergunte, desabe, reflita...',
                      hintStyle: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                      ),
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: chatState.isTyping ? null : _sendMessage,
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: chatState.isTyping ? null : AppColors.goldGradient,
                      color: chatState.isTyping ? (isDark ? AppColors.darkSurface2 : AppColors.lightSurface2) : null,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.send,
                      color: chatState.isTyping
                          ? (isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled)
                          : AppColors.darkBackground,
                      size: 18,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, this.isAnimated = false});

  final ChatMessage message;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusMd),
              topRight: Radius.circular(AppSpacing.radiusMd),
              bottomLeft: Radius.circular(AppSpacing.radiusMd),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.darkBackground),
          ),
        ),
      );
    }

    // AI Message uses GlassCard for a mystical, celestial feel
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          borderRadius: AppSpacing.radiusMd,
          borderColor: AppColors.celestialBlue.withValues(alpha: 0.2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2, right: 12),
                child: Icon(LucideIcons.sparkles, color: AppColors.gold, size: 16),
              ),
              Expanded(
                child: isAnimated
                    ? FadeInText(
                        text: message.text,
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                        charDelay: const Duration(milliseconds: 15),
                      )
                    : Text(
                        message.text,
                        style: AppTypography.bodySmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiTypingBubble extends StatelessWidget {
  const _AiTypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        borderRadius: AppSpacing.radiusMd,
        borderColor: AppColors.gold.withValues(alpha: 0.1),
        child: const AiTypingIndicator(),
      ),
    );
  }
}
