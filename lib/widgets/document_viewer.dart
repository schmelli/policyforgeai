import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/project.dart';
import '../services/document_export_service.dart';
import '../widgets/share_dialog.dart';

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
        Row(
          children: [
            if (widget.document != null) ...[
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Export Document'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Choose export format:'),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final format in ExportFormat.values)
                                FilledButton.tonal(
                                  onPressed: () async {
                                    try {
                                      await DocumentExportService.exportDocument(
                                        widget.document!.document,
                                        format,
                                      );
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Document exported successfully',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to export document: $e',
                                            ),
                                            backgroundColor:
                                                Theme.of(context).colorScheme.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Text(
                                    format.name.toUpperCase(),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.download),
                tooltip: 'Export Document',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ShareDialog(
                    documentId: widget.document!.id,
                    projectId: widget.document!.projectId,
                    createdBy: widget.document!.createdBy,
                  ),
                ),
                tooltip: 'Share Document',
              ),
              const SizedBox(width: 8),
            ],
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
