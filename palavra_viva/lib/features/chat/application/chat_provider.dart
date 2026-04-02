import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../domain/chat_message.dart';

String get _openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? error,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  late Dio _dio;
  static const _boxName = 'chatBox';

  @override
  ChatState build() {
    _dio = Dio();
    
    final box = Hive.box(_boxName);
    final historyDynamic = box.get('history');
    
    List<ChatMessage> loadedMessages = [];
    
    if (historyDynamic != null && historyDynamic is List) {
      loadedMessages = historyDynamic.map((dynamic item) => 
        ChatMessage.fromJson(item as Map<dynamic, dynamic>)
      ).toList();
    }
    
    // Se histórico estiver vazio, envia a saudação oficial
    if (loadedMessages.isEmpty) {
      loadedMessages = [
        ChatMessage(
          text: 'Olá. Sou seu Conselheiro Teológico. A Palavra Viva tem respostas para qualquer aflição. Como posso nutrir sua fé hoje?',
          role: MessageRole.ai,
        ),
      ];
    }

    return ChatState(messages: loadedMessages);
  }

  Future<void> _saveHistory(List<ChatMessage> messages) async {
    final box = Hive.box(_boxName);
    final serialized = messages.map((m) => m.toJson()).toList();
    await box.put('history', serialized);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(text: text, role: MessageRole.user);
    
    final newMessages = [...state.messages, userMsg];
    state = state.copyWith(
      messages: newMessages,
      isTyping: true,
      clearError: true,
    );
    await _saveHistory(newMessages);

    try {
      final historyParams = state.messages.map((m) {
        return {
          'role': m.role == MessageRole.ai ? 'assistant' : 'user',
          'content': m.text,
        };
      }).toList();

      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openAiApiKey',
        }),
        data: {
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  'Você é um conselheiro cristão e teológico solidário e acolhedor. Responda perguntas usando as escrituras sagradas para dar base aos seus aconselhamentos. Seja carinhoso e sempre sábio.'
            },
            ...historyParams,
          ],
        },
      );

      final replyText = response.data['choices'][0]['message']['content'];
      final aiMsg = ChatMessage(text: replyText, role: MessageRole.ai);

      final finalMessages = [...state.messages, aiMsg];
      state = state.copyWith(
        messages: finalMessages,
        isTyping: false,
      );
      await _saveHistory(finalMessages);

    } catch (e) {
      if (_openAiApiKey.isEmpty) {
        state = state.copyWith(
          isTyping: false,
          error: 'Por favor, adicione sua chave de API OpenAI no arquivo `.env` para habilitar a IA.',
        );
        return;
      }
      state = state.copyWith(
        isTyping: false,
        error: 'Sinto muito, perdi a conexão espiritual com o servidor. Tente novamente.',
      );
    }
  }
}
