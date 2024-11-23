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

class LoadChat extends ChatEvent {
  final String documentId;

  const LoadChat(this.documentId);

  @override
  List<Object?> get props => [documentId];
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

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AIService _aiService;
  final StorageService _storageService;
  final String _documentId;
  ChatThread? _currentThread;

  ChatBloc({
    required AIService aiService,
    required StorageService storageService,
    required String documentId,
  })  : _aiService = aiService,
        _storageService = storageService,
        _documentId = documentId,
        super(const ChatLoading()) {
    on<LoadChat>(_onLoadChat);
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);

    // Load chat thread when bloc is created
    add(LoadChat(_documentId));
  }

  Future<void> _onLoadChat(LoadChat event, Emitter<ChatState> emit) async {
    try {
      emit(const ChatLoading());
      final thread = await _storageService.loadChatThread(event.documentId);
      _currentThread = thread ?? ChatThread(messages: []);
      emit(ChatLoaded(thread: _currentThread!));
    } catch (e) {
      emit(ChatError('Failed to load chat thread: $e'));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      try {
        // Update state to show processing
        emit(ChatLoaded(
          thread: currentState.thread,
          isProcessing: true,
        ));

        // Generate AI response
        final response = await _aiService.generateResponse(message: event.message);

        // Create new message
        final message = ChatMessage(
          content: event.message,
          role: MessageRole.user,
          timestamp: DateTime.now(),
        );

        // Create AI response message
        final aiMessage = ChatMessage(
          content: response,
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
        );

        // Update thread with new messages
        final updatedThread = currentState.thread.copyWith(
          messages: [...currentState.thread.messages, message, aiMessage],
        );

        // Save updated thread
        await _storageService.saveChatThread(_documentId, updatedThread);

        // Update state with new messages
        emit(ChatLoaded(
          thread: updatedThread,
          isProcessing: false,
        ));
      } catch (e) {
        emit(ChatError('Failed to send message: $e'));
      }
    }
  }

  Future<void> _onClearChat(ClearChat event, Emitter<ChatState> emit) async {
    try {
      await _storageService.clearChatThread(_documentId);
      _currentThread = ChatThread(messages: []);
      emit(ChatLoaded(thread: _currentThread!));
    } catch (e) {
      emit(ChatError('Failed to clear chat: $e'));
    }
  }
}
