import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ai_typing_indicator.dart';
import '../../../core/widgets/glass_card.dart';
import '../application/chat_provider.dart';
import '../domain/chat_message.dart';
import 'chat_history_drawer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    // Rebuild when keyboard opens/closes to update the bottom padding
    if (mounted) {
      setState(() {});
      // Scroll to bottom when keyboard opens so messages stay visible
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

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

  void _startNewConversation() {
    ref.read(chatProvider.notifier).startNewConversation();
    // Scroll to top for new conversation
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
      key: _scaffoldKey,
      drawer: const ChatHistoryDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        actions: [
          // New conversation button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(
                LucideIcons.plus,
                color: AppColors.darkBackground,
                size: 16,
              ),
            ),
            tooltip: 'Nova conversa',
            onPressed: _startNewConversation,
          ),
          // History button
          IconButton(
            icon: Icon(
              LucideIcons.history,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              size: 22,
            ),
            tooltip: 'Histórico',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          // Área de Mensagens
          Expanded(
            child: chatState.messages.length <= 1 && !chatState.isTyping
                ? _EmptyState(onSuggestionTap: (text) {
                    ref.read(chatProvider.notifier).sendMessage(text);
                    Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
                  })
                : ListView.separated(
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
                      // Aplica a animação FadeIn apenas na ÚLTIMA msg do AI recém gerada
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
              bottom: AppSpacing.sm + MediaQuery.of(context).padding.bottom,
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

/// Empty state shown when conversation has only the greeting message
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onSuggestionTap});
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Sparkle icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gold.withValues(alpha: 0.15),
                    AppColors.celestialBlue.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                color: AppColors.gold,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Conselheiro Teológico',
              style: AppTypography.title.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'A Palavra Viva tem respostas para qualquer aflição.\nComo posso nutrir sua fé hoje?',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),

            // Suggestion chips
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                _SuggestionChip(
                  icon: LucideIcons.heart,
                  label: 'Estou ansioso',
                  onTap: () => onSuggestionTap('Estou me sentindo ansioso, pode me ajudar?'),
                ),
                _SuggestionChip(
                  icon: LucideIcons.bookOpen,
                  label: 'Explique um versículo',
                  onTap: () => onSuggestionTap('Pode me explicar um versículo bíblico importante?'),
                ),
                _SuggestionChip(
                  icon: LucideIcons.hand,
                  label: 'Preciso de ajuda',
                  onTap: () => onSuggestionTap('Estou passando por um momento difícil e preciso de ajuda.'),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: isDark
                  ? AppColors.gold.withValues(alpha: 0.2)
                  : AppColors.gold.withValues(alpha: 0.3),
            ),
            color: isDark
                ? AppColors.gold.withValues(alpha: 0.05)
                : AppColors.gold.withValues(alpha: 0.04),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.gold),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
                    ? _FadeInMarkdown(
                        text: message.text,
                        isDark: Theme.of(context).brightness == Brightness.dark,
                        charDelay: const Duration(milliseconds: 15),
                      )
                    : _AiMarkdownBody(
                        data: message.text,
                        isDark: Theme.of(context).brightness == Brightness.dark,
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

/// Shared Markdown stylesheet that matches the app's design system
MarkdownStyleSheet _buildMarkdownStyle(BuildContext context, bool isDark) {
  final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  final secondaryColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  final codeBg = isDark
      ? AppColors.darkSurface2.withValues(alpha: 0.8)
      : AppColors.lightSurface2.withValues(alpha: 0.8);

  return MarkdownStyleSheet(
    p: AppTypography.bodySmall.copyWith(color: textColor),
    h1: AppTypography.heading3.copyWith(color: textColor),
    h2: AppTypography.title.copyWith(color: textColor),
    h3: AppTypography.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.w600),
    strong: AppTypography.bodySmall.copyWith(color: AppColors.gold, fontWeight: FontWeight.w600),
    em: AppTypography.bodySmall.copyWith(color: secondaryColor, fontStyle: FontStyle.italic),
    blockquote: AppTypography.bodySmall.copyWith(
      color: secondaryColor,
      fontStyle: FontStyle.italic,
    ),
    blockquoteDecoration: BoxDecoration(
      border: Border(left: BorderSide(color: AppColors.gold.withValues(alpha: 0.4), width: 3)),
      color: AppColors.gold.withValues(alpha: 0.04),
    ),
    blockquotePadding: const EdgeInsets.only(left: AppSpacing.md, top: AppSpacing.xs, bottom: AppSpacing.xs),
    code: AppTypography.caption.copyWith(
      color: AppColors.celestialBlue,
      backgroundColor: codeBg,
    ),
    codeblockDecoration: BoxDecoration(
      color: codeBg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      border: Border.all(color: AppColors.celestialBlue.withValues(alpha: 0.15)),
    ),
    codeblockPadding: const EdgeInsets.all(AppSpacing.md),
    listBullet: AppTypography.bodySmall.copyWith(color: AppColors.gold),
    tableHead: AppTypography.bodySmall.copyWith(color: textColor, fontWeight: FontWeight.w600),
    tableBody: AppTypography.bodySmall.copyWith(color: textColor),
    tableBorder: TableBorder.all(color: secondaryColor.withValues(alpha: 0.2)),
    horizontalRuleDecoration: BoxDecoration(
      border: Border(top: BorderSide(color: AppColors.gold.withValues(alpha: 0.2))),
    ),
    a: AppTypography.bodySmall.copyWith(color: AppColors.celestialBlue),
    blockSpacing: AppSpacing.sm,
  );
}

/// Renders markdown text for AI messages
class _AiMarkdownBody extends StatelessWidget {
  const _AiMarkdownBody({required this.data, required this.isDark});

  final String data;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      shrinkWrap: true,
      styleSheet: _buildMarkdownStyle(context, isDark),
    );
  }
}

/// Animated markdown that reveals text character by character
class _FadeInMarkdown extends StatefulWidget {
  const _FadeInMarkdown({
    required this.text,
    required this.isDark,
    this.charDelay = const Duration(milliseconds: 20),
  });

  final String text;
  final bool isDark;
  final Duration charDelay;

  @override
  State<_FadeInMarkdown> createState() => _FadeInMarkdownState();
}

class _FadeInMarkdownState extends State<_FadeInMarkdown> {
  String _displayed = '';

  @override
  void initState() {
    super.initState();
    _animate();
  }

  @override
  void didUpdateWidget(_FadeInMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _displayed = '';
      _animate();
    }
  }

  Future<void> _animate() async {
    for (var i = 0; i < widget.text.length; i++) {
      if (!mounted) return;
      await Future.delayed(widget.charDelay);
      if (!mounted) return;
      setState(() {
        _displayed = widget.text.substring(0, i + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _displayed,
      shrinkWrap: true,
      styleSheet: _buildMarkdownStyle(context, widget.isDark),
    );
  }
}

