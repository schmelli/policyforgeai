import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import '../models/project.dart';
import '../services/document_export_service.dart';
import '../widgets/share_dialog.dart';
import 'package:flutter_quill/flutter_quill.dart' show DefaultStyles, DefaultTextBlockStyle, VerticalSpacing;

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
  bool _isEditing = false;

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

      // TODO: Load actual document content
      _controller = QuillController(
        document: Document.fromJson([
          {"insert": widget.document!.document.content ?? ""}
        ]),
        selection: const TextSelection.collapsed(offset: 0),
      );
      _controller?.readOnly = isReadOnly;
      _controller?.addListener(_onTextChanged);
    } else {
      _controller = null;
    }
  }

  void _onTextChanged() {
    if (_controller != null && widget.onContentChanged != null) {
      final content = _controller!.document.toPlainText();
      widget.onContentChanged!(content);
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
            if (widget.showShareButton) Padding(
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
