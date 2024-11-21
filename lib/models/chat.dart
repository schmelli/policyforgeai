import 'package:equatable/equatable.dart';

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
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.create({
    required MessageRole role,
    required String content,
  }) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: role,
      content: content,
      timestamp: DateTime.now(),
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
      ),
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  List<Object?> get props => [id, role, content, timestamp];
}

class ChatThread extends Equatable {
  final String id;
  final String documentId;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastModified;

  const ChatThread({
    required this.id,
    required this.documentId,
    required this.messages,
    required this.createdAt,
    required this.lastModified,
  });

  factory ChatThread.create({
    required String documentId,
  }) {
    final now = DateTime.now();
    return ChatThread(
      id: now.millisecondsSinceEpoch.toString(),
      documentId: documentId,
      messages: const [],
      createdAt: now,
      lastModified: now,
    );
  }

  ChatThread copyWith({
    List<ChatMessage>? messages,
    DateTime? lastModified,
  }) {
    return ChatThread(
      id: id,
      documentId: documentId,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    return ChatThread(
      id: json['id'] as String,
      documentId: json['documentId'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  @override
  List<Object?> get props => [id, documentId, messages, createdAt, lastModified];
}
