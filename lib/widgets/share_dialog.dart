import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/share_service.dart';
import '../models/document.dart';

class ShareDialog extends StatefulWidget {
  final String documentId;
  final String projectId;
  final String createdBy;

  const ShareDialog({
    super.key,
    required this.documentId,
    required this.projectId,
    required this.createdBy,
  });

  @override
  State<ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<ShareDialog> {
  SharePermission _permission = SharePermission.view;
  DateTime? _expiresAt;
  List<ShareLink> _existingLinks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingLinks();
  }

  Future<void> _loadExistingLinks() async {
    setState(() => _isLoading = true);
    try {
      final links = await ShareService.getDocumentShareLinks(widget.documentId);
      setState(() => _existingLinks = links);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createShareLink() async {
    final link = await ShareService.createShareLink(
      documentId: widget.documentId,
      projectId: widget.projectId,
      permission: _permission,
      createdBy: widget.createdBy,
      expiresAt: _expiresAt,
    );

    setState(() => _existingLinks = [..._existingLinks, link]);
  }

  Future<void> _deactivateLink(String id) async {
    await ShareService.deactivateShareLink(id);
    await _loadExistingLinks();
  }

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Share Document',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Create New Share Link'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<SharePermission>(
                      value: _permission,
                      decoration: const InputDecoration(
                        labelText: 'Permission',
                        border: OutlineInputBorder(),
                      ),
                      items: SharePermission.values
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.name.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _permission = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _createShareLink,
                    child: const Text('Create Link'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Existing Share Links'),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_existingLinks.isEmpty)
                const Text('No share links created yet')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _existingLinks.length,
                    itemBuilder: (context, index) {
                      final link = _existingLinks[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            'Permission: ${link.permission.name.toUpperCase()}',
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Created: ${link.createdAt}'),
                              if (link.expiresAt != null)
                                Text('Expires: ${link.expiresAt}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () => _copyLink(link.shareUrl),
                                tooltip: 'Copy Link',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deactivateLink(link.id),
                                tooltip: 'Deactivate Link',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
