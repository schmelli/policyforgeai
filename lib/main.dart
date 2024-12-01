import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'models/project.dart';
import 'models/document.dart';
import 'models/settings.dart';
import 'blocs/document/document_bloc.dart';
import 'blocs/document_tree/document_tree_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/chat/chat_bloc.dart';
import 'services/storage_service.dart';
import 'services/ai_service.dart';
import 'widgets/document_tree.dart';
import 'widgets/document_structure.dart';
import 'widgets/chat_panel.dart';
import 'widgets/settings_panel.dart';
import 'widgets/project_selection_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final storageService = StorageService();
    await storageService.initialize();

    final settings = await storageService.loadProjectSettings('default');
    final aiService = AIService(
      apiKey: settings?.aiSettings.apiKey ??
          const String.fromEnvironment('OPENAI_API_KEY'),
      model: settings?.aiSettings.model ?? 'gpt-3.5-turbo',
      temperature: settings?.aiSettings.temperature ?? 0.7,
      maxTokens: settings?.aiSettings.maxTokens ?? 1000,
    );

    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: storageService),
          RepositoryProvider.value(value: aiService),
        ],
        child: MyApp(storageService: storageService),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print(stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolicyForge AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ).copyWith(
          primaryContainer: Colors.blue.shade50,
          onPrimaryContainer: Colors.blue.shade900,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ).copyWith(
          primaryContainer: Colors.blue.shade900,
          onPrimaryContainer: Colors.blue.shade50,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          try {
            return ProjectSelectionScreen(storageService: storageService);
          } catch (e, stackTrace) {
            print('Error building ProjectSelectionScreen: $e');
            print(stackTrace);
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: $e'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                MyApp(storageService: storageService),
                          ),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class ProjectSelectionScreen extends StatelessWidget {
  final StorageService storageService;

  const ProjectSelectionScreen({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome to PolicyForge AI',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        final project = Project.create(
                          name: 'New Project',
                          description: 'A new policy management project',
                          createdBy: 'current-user',
                        );
                        await storageService.saveProject(project);
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => ProjectWorkspace(
                                project: project,
                              ),
                            ),
                          );
                        }
                      } catch (e, stackTrace) {
                        print('Error creating project: $e');
                        print(stackTrace);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error creating project: $e'),
                              action: SnackBarAction(
                                label: 'Retry',
                                onPressed: () {
                                  // Retry button pressed
                                },
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Project'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final projects = await storageService.listProjects();
                        if (context.mounted) {
                          final selectedProject = await showDialog<Project>(
                            context: context,
                            builder: (context) => ProjectSelectionDialog(
                              projects: projects,
                            ),
                          );
                          if (selectedProject != null && context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ProjectWorkspace(
                                  project: selectedProject,
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e, stackTrace) {
                        print('Error loading projects: $e');
                        print(stackTrace);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error loading projects: $e'),
                              action: SnackBarAction(
                                label: 'Retry',
                                onPressed: () {
                                  // Retry button pressed
                                },
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Open Existing Project'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
  late final DocumentTreeBloc _documentTreeBloc;
  late final DocumentBloc _documentBloc;
  late final SettingsBloc _settingsBloc;
  late final ChatBloc _chatBloc;
  late QuillController _quillController;
  late FocusNode _focusNode;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _focusNode = FocusNode();

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
    _settingsBloc = SettingsBloc(
      storageService: storageService,
      projectId: widget.project.id,
    );
    _chatBloc = ChatBloc(
      aiService: aiService,
      storageService: storageService,
      documentId: '', // We'll update this when a document is selected
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _documentTreeBloc.add(LoadDocumentTree(widget.project.id));
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _documentTreeBloc),
        BlocProvider.value(value: _documentBloc),
        BlocProvider.value(value: _settingsBloc),
        BlocProvider.value(value: _chatBloc),
      ],
      child: Scaffold(
        body: BlocBuilder<DocumentTreeBloc, DocumentTreeState>(
          builder: (context, state) {
            if (state is DocumentTreeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DocumentTreeLoaded) {
              final selectedNode = state.selectedNode;

              return Row(
                children: [
                  // Vertical Button Bar
                  Container(
                    width: 48,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final formKey = GlobalKey<FormState>();
                            String documentName = '';

                            final result = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Create New Document'),
                                content: Form(
                                  key: formKey,
                                  child: TextFormField(
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Document Name',
                                      hintText: 'Enter document name',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a document name';
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
                                        Navigator.of(dialogContext).pop(true);
                                      }
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (formKey.currentState?.validate() ??
                                          false) {
                                        formKey.currentState?.save();
                                        Navigator.of(dialogContext).pop(true);
                                      }
                                    },
                                    child: const Text('Create'),
                                  ),
                                ],
                              ),
                            );

                            if (result == true && documentName.isNotEmpty) {
                              final document = PolicyDocument.create(
                                title: documentName,
                                projectId: widget.project.id,
                                createdBy: 'current-user',
                              );

                              _documentTreeBloc.add(CreateDocument(
                                document.title,
                                projectId: widget.project.id,
                                parentId: null,
                              ));

                              _documentBloc.add(UpdateDocument(
                                documentId: document.id,
                                content: document.content,
                              ));
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            // TODO: Implement settings
                          },
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  // Document Tree
                  SizedBox(
                    width: 250,
                    child: DocumentTree(
                      nodes: state.nodes,
                      selectedId: state.selectedNode?.id,
                      onNodeSelected: (id) {
                        final node = _findNodeById(state.nodes, id);
                        if (node != null) {
                          _documentTreeBloc.add(SelectNode(node));
                          if (node is DocumentLeafNode) {
                            _documentBloc.add(LoadDocument(node));
                          }
                        }
                      },
                      onNodeMoved: (node, newParentId) {
                        _documentTreeBloc.add(
                          MoveNode(
                            node: node,
                            newParentId: newParentId,
                          ),
                        );
                      },
                      projectId: widget.project.id,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  // Document Structure (Navigation)
                  if (selectedNode is DocumentLeafNode)
                    SizedBox(
                      width: 250,
                      child: DocumentStructure(
                        key: ValueKey((selectedNode).document.id),
                        document: (selectedNode).document,
                        projectId: widget.project.id,
                        onContentChanged: (content) {
                          _documentBloc.add(
                            UpdateDocument(
                              documentId: selectedNode.id,
                              content: content,
                            ),
                          );
                        },
                      ),
                    ),
                  const VerticalDivider(width: 1),
                  // Document Viewer
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

  DocumentNode? _findNodeById(List<DocumentNode> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
      if (node is FolderNode) {
        final found = _findNodeById(node.children, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _documentTreeBloc.close();
    _documentBloc.close();
    _settingsBloc.close();
    _chatBloc.close();
    _quillController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

class DocumentViewer extends StatefulWidget {
  final PolicyDocument? document;

  const DocumentViewer({
    super.key,
    this.document,
  });

  @override
  State<DocumentViewer> createState() => _DocumentViewerState();
}

class _DocumentViewerState extends State<DocumentViewer> {
  late QuillController _controller;
  late FocusNode _focusNode;
  final bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _focusNode = FocusNode();
    _updateDocument();
  }

  void _updateDocument() {
    if (widget.document != null) {
      try {
        final doc = Document.fromJson(jsonDecode(widget.document!.content));
        _controller.document = doc;
      } catch (e) {
        print('Error updating document: $e');
        _controller.document = Document();
      }
    } else {
      _controller.document = Document();
    }
  }

  @override
  void didUpdateWidget(DocumentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.document?.id != oldWidget.document?.id ||
        widget.document?.content != oldWidget.document?.content) {
      _updateDocument();
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      controller: _controller,
      focusNode: _focusNode,
      scrollController: ScrollController(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
