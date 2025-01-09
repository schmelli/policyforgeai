import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';
import '../widgets/document_viewer.dart';
import '../widgets/document_tree.dart';
import '../models/document.dart';
import '../models/project.dart';
import '../blocs/document_tree/document_tree_bloc.dart';

class ProjectWorkspace extends StatefulWidget {
  final String projectId;

  const ProjectWorkspace({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectWorkspace> createState() => _ProjectWorkspaceState();
}

class _ProjectWorkspaceState extends State<ProjectWorkspace> {
  final StorageService _storageService = StorageService();
  PolicyDocument? _selectedDocument;

  @override
  void initState() {
    super.initState();
  }

  void _onDocumentSelected(String nodeId) {
    final state = context.read<DocumentTreeBloc>().state;
    if (state is DocumentTreeLoaded) {
      final node = _findNode(state.nodes, nodeId);
      if (node is DocumentLeafNode) {
        setState(() {
          _selectedDocument = node.document;
        });
      }
    }
  }

  DocumentNode? _findNode(List<DocumentNode> nodes, String nodeId) {
    for (final node in nodes) {
      if (node.id == nodeId) return node;
      if (node is FolderNode) {
        final found = _findNode(node.children, nodeId);
        if (found != null) return found;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectId),
      ),
      body: Row(
        children: [
          // Document Tree
          SizedBox(
            width: 250,
            child: DocumentTree(
              projectId: widget.projectId,
              nodes:
                  context.watch<DocumentTreeBloc>().state is DocumentTreeLoaded
                      ? (context.watch<DocumentTreeBloc>().state
                              as DocumentTreeLoaded)
                          .nodes
                      : [],
              selectedId: _selectedDocument?.id,
              onNodeSelected: _onDocumentSelected,
            ),
          ),
          // Vertical Divider
          const VerticalDivider(width: 1),
          // Document Editor
          Expanded(
            child: _selectedDocument != null
                ? DocumentViewer(
                    document: _selectedDocument!,
                    storageService: _storageService,
                  )
                : const Center(
                    child: Text('Select a document to edit'),
                  ),
          ),
        ],
      ),
    );
  }
}
