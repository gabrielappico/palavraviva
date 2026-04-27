
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/openai_service.dart';
import '../domain/chat_message.dart';
import '../domain/chat_conversation.dart';

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatState {
  final ChatConversation activeConversation;
  final List<ChatConversation> conversations;
  final bool isTyping;
  final String? error;

  const ChatState({
    required this.activeConversation,
    this.conversations = const [],
    this.isTyping = false,
    this.error,
  });

  List<ChatMessage> get messages => activeConversation.messages;

  /// Whether the active conversation is empty (only greeting, no user messages)
  bool get isActiveEmpty =>
      activeConversation.messages.where((m) => m.isUser).isEmpty;

  ChatState copyWith({
    ChatConversation? activeConversation,
    List<ChatConversation>? conversations,
    bool? isTyping,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      activeConversation: activeConversation ?? this.activeConversation,
      conversations: conversations ?? this.conversations,
      isTyping: isTyping ?? this.isTyping,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  late OpenAiService _openAi;
  static const _boxName = 'chatBox';
  static const _conversationsKey = 'conversations';
  static const _activeIdKey = 'activeConversationId';

  static const _greetingText =
      'Olá. Sou seu Conselheiro Teológico. A Palavra Viva tem respostas para qualquer aflição. Como posso nutrir sua fé hoje?';

  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  @override
  ChatState build() {
    _openAi = OpenAiService();

    // Load from Hive first (instant), then sync from Supabase in background
    final localState = _loadFromHive();

    // Background sync from Supabase
    _syncFromSupabase();

    // Auto-start new conversation if the last one is stale (>1 hour)
    return _autoNewIfStale(localState);
  }

  /// If the active conversation's last update was >1 hour ago, start fresh
  ChatState _autoNewIfStale(ChatState currentState) {
    final active = currentState.activeConversation;
    final timeSinceUpdate = DateTime.now().difference(active.updatedAt);

    // Only auto-new if conversation has user messages AND is older than 1 hour
    final hasUserMessages = active.messages.any((m) => m.isUser);
    if (hasUserMessages && timeSinceUpdate.inMinutes >= 60) {
      final fresh = _createFreshConversation();
      final updated = [fresh, ...currentState.conversations];
      _persistLocal(updated, fresh.id);

      return ChatState(
        activeConversation: fresh,
        conversations: updated,
      );
    }

    return currentState;
  }

  ChatState _loadFromHive() {
    final box = Hive.box(_boxName);
    final conversationsData = box.get(_conversationsKey);
    final activeId = box.get(_activeIdKey) as String?;

    List<ChatConversation> loaded = [];

    if (conversationsData != null && conversationsData is List) {
      loaded = conversationsData
          .map((c) => ChatConversation.fromJson(c as Map<dynamic, dynamic>))
          .toList();
      loaded.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    // Migrate legacy "history" key
    _migrateLegacyHistory(box, loaded);

    ChatConversation active;
    if (loaded.isNotEmpty && activeId != null) {
      active = loaded.firstWhere(
        (c) => c.id == activeId,
        orElse: () => loaded.first,
      );
    } else if (loaded.isNotEmpty) {
      active = loaded.first;
    } else {
      active = _createFreshConversation();
      loaded = [active];
      _persistLocal(loaded, active.id);
    }

    return ChatState(
      activeConversation: active,
      conversations: loaded,
    );
  }

  void _migrateLegacyHistory(Box box, List<ChatConversation> conversations) {
    final legacyHistory = box.get('history');
    if (legacyHistory != null &&
        legacyHistory is List &&
        legacyHistory.isNotEmpty) {
      if (conversations.length == 1 &&
          conversations.first.messages.length <= 1) {
        final legacyMessages = legacyHistory
            .map((m) => ChatMessage.fromJson(m as Map<dynamic, dynamic>))
            .toList();

        if (legacyMessages.isNotEmpty) {
          final migrated = ChatConversation(messages: legacyMessages);
          conversations.insert(0, migrated);
          _persistLocal(conversations, migrated.id);
          box.delete('history');
        }
      }
    }
  }

  ChatConversation _createFreshConversation() {
    return ChatConversation(
      messages: [
        ChatMessage(text: _greetingText, role: MessageRole.ai),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  // LOCAL PERSISTENCE (Hive)
  // ═══════════════════════════════════════════════

  Future<void> _persistLocal(
      List<ChatConversation> conversations, String activeId) async {
    final box = Hive.box(_boxName);
    final serialized = conversations.map((c) => c.toJson()).toList();
    await box.put(_conversationsKey, serialized);
    await box.put(_activeIdKey, activeId);
  }

  // ═══════════════════════════════════════════════
  // SUPABASE SYNC
  // ═══════════════════════════════════════════════

  /// Sync conversations from Supabase (background, non-blocking)
  Future<void> _syncFromSupabase() async {
    if (_userId == null) return;
    try {
      final convos = await _supabase
          .from('chat_conversations')
          .select()
          .eq('user_id', _userId!)
          .order('updated_at', ascending: false);

      if (convos.isEmpty) {
        // First time — push local to Supabase
        await _pushAllToSupabase();
        return;
      }

      // Load conversations with their messages
      List<ChatConversation> remote = [];
      for (final c in convos) {
        final msgs = await _supabase
            .from('chat_messages')
            .select()
            .eq('conversation_id', c['id'])
            .order('timestamp', ascending: true);

        final messages = (msgs as List).map((m) => ChatMessage(
              id: m['id'],
              text: m['text'],
              role: m['role'] == 0 ? MessageRole.user : MessageRole.ai,
              timestamp: DateTime.parse(m['timestamp']),
            )).toList();

        remote.add(ChatConversation(
          id: c['id'],
          messages: messages,
          createdAt: DateTime.parse(c['created_at']),
          updatedAt: DateTime.parse(c['updated_at']),
        ));
      }

      // Merge: keep remote as source of truth, add any local-only convos
      final remoteIds = remote.map((r) => r.id).toSet();
      final localOnly = state.conversations
          .where((c) =>
              !remoteIds.contains(c.id) &&
              c.messages.any((m) => m.isUser))
          .toList();

      // Push local-only convos to Supabase
      for (final local in localOnly) {
        await _saveConversationToSupabase(local);
      }

      final merged = [...remote, ...localOnly];
      merged.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      final activeId = state.activeConversation.id;
      final active = merged.firstWhere(
        (c) => c.id == activeId,
        orElse: () => merged.isNotEmpty ? merged.first : _createFreshConversation(),
      );

      state = state.copyWith(
        conversations: merged,
        activeConversation: active,
      );
      await _persistLocal(merged, active.id);
    } catch (_) {
      // Offline — Hive data is fine
    }
  }

  /// Push all local conversations to Supabase
  Future<void> _pushAllToSupabase() async {
    for (final convo in state.conversations) {
      if (convo.messages.any((m) => m.isUser)) {
        await _saveConversationToSupabase(convo);
      }
    }
  }

  /// Save a single conversation + messages to Supabase
  Future<void> _saveConversationToSupabase(ChatConversation convo) async {
    if (_userId == null) return;
    try {
      await _supabase.from('chat_conversations').upsert({
        'id': convo.id,
        'user_id': _userId,
        'title': convo.title,
        'created_at': convo.createdAt.toIso8601String(),
        'updated_at': convo.updatedAt.toIso8601String(),
      });

      // Upsert messages (only user messages that matter)
      for (final msg in convo.messages) {
        await _supabase.from('chat_messages').upsert({
          'id': msg.id,
          'user_id': _userId,
          'conversation_id': convo.id,
          'text': msg.text,
          'role': msg.role.index,
          'timestamp': msg.timestamp.toIso8601String(),
        });
      }
    } catch (_) {
      // Silently fail — local data is the fallback
    }
  }

  /// Delete conversation from Supabase
  Future<void> _deleteFromSupabase(String conversationId) async {
    if (_userId == null) return;
    try {
      // Messages cascade delete via FK
      await _supabase
          .from('chat_conversations')
          .delete()
          .eq('id', conversationId);
    } catch (_) {}
  }

  // ═══════════════════════════════════════════════
  // CONVERSATION MANAGEMENT
  // ═══════════════════════════════════════════════

  /// Start a new conversation — if active is already empty, just focus it
  void startNewConversation() {
    // Guard: if current conversation has no user messages, reuse it
    if (state.isActiveEmpty) {
      return; // Already on a fresh conversation, do nothing
    }

    final fresh = _createFreshConversation();
    final updated = [fresh, ...state.conversations];

    state = state.copyWith(
      activeConversation: fresh,
      conversations: updated,
      clearError: true,
    );
    _persistLocal(updated, fresh.id);
  }

  void switchConversation(String conversationId) {
    final target = state.conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => state.activeConversation,
    );

    state = state.copyWith(
      activeConversation: target,
      clearError: true,
    );

    final box = Hive.box(_boxName);
    box.put(_activeIdKey, target.id);
  }

  void deleteConversation(String conversationId) {
    if (state.conversations.length <= 1) return;

    final updated =
        state.conversations.where((c) => c.id != conversationId).toList();

    ChatConversation newActive = state.activeConversation;
    if (state.activeConversation.id == conversationId) {
      newActive = updated.first;
    }

    state = state.copyWith(
      activeConversation: newActive,
      conversations: updated,
    );
    _persistLocal(updated, newActive.id);
    _deleteFromSupabase(conversationId);
  }

  // ═══════════════════════════════════════════════
  // MESSAGING
  // ═══════════════════════════════════════════════

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(text: text, role: MessageRole.user);

    final updatedActive = state.activeConversation.copyWith(
      messages: [...state.activeConversation.messages, userMsg],
    );

    final updatedList = state.conversations
        .map((c) => c.id == updatedActive.id ? updatedActive : c)
        .toList();
    updatedList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    state = state.copyWith(
      activeConversation: updatedActive,
      conversations: updatedList,
      isTyping: true,
      clearError: true,
    );
    await _persistLocal(updatedList, updatedActive.id);

    try {
      final historyParams = updatedActive.messages.map((m) {
        return {
          'role': m.role == MessageRole.ai ? 'assistant' : 'user',
          'content': m.text,
        };
      }).toList();

      final response = await _openAi.chatCompletion(
        messages: [
          {
            'role': 'system',
            'content':
                'Você é um conselheiro cristão e teológico solidário e acolhedor. Responda perguntas usando as escrituras sagradas para dar base aos seus aconselhamentos. Seja carinhoso e sempre sábio.'
          },
          ...historyParams,
        ],
      );

      final replyText = response['choices'][0]['message']['content'];
      final aiMsg = ChatMessage(text: replyText, role: MessageRole.ai);

      final finalActive = state.activeConversation.copyWith(
        messages: [...state.activeConversation.messages, aiMsg],
      );

      final finalList = state.conversations
          .map((c) => c.id == finalActive.id ? finalActive : c)
          .toList();
      finalList.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      state = state.copyWith(
        activeConversation: finalActive,
        conversations: finalList,
        isTyping: false,
      );
      await _persistLocal(finalList, finalActive.id);

      // Sync to Supabase in background
      _saveConversationToSupabase(finalActive);
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        error:
            'Sinto muito, perdi a conexão espiritual com o servidor. Tente novamente.',
      );
    }
  }
}
