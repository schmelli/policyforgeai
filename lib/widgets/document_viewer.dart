import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/project.dart';

class DocumentViewer extends StatefulWidget {
  final DocumentLeafNode? document;
  final void Function(String content)? onContentChanged;

  const DocumentViewer({
    super.key,
    this.document,
    this.onContentChanged,
  });

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  QuillController? _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(DocumentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document?.id != widget.document?.id) {
      _initializeController();
    }
  }

  void _initializeController() {
    if (widget.document != null) {
      // TODO: Load actual document content
      _controller = QuillController(
        document: Document.fromJson([
          {"insert": widget.document!.document.content ?? ""}
        ]),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _controller?.addListener(_onTextChanged);
    } else {
      _controller = null;
    }
    _isEditing = false;
  }

  void _onTextChanged() {
    if (_controller != null && widget.onContentChanged != null) {
      final content = _controller!.document.toPlainText();
      widget.onContentChanged!(content);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.document == null) {
      return const _EmptyDocumentView();
    }

    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: _buildEditor(),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppBar(
      title: Text(widget.document?.name ?? ''),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.save : Icons.edit),
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
          tooltip: _isEditing ? 'Save' : 'Edit',
        ),
      ],
    );
  }

  Widget _buildEditor() {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_isEditing) ...[
            QuillToolbar.basic(
              controller: _controller!,
              showAlignmentButtons: true,
              showBackgroundColorButton: false,
              showCenterAlignment: true,
              showColorButton: true,
              showCodeBlock: false,
              showDirection: false,
              showFontFamily: false,
              showDividers: true,
              showIndent: true,
              showHeaderStyle: true,
              showLink: true,
              showSearchButton: true,
              showInlineCode: true,
              showQuote: true,
              showListNumbers: true,
              showListBullets: true,
              showClearFormat: true,
              showBoldButton: true,
              showItalicButton: true,
              showUnderLineButton: true,
              showStrikeThrough: true,
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: QuillEditor(
                controller: _controller!,
                scrollController: ScrollController(),
                scrollable: true,
                focusNode: FocusNode(),
                autoFocus: false,
                readOnly: !_isEditing,
                expands: false,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDocumentView extends StatelessWidget {
  const _EmptyDocumentView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No document selected',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a document from the tree to view or edit it',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
