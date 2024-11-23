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

  ChatMessage({
    String? id,
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? DateTime.now();

  /// Creates a copy of this message with the given fields replaced
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

  /// Converts this message to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.toString(),
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Creates a message from a JSON map
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: MessageRole.values.firstWhere(
          (e) => e.toString() == json['role'],
          orElse: () => MessageRole.user,
        ),
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  List<Object?> get props => [id, role, content, timestamp];
}

/// Represents a chat thread
class ChatThread extends Equatable {
  final String id;
  final List<ChatMessage> messages;
  final DateTime lastModified;

  ChatThread({
    String? id,
    List<ChatMessage>? messages,
    DateTime? lastModified,
  })  : id = id ?? const Uuid().v4(),
        messages = messages ?? [],
        lastModified = lastModified ?? DateTime.now();

  /// Creates a copy of this thread with the given fields replaced
  ChatThread copyWith({
    String? id,
    List<ChatMessage>? messages,
    DateTime? lastModified,
  }) {
    return ChatThread(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Converts this thread to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'messages': messages.map((m) => m.toJson()).toList(),
        'lastModified': lastModified.toIso8601String(),
      };

  /// Creates a thread from a JSON map
  factory ChatThread.fromJson(Map<String, dynamic> json) => ChatThread(
        id: json['id'] as String,
        messages: (json['messages'] as List<dynamic>)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastModified: DateTime.parse(json['lastModified'] as String),
      );

  @override
  List<Object?> get props => [id, messages, lastModified];
}
