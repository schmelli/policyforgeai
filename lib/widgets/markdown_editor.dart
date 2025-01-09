import 'package:flutter/material.dart';

class MarkdownEditor extends StatefulWidget {
  final String initialContent;
  final Function(String) onChanged;
  final bool readOnly;

  const MarkdownEditor({
    super.key,
    required this.initialContent,
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  void didUpdateWidget(MarkdownEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialContent != widget.initialContent) {
      _controller.text = widget.initialContent;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: null,
      readOnly: widget.readOnly,
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
      ),
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
      ),
      onChanged: widget.onChanged,
    );
  }
}
