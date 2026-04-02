import 'package:uuid/uuid.dart';

enum MessageRole { user, ai }

class ChatMessage {
  final String id;
  final String text;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({
    String? id,
    required this.text,
    required this.role,
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'role': role.index,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<dynamic, dynamic> json) => ChatMessage(
        id: json['id'] as String?,
        text: json['text'] as String,
        role: MessageRole.values[json['role'] as int],
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : null,
      );

  bool get isUser => role == MessageRole.user;
}
