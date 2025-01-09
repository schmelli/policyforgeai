import 'package:flutter/material.dart';
import '../utils/markdown_utils.dart';

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

  void _applyMarkdown(String prefix, [String? suffix]) {
    final text = _controller.text;
    final selection = _controller.selection;
    
    if (!selection.isValid) return;

    final newText = MarkdownUtils.wrapSelection(
      text,
      selection.start,
      selection.end,
      prefix,
      suffix,
    );

    final newCursorPosition = selection.start + prefix.length;
    
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
    
    widget.onChanged(newText);
  }

  void _applyHeading(int level) {
    final text = _controller.text;
    final selection = _controller.selection;
    
    if (!selection.isValid) return;

    final newText = MarkdownUtils.toggleHeading(
      text,
      selection.start,
      level,
    );
    
    _controller.text = newText;
    widget.onChanged(newText);
  }

  void _toggleBulletPoint() {
    final text = _controller.text;
    final selection = _controller.selection;
    
    if (!selection.isValid) return;

    final newText = MarkdownUtils.toggleBulletPoint(
      text,
      selection.start,
    );
    
    _controller.text = newText;
    widget.onChanged(newText);
  }

  void _toggleNumberedList() {
    final text = _controller.text;
    final selection = _controller.selection;
    
    if (!selection.isValid) return;

    final newText = MarkdownUtils.toggleNumberedList(
      text,
      selection.start,
    );
    
    _controller.text = newText;
    widget.onChanged(newText);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.readOnly) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Headings
                PopupMenuButton<int>(
                  tooltip: 'Heading',
                  icon: const Icon(Icons.title),
                  onSelected: _applyHeading,
                  itemBuilder: (context) => [
                    for (var i = 1; i <= 6; i++)
                      PopupMenuItem(
                        value: i,
                        child: Text('Heading $i'),
                      ),
                  ],
                ),
                // Bold
                IconButton(
                  icon: const Icon(Icons.format_bold),
                  tooltip: 'Bold',
                  onPressed: () => _applyMarkdown('**'),
                ),
                // Italic
                IconButton(
                  icon: const Icon(Icons.format_italic),
                  tooltip: 'Italic',
                  onPressed: () => _applyMarkdown('_'),
                ),
                // Code
                IconButton(
                  icon: const Icon(Icons.code),
                  tooltip: 'Code',
                  onPressed: () => _applyMarkdown('`'),
                ),
                // Bullet List
                IconButton(
                  icon: const Icon(Icons.format_list_bulleted),
                  tooltip: 'Bullet List',
                  onPressed: _toggleBulletPoint,
                ),
                // Numbered List
                IconButton(
                  icon: const Icon(Icons.format_list_numbered),
                  tooltip: 'Numbered List',
                  onPressed: _toggleNumberedList,
                ),
                // Link
                IconButton(
                  icon: const Icon(Icons.link),
                  tooltip: 'Link',
                  onPressed: () => _applyMarkdown('[', '](url)'),
                ),
                // Quote
                IconButton(
                  icon: const Icon(Icons.format_quote),
                  tooltip: 'Quote',
                  onPressed: () => _applyMarkdown('> '),
                ),
              ],
            ),
          ),
          const Divider(),
        ],
        Expanded(
          child: TextField(
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
          ),
        ),
      ],
    );
  }
}
