import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/chat/chat_bloc.dart';
import '../models/chat.dart';

class ChatPanel extends StatelessWidget {
  final String documentId;

  const ChatPanel({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is ChatLoaded) {
          return Column(
            children: [
              // Chat Header
              _ChatHeader(
                onClear: () {
                  context.read<ChatBloc>().add(const ClearChat());
                },
              ),
              // Message List
              Expanded(
                child: _MessageList(
                  messages: state.thread.messages,
                  isProcessing: state.isProcessing,
                ),
              ),
              // Message Input
              _MessageInput(
                onSend: (message) {
                  context.read<ChatBloc>().add(SendMessage(message));
                },
                isProcessing: state.isProcessing,
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final VoidCallback onClear;

  const _ChatHeader({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_outlined,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'AI Assistant',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: colorScheme.error,
            ),
            onPressed: onClear,
            tooltip: 'Clear chat',
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatefulWidget {
  final List<ChatMessage> messages;
  final bool isProcessing;

  const _MessageList({
    required this.messages,
    required this.isProcessing,
  });

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      itemCount: widget.messages.length + (widget.isProcessing ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.messages.length) {
          return const _ProcessingIndicator();
        }
        return _MessageBubble(message: widget.messages[index]);
      },
    );
  }
}

class _ProcessingIndicator extends StatelessWidget {
  const _ProcessingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(
        left: 64.0,
        right: 8.0,
        top: 4.0,
        bottom: 4.0,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Thinking...',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(16.0),
        margin: EdgeInsets.only(
          left: isUser ? 64.0 : 8.0,
          right: isUser ? 8.0 : 64.0,
          top: 4.0,
          bottom: 4.0,
        ),
        decoration: BoxDecoration(
          color: isUser ? colorScheme.primary : colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? colorScheme.onPrimary : colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                color: isUser 
                    ? colorScheme.onPrimary.withOpacity(0.7)
                    : colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isProcessing;

  const _MessageInput({
    required this.onSend,
    required this.isProcessing,
  });

  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.isProcessing,
              decoration: InputDecoration(
                hintText: 'Ask me anything about this document...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                fillColor: colorScheme.surface,
                filled: true,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onChanged: (value) {
                setState(() => _hasText = value.trim().isNotEmpty);
              },
              onSubmitted: (_) => _handleSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _hasText && !widget.isProcessing ? _handleSubmit : null,
            icon: const Icon(Icons.send),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: colorScheme.surfaceVariant,
              disabledForegroundColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
