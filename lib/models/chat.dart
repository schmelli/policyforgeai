import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum MessageRole {
  system,
  user,
  assistant,
}

class ChatMessage extends Equatable {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    String? id,
    required this.role,
    required this.content,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();

  ChatMessage copyWith({
    String? id,
    MessageRole? role,
    String? content,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.toString().split('.').last,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => MessageRole.user,
      ),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [id, role, content, timestamp];
}

class ChatThread extends Equatable {
  final List<ChatMessage> messages;
  final DateTime lastModified;

  const ChatThread({
    this.messages = const [],
    DateTime? lastModified,
  }) : lastModified = lastModified ?? DateTime.now();

  ChatThread copyWith({
    List<ChatMessage>? messages,
    DateTime? lastModified,
  }) {
    return ChatThread(
      messages: messages ?? this.messages,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messages': messages.map((m) => m.toJson()).toList(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      messages: (json['messages'] as List<dynamic>)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  @override
  List<Object?> get props => [messages, lastModified];
}
