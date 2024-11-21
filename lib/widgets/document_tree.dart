import 'package:flutter/material.dart';
import '../models/project.dart';

class DocumentTree extends StatefulWidget {
  final List<DocumentNode> nodes;
  final Function(String name, String? parentId)? onCreateFolder;
  final Function(String name, String? parentId)? onCreateDocument;
  final Function(DocumentNode)? onNodeSelected;

  const DocumentTree({
    super.key,
    this.nodes = const [],
    this.onNodeSelected,
    this.onCreateFolder,
    this.onCreateDocument,
  });

  @override
  State<DocumentTree> createState() => _DocumentTreeState();
}

class _DocumentTreeState extends State<DocumentTree> {
  Set<String> expandedNodes = {};
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showCreateDialog({
    required String title,
    required Function(String name, String? parentId) onSubmit,
    String? parentId,
  }) async {
    _nameController.clear();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter name',
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  onSubmit(_nameController.text, parentId);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Documents'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              onPressed: widget.onCreateFolder == null
                  ? null
                  : () => _showCreateDialog(
                        title: 'Create Folder',
                        onSubmit: widget.onCreateFolder!,
                      ),
              tooltip: 'Create Folder',
            ),
            IconButton(
              icon: const Icon(Icons.note_add),
              onPressed: widget.onCreateDocument == null
                  ? null
                  : () => _showCreateDialog(
                        title: 'Create Document',
                        onSubmit: widget.onCreateDocument!,
                      ),
              tooltip: 'Create Document',
            ),
          ],
        ),
        Expanded(
          child: widget.nodes.isEmpty
              ? _buildEmptyState()
              : ListView(
                  children: widget.nodes
                      .map((node) => _buildNode(node, 0))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder_open,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No documents yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => widget.onCreateDocument?.call(''),
            icon: const Icon(Icons.add),
            label: const Text('Create Document'),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(DocumentNode node, int depth) {
    final isExpanded = expandedNodes.contains(node.id);
    
    if (node is FolderNode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNodeTile(
            node,
            depth,
            isExpanded,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.note_add, size: 18),
                  onPressed: () => widget.onCreateDocument?.call(node.id),
                  tooltip: 'Create Document',
                ),
                IconButton(
                  icon: const Icon(Icons.create_new_folder, size: 18),
                  onPressed: () => widget.onCreateFolder?.call(node.id),
                  tooltip: 'Create Folder',
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.only(left: 16.0 + depth * 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: node.children
                    .map((child) => _buildNode(child, depth + 1))
                    .toList(),
              ),
            ),
        ],
      );
    } else {
      return _buildNodeTile(node, depth, false);
    }
  }

  Widget _buildNodeTile(
    DocumentNode node,
    int depth,
    bool isExpanded, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        node is FolderNode
            ? isExpanded
                ? Icons.folder_open
                : Icons.folder
            : Icons.description,
      ),
      title: Text(node.name),
      trailing: trailing,
      onTap: () {
        if (node is FolderNode) {
          setState(() {
            if (isExpanded) {
              expandedNodes.remove(node.id);
            } else {
              expandedNodes.add(node.id);
            }
          });
        }
        widget.onNodeSelected?.call(node);
      },
    );
  }
}
