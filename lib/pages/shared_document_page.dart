import 'package:flutter/material.dart';
import '../services/share_service.dart';
import '../widgets/document_viewer.dart';
import '../models/policy_document.dart';

class SharedDocumentPage extends StatefulWidget {
  final String shareUrl;

  const SharedDocumentPage({Key? key, required this.shareUrl}) : super(key: key);

  @override
  State<SharedDocumentPage> createState() => _SharedDocumentPageState();
}

class _SharedDocumentPageState extends State<SharedDocumentPage> {
  bool _isLoading = true;
  String? _error;
  ShareLink? _shareLink;
  PolicyDocument? _document;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final shareLink = await ShareService.parseShareUrl(widget.shareUrl);
      if (shareLink == null) {
        setState(() => _error = 'Invalid share link');
        return;
      }

      final validLink = await ShareService.getShareLink(shareLink.id);
      if (validLink == null) {
        setState(() => _error = 'This share link has expired or been deactivated');
        return;
      }

      // TODO: Load document using DocumentService
      // final document = await DocumentService.getDocument(validLink.documentId);
      // setState(() => _document = document);
      
      setState(() => _shareLink = validLink);
    } catch (e) {
      setState(() => _error = 'Failed to load document: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_document == null) {
      return const Scaffold(
        body: Center(child: Text('Document not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_document!.title),
        actions: [
          if (_shareLink?.permission == SharePermission.comment ||
              _shareLink?.permission == SharePermission.edit)
            IconButton(
              icon: const Icon(Icons.comment),
              onPressed: () {
                // TODO: Show comments panel
              },
              tooltip: 'View Comments',
            ),
        ],
      ),
      body: DocumentViewer(
        document: _document!,
        readOnly: _shareLink?.permission != SharePermission.edit,
        onContentChanged: (content) {
          if (_shareLink?.permission == SharePermission.edit) {
            // TODO: Save document changes
          }
        },
      ),
    );
  }
}
