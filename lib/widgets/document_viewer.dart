import 'package:flutter/material.dart';
import 'dart:async';
import '../services/storage_service.dart';
import '../models/document.dart';
import '../utils/logger.dart';
import 'markdown_editor.dart';

class DocumentViewer extends StatefulWidget {
  final PolicyDocument document;
  final StorageService storageService;
  final Function()? onDocumentChanged;

  const DocumentViewer({
    super.key,
    required this.document,
    required this.storageService,
    this.onDocumentChanged,
  });

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  String _content = '';
  bool _isLoading = true;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(DocumentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id) {
      _loadDocument();
    }
  }

  Future<void> _loadDocument() async {
    try {
      final content = await widget.storageService.loadDocumentContent(
        widget.document.projectId,
        widget.document.id,
      );
      setState(() {
        _content = content ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Error loading document: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDocument(String content) async {
    // Cancel any pending saves
    _saveTimer?.cancel();
    
    // Start a new timer
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        await widget.storageService.saveDocumentContent(
          widget.document.projectId,
          widget.document.id,
          content,
        );
        widget.onDocumentChanged?.call();
      } catch (e) {
        appLogger.e('Error saving document', error: e);
        // Show error snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving document: $e')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Simple toolbar
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.document.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        // Editor
        Expanded(
          child: MarkdownEditor(
            initialContent: _content,
            onChanged: _saveDocument,
          ),
        ),
      ],
    );
  }
}
