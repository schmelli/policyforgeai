import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/chat.dart';
import '../../services/ai_service.dart';
import '../../services/storage_service.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class ClearChat extends ChatEvent {
  const ClearChat();
}

// States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatLoaded extends ChatState {
  final ChatThread thread;
  final bool isProcessing;

  const ChatLoaded({
    required this.thread,
    this.isProcessing = false,
  });

  ChatLoaded copyWith({
    ChatThread? thread,
    bool? isProcessing,
  }) {
    return ChatLoaded(
      thread: thread ?? this.thread,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [thread, isProcessing];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AIService _aiService;
  final StorageService _storageService;
  final String _documentId;

  ChatBloc({
    required AIService aiService,
    required StorageService storageService,
    required String documentId,
  })  : _aiService = aiService,
        _storageService = storageService,
        _documentId = documentId,
        super(ChatLoaded(
          thread: ChatThread.create(documentId: documentId),
          isProcessing: false,
        )) {
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
    _loadChatThread();
  }

  Future<void> _loadChatThread() async {
    try {
      final thread = await _storageService.loadChatThread(_documentId) ??
          ChatThread.create(documentId: _documentId);
      emit(ChatLoaded(thread: thread, isProcessing: false));
    } catch (e) {
      emit(ChatError(message: 'Failed to load chat thread: $e'));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;

    final currentState = state as ChatLoaded;
    final userMessage = ChatMessage.create(
      role: MessageRole.user,
      content: event.message,
    );

    // Add user message and show processing state
    final updatedThread = currentState.thread.copyWith(
      messages: [...currentState.thread.messages, userMessage],
      lastModified: DateTime.now(),
    );
    emit(ChatLoaded(thread: updatedThread, isProcessing: true));

    try {
      // Get document content for context
      final documentContent = await _storageService.getDocumentContent(_documentId);

      // Generate AI response
      final response = await _aiService.generateResponse(
        messages: updatedThread.messages,
        documentContext: documentContent,
      );

      // Add AI response
      final aiMessage = ChatMessage.create(
        role: MessageRole.assistant,
        content: response,
      );

      final finalThread = updatedThread.copyWith(
        messages: [...updatedThread.messages, aiMessage],
        lastModified: DateTime.now(),
      );

      // Save thread and update state
      await _storageService.saveChatThread(_documentId, finalThread);
      emit(ChatLoaded(thread: finalThread, isProcessing: false));
    } catch (e) {
      emit(ChatError(message: 'Failed to generate response: $e'));
      emit(ChatLoaded(thread: updatedThread, isProcessing: false));
    }
  }

  Future<void> _onClearChat(ClearChat event, Emitter<ChatState> emit) async {
    try {
      final emptyThread = ChatThread.create(documentId: _documentId);
      await _storageService.saveChatThread(_documentId, emptyThread);
      emit(ChatLoaded(thread: emptyThread, isProcessing: false));
    } catch (e) {
      emit(ChatError(message: 'Failed to clear chat: $e'));
    }
  }
}
