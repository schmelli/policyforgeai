import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import '../models/project.dart';
import '../services/document_export_service.dart';
import '../widgets/share_dialog.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show DefaultStyles, DefaultTextBlockStyle, VerticalSpacing;
import 'dart:convert'; // Import jsonDecode

class DocumentViewer extends StatefulWidget {
  final DocumentLeafNode? document;
  final void Function(String content)? onContentChanged;
  final bool showShareButton;
  final bool? readOnly;

  const DocumentViewer({
    super.key,
    this.document,
    this.onContentChanged,
    this.showShareButton = true,
    this.readOnly,
  });

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  QuillController? _controller;
  final bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(DocumentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document?.id != widget.document?.id ||
        oldWidget.readOnly != widget.readOnly) {
      _initializeController();
    } else if (oldWidget.document?.document.content !=
        widget.document?.document.content) {
      print('Document content changed, updating controller');
      _updateControllerContent();
    }
  }

  void _initializeController() {
    if (widget.document != null) {
      // TODO: Get current user ID from auth service
      const currentUserId = '';
      final permissions = widget.document!.document.permissions;
      final isReadOnly = widget.readOnly ??
          (permissions.owner != currentUserId &&
              !permissions.editors.contains(currentUserId));

      try {
        // Parse the document content as JSON
        final content = widget.document!.document.content;
        print('Initializing controller with content: $content');
        final json = content.isEmpty
            ? [
                {"insert": "\n"}
              ]
            : jsonDecode(content);

        if (_controller != null) {
          // Update existing controller
          final doc = Document.fromJson(json);
          _controller!.document = doc;
          _controller!.readOnly = isReadOnly;
        } else {
          // Create new controller
          _controller = QuillController(
            document: Document.fromJson(json),
            selection: const TextSelection.collapsed(offset: 0),
          );
          _controller?.readOnly = isReadOnly;
          _controller?.addListener(_onTextChanged);
        }
      } catch (e) {
        print('Error initializing document: $e');
        // Initialize with empty document if parsing fails
        final emptyDoc = Document();
        if (_controller != null) {
          _controller!.document = emptyDoc;
          _controller!.readOnly = isReadOnly;
        } else {
          _controller = QuillController(
            document: emptyDoc,
            selection: const TextSelection.collapsed(offset: 0),
          );
          _controller?.readOnly = isReadOnly;
          _controller?.addListener(_onTextChanged);
        }
      }
    } else {
      _controller?.dispose();
      _controller = null;
    }
  }

  void _updateControllerContent() {
    if (widget.document != null && _controller != null) {
      try {
        final content = widget.document!.document.content;
        print('Updating controller with content: $content');
        final json = content.isEmpty
            ? [
                {"insert": "\n"}
              ]
            : jsonDecode(content);
        final doc = Document.fromJson(json);

        // Preserve cursor position
        final oldSelection = _controller!.selection;

        // Update document
        _controller!.document = doc;

        // Restore cursor position if it's still valid
        if (oldSelection.start <= doc.length &&
            oldSelection.end <= doc.length) {
          _controller!.updateSelection(oldSelection, ChangeSource.local);
        }
      } catch (e) {
        print('Error updating document content: $e');
      }
    }
  }

  void _onTextChanged() {
    if (_controller != null && widget.onContentChanged != null) {
      // Save the full document JSON to preserve formatting
      final json = _controller!.document.toDelta().toJson();
      widget.onContentChanged!(jsonEncode(json));
    }
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => ShareDialog(
        documentId: widget.document!.id,
        projectId: widget.document!.document.projectId,
        createdBy: widget.document!.createdBy,
      ),
    );
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
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: QuillToolbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (!_controller!.readOnly) ...[
                          QuillToolbarHistoryButton(
                            controller: _controller!,
                            isUndo: true,
                          ),
                          QuillToolbarHistoryButton(
                            controller: _controller!,
                            isUndo: false,
                          ),
                          QuillToolbarToggleStyleButton(
                            controller: _controller!,
                            attribute: Attribute.bold,
                          ),
                          QuillToolbarToggleStyleButton(
                            controller: _controller!,
                            attribute: Attribute.italic,
                          ),
                          QuillToolbarToggleStyleButton(
                            controller: _controller!,
                            attribute: Attribute.underline,
                          ),
                          QuillToolbarClearFormatButton(
                            controller: _controller!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showShareButton)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _showShareDialog,
                  tooltip: 'Share Document',
                ),
              ),
          ],
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: QuillEditor(
              controller: _controller!,
              scrollController: ScrollController(),
              focusNode: FocusNode(),
              configurations: QuillEditorConfigurations(
                padding: EdgeInsets.zero,
                autoFocus: false,
                scrollPhysics: const ClampingScrollPhysics(),
                enableInteractiveSelection: !_controller!.readOnly,
                expands: true,
              ),
            ),
          ),
        ),
      ],
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
