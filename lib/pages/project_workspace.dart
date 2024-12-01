import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/project.dart';
import '../models/document.dart';
import '../blocs/document/document_bloc.dart';
import '../blocs/document_tree/document_tree_bloc.dart';
import '../blocs/chat/chat_bloc.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../widgets/document_tree.dart';
import '../widgets/document_structure.dart';
import '../widgets/chat_panel.dart';

class ProjectWorkspace extends StatefulWidget {
  final Project project;

  const ProjectWorkspace({
    super.key,
    required this.project,
  });

  @override
  State<ProjectWorkspace> createState() => _ProjectWorkspaceState();
}

class _ProjectWorkspaceState extends State<ProjectWorkspace> {
  late DocumentTreeBloc _documentTreeBloc;
  late DocumentBloc _documentBloc;
  late ChatBloc _chatBloc;
  late QuillController _quillController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize blocs
    final storageService = context.read<StorageService>();
    final aiService = context.read<AIService>();

    _documentTreeBloc = DocumentTreeBloc(
      storageService: storageService,
      projectId: widget.project.id,
    );

    _documentBloc = DocumentBloc(
      storageService: storageService,
      projectId: widget.project.id,
    );

    _chatBloc = ChatBloc(
      aiService: aiService,
      documentBloc: _documentBloc,
    );

    _documentTreeBloc.add(LoadDocumentTree(projectId: widget.project.id));
  }

  DocumentNode? _findNodeById(List<DocumentNode> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) {
        return node;
      }
      if (node is DocumentBranchNode) {
        final found = _findNodeById(node.children, id);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _documentTreeBloc),
        BlocProvider.value(value: _documentBloc),
        BlocProvider.value(value: _chatBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.project.name),
        ),
        body: BlocBuilder<DocumentTreeBloc, DocumentTreeState>(
          builder: (context, state) {
            if (state is DocumentTreeLoaded) {
              final selectedNode = _findNodeById(
                state.nodes,
                state.selectedNodeId ?? '',
              );

              return Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Card(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Text(
                                  'Documents',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    String documentName = '';
                                    final formKey = GlobalKey<FormState>();

                                    final shouldCreate = await showDialog<bool>(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('New Document'),
                                        content: Form(
                                          key: formKey,
                                          child: TextFormField(
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              labelText: 'Document Name',
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter a name';
                                              }
                                              return null;
                                            },
                                            onSaved: (value) {
                                              documentName = value ?? '';
                                            },
                                            onFieldSubmitted: (value) {
                                              if (formKey.currentState?.validate() ??
                                                  false) {
                                                formKey.currentState?.save();
                                                Navigator.of(dialogContext)
                                                    .pop(true);
                                              }
                                            },
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                                dialogContext)
                                                .pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                formKey.currentState?.save();
                                                Navigator.of(dialogContext)
                                                    .pop(true);
                                              }
                                            },
                                            child: const Text('Create'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (shouldCreate == true) {
                                      final document = Document.create(
                                        title: documentName,
                                        projectId: widget.project.id,
                                        createdBy: 'current-user',
                                      );

                                      _documentTreeBloc.add(CreateDocument(
                                        document.title,
                                        projectId: widget.project.id,
                                        parentId: state.selectedNodeId,
                                      ));

                                      _documentBloc.add(UpdateDocument(
                                        documentId: document.id,
                                        content: document.content,
                                      ));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: DocumentTree(
                              nodes: state.nodes,
                              selectedNodeId: state.selectedNodeId,
                              onNodeSelected: (nodeId) {
                                _documentTreeBloc
                                    .add(SelectNode(nodeId: nodeId));
                                if (selectedNode is DocumentLeafNode) {
                                  _documentBloc.add(LoadDocument(
                                    documentId: nodeId,
                                  ));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: selectedNode is DocumentLeafNode
                        ? BlocBuilder<DocumentBloc, DocumentState>(
                            builder: (context, docState) {
                              if (docState is DocumentLoaded &&
                                  docState.document.id == selectedNode.id) {
                                return QuillEditor(
                                  controller: _quillController,
                                  focusNode: _focusNode,
                                  scrollController: ScrollController(),
                                  scrollable: true,
                                  padding: const EdgeInsets.all(16),
                                  autoFocus: false,
                                  readOnly: false,
                                  expands: false,
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          )
                        : const Center(
                            child: Text('Select a document to view'),
                          ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text(
                  'No documents found. Create one using the + button above.'),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _documentTreeBloc.close();
    _documentBloc.close();
    _chatBloc.close();
    _quillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
