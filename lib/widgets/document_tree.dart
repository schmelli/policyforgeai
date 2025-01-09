import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/project.dart';
import '../blocs/document_tree/document_tree_bloc.dart';

class DocumentTree extends StatefulWidget {
  final List<DocumentNode> nodes;
  final String? selectedId;
  final void Function(String id)? onNodeSelected;
  final void Function(DocumentNode node, String? newParentId)? onNodeMoved;
  final String projectId;

  const DocumentTree({
    super.key,
    required this.nodes,
    this.selectedId,
    this.onNodeSelected,
    this.onNodeMoved,
    required this.projectId,
  });

  @override
  State<DocumentTree> createState() => _DocumentTreeState();
}

class _DocumentTreeState extends State<DocumentTree> {
  final Set<String> _expandedNodes = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.nodes.length,
      itemBuilder: (context, index) {
        return _buildNode(widget.nodes[index], context);
      },
    );
  }

  Widget _buildNode(DocumentNode node, BuildContext context, {int depth = 0}) {
    final isSelected = node.id == widget.selectedId;
    final children = node is FolderNode ? node.children : <DocumentNode>[];
    final hasChildren = children.isNotEmpty;
    final isExpanded = _expandedNodes.contains(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DragTarget<DocumentNode>(
          onWillAcceptWithDetails: (details) {
            if (details.data.id == node.id) return false;
            // Don't allow dropping onto a document or onto a parent/ancestor
            if (node is DocumentLeafNode) return false;
            return true;
          },
          onAcceptWithDetails: (details) {
            widget.onNodeMoved?.call(details.data, node.id);
            context.read<DocumentTreeBloc>().add(
                  MoveNode(
                    node: details.data,
                    newParentId: node.id,
                  ),
                );
          },
          builder: (context, candidateData, rejectedData) {
            return Draggable<DocumentNode>(
              data: node,
              feedback: Material(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        node is FolderNode ? Icons.folder : Icons.description,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(node.name),
                    ],
                  ),
                ),
              ),
              child: InkWell(
                onTap: () => widget.onNodeSelected?.call(node.id),
                child: Container(
                  padding: EdgeInsets.only(
                    left: (depth * 24).toDouble(),
                    top: 8,
                    bottom: 8,
                    right: 8,
                  ),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: Row(
                    children: [
                      if (node is FolderNode)
                        IconButton(
                          icon: Icon(
                            hasChildren
                                ? (isExpanded
                                    ? Icons.expand_more
                                    : Icons.chevron_right)
                                : Icons.chevron_right,
                            size: 16,
                          ),
                          onPressed: hasChildren
                              ? () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedNodes.remove(node.id);
                                    } else {
                                      _expandedNodes.add(node.id);
                                    }
                                  });
                                }
                              : null,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        )
                      else
                        const SizedBox(width: 24),
                      Icon(
                        node is FolderNode ? Icons.folder : Icons.description,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(node.name)),
                      if (node is FolderNode)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 16),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'new_folder',
                              child: Text('New Folder'),
                            ),
                            const PopupMenuItem(
                              value: 'new_document',
                              child: Text('New Document'),
                            ),
                          ],
                          onSelected: (value) {
                            _showCreateDialog(
                                context, node.id, value == 'new_folder');
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (hasChildren && isExpanded)
          ...children
              .map((child) => _buildNode(child, context, depth: depth + 1)),
      ],
    );
  }

  void _showCreateDialog(BuildContext context, String parentId, bool isFolder) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New ${isFolder ? 'Folder' : 'Document'}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: 'Enter ${isFolder ? 'folder' : 'document'} name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final bloc = context.read<DocumentTreeBloc>();
                if (isFolder) {
                  bloc.add(CreateFolder(name, parentId: parentId));
                } else {
                  bloc.add(CreateDocument(
                    name,
                    parentId: parentId,
                    projectId: widget.projectId,
                  ));
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
