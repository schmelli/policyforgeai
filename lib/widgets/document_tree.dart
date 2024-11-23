import 'package:flutter/material.dart';
import '../models/project.dart';

class DocumentTree extends StatefulWidget {
  final List<DocumentNode> nodes;
  final Function(String name, String parentId)? onCreateFolder;
  final Function(String name, String parentId)? onCreateDocument;
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
    required BuildContext context,
    required bool isFolder,
    required String parentId,
  }) async {
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Create ${isFolder ? 'Folder' : 'Document'}'),
          content: TextField(
            controller: _nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'Enter ${isFolder ? 'folder' : 'document'} name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                }
                _nameController.clear();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      );

      if (name != null && name.isNotEmpty) {
        if (isFolder) {
          widget.onCreateFolder?.call(name, parentId);
        } else {
          widget.onCreateDocument?.call(name, parentId);
        }
        
        // Show a snackbar to indicate the creation is in progress
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Creating ${isFolder ? 'folder' : 'document'}: $name'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating ${isFolder ? 'folder' : 'document'}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildNodeIcon(DocumentNode node) {
    if (node is FolderNode) {
      return expandedNodes.contains(node.id)
          ? const Icon(Icons.folder_open)
          : const Icon(Icons.folder);
    } else {
      return const Icon(Icons.description);
    }
  }

  Widget _buildNode(DocumentNode node, {required bool isRoot}) {
    final children = node is FolderNode ? node.children : <DocumentNode>[];
    final hasChildren = children.isNotEmpty;
    final isExpanded = expandedNodes.contains(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
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
          child: Padding(
            padding: EdgeInsets.only(
              left: isRoot ? 0 : 16.0,
              top: 4.0,
              bottom: 4.0,
            ),
            child: Row(
              children: [
                _buildNodeIcon(node),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    node.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (node is FolderNode)
                  IconButton(
                    icon: const Icon(Icons.create_new_folder),
                    onPressed: () => _showCreateDialog(
                      context: context,
                      isFolder: true,
                      parentId: node.id,
                    ),
                  ),
                if (node is FolderNode)
                  IconButton(
                    icon: const Icon(Icons.note_add),
                    onPressed: () => _showCreateDialog(
                      context: context,
                      isFolder: false,
                      parentId: node.id,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children
                  .map((child) => _buildNode(
                        child,
                        isRoot: false,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.create_new_folder),
                  onPressed: () => _showCreateDialog(
                    context: context,
                    isFolder: true,
                    parentId: '',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.note_add),
                  onPressed: () => _showCreateDialog(
                    context: context,
                    isFolder: false,
                    parentId: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...widget.nodes
                .map((node) => _buildNode(
                      node,
                      isRoot: true,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
