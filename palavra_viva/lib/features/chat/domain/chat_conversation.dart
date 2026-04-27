import 'package:uuid/uuid.dart';
import 'chat_message.dart';

class ChatConversation {
  final String id;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation({
    String? id,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        messages = messages ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get title {
    // First user message as title, or fallback
    final firstUserMsg = messages.where((m) => m.isUser).firstOrNull;
    if (firstUserMsg != null) {
      final text = firstUserMsg.text;
      return text.length > 50 ? '${text.substring(0, 50)}…' : text;
    }
    return 'Nova conversa';
  }

  String get preview {
    if (messages.isEmpty) return '';
    final last = messages.last;
    final text = last.text;
    return text.length > 80 ? '${text.substring(0, 80)}…' : text;
  }

  ChatConversation copyWith({
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) {
    return ChatConversation(
      id: id,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChatConversation.fromJson(Map<dynamic, dynamic> json) {
    final messagesList = (json['messages'] as List?)
            ?.map((m) => ChatMessage.fromJson(m as Map<dynamic, dynamic>))
            .toList() ??
        [];

    return ChatConversation(
      id: json['id'] as String,
      messages: messagesList,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
