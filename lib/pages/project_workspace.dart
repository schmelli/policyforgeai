import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../widgets/document_viewer.dart';
import '../widgets/document_tree.dart';
import '../models/document.dart';
import '../models/project.dart';
import '../blocs/document_tree/document_tree_bloc.dart';
import '../blocs/document/document_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/chat/chat_bloc.dart';
import '../widgets/document_tree_toolbar.dart';

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
  PolicyDocument? _selectedDocument;
  Project? _project;

  @override
  void initState() {
    super.initState();
    _loadProject();
  }

  Future<void> _loadProject() async {
    final storageService = context.read<StorageService>();
    final project = await storageService.loadProject(widget.projectId);
    if (mounted) {
      setState(() {
        _project = project;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storageService = context.read<StorageService>();
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DocumentTreeBloc(
            storageService: storageService,
            projectId: widget.projectId,
          )..add(LoadDocumentTree(widget.projectId)),
        ),
        BlocProvider(
          create: (context) => DocumentBloc(
            storageService: storageService,
            projectId: widget.projectId,
          ),
        ),
        BlocProvider(
          create: (context) => SettingsBloc(
            storageService: storageService,
            projectId: widget.projectId,
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_project?.name ?? 'Loading...'),
            ),
            body: Row(
              children: [
                // Document Tree with Toolbar
                SizedBox(
                  width: 250,
                  child: Column(
                    children: [
                      // Toolbar
                      DocumentTreeToolbar(
                        onCreateDocument: () {
                          context.read<DocumentTreeBloc>().add(
                            CreateDocument(
                              'New Document',
                              projectId: widget.projectId,
                            ),
                          );
                        },
                        onCreateFolder: () {
                          context.read<DocumentTreeBloc>().add(
                            CreateFolder('New Folder'),
                          );
                        },
                      ),
                      // Tree
                      Expanded(
                        child: BlocBuilder<DocumentTreeBloc, DocumentTreeState>(
                          builder: (context, state) {
                            final nodes = state is DocumentTreeLoaded 
                                ? state.nodes
                                : <DocumentNode>[];
                            return DocumentTree(
                              projectId: widget.projectId,
                              nodes: nodes,
                              selectedId: _selectedDocument?.id,
                              onNodeSelected: (nodeId) {
                                if (state is DocumentTreeLoaded) {
                                  final node = _findNode(state.nodes, nodeId);
                                  if (node is DocumentLeafNode) {
                                    setState(() {
                                      _selectedDocument = node.document;
                                    });
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Vertical Divider
                const VerticalDivider(width: 1),
                // Document Editor
                Expanded(
                  child: _selectedDocument != null
                      ? BlocProvider(
                          create: (context) => ChatBloc(
                            storageService: storageService,
                            aiService: context.read<AIService>(),
                            documentId: _selectedDocument!.id,
                          ),
                          child: DocumentViewer(
                            document: _selectedDocument!,
                            storageService: storageService,
                          ),
                        )
                      : const Center(
                          child: Text('Select a document to edit'),
                        ),
                ),
              ],
            ),
          );
        }
      ),
    );
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
}
