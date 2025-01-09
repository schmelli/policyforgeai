import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'models/project.dart';
import 'models/settings.dart';
import 'models/llm_provider.dart';
import 'blocs/document/document_bloc.dart';
import 'blocs/document_tree/document_tree_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/chat/chat_bloc.dart';
import 'services/storage_service.dart';
import 'services/ai_service.dart';
import 'widgets/document_tree.dart';
import 'widgets/document_viewer.dart';
import 'widgets/project_selection_dialog.dart';
import 'widgets/new_project_button.dart';
import 'widgets/open_project_button.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final storageService = StorageService();
    await storageService.initialize();

    final settings = await storageService.loadProjectSettings('default');
    final aiService = AIService(
      config: settings?.aiSettings.llmConfig ??
          const LLMConfig(
            provider: LLMProvider.ollama,
            model: 'llama2',
            baseUrl: 'http://localhost:11434/api/chat',
          ),
      temperature: settings?.aiSettings.temperature ?? 0.7,
      maxTokens: settings?.aiSettings.maxTokens ?? 1000,
    );

    appLogger.i('Settings loaded successfully');
    appLogger.d('Settings content: $settings');

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
    appLogger.e('Error initializing app', error: e, stackTrace: stackTrace);
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
            appLogger.e('Error building ProjectSelectionScreen', error: e, stackTrace: stackTrace);
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
                  NewProjectButton(storageService: storageService),
                  const SizedBox(height: 16),
                  OpenProjectButton(storageService: storageService),
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
  late final DocumentTreeBloc _documentTreeBloc;
  late final DocumentBloc _documentBloc;
  late final SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _documentTreeBloc = DocumentTreeBloc(
      storageService: _storageService,
      projectId: widget.projectId,
    );
    _documentBloc = DocumentBloc(
      storageService: _storageService,
      projectId: widget.projectId,
    );
    _settingsBloc = SettingsBloc(
      storageService: _storageService,
      projectId: widget.projectId,
    );

    // Load initial data
    _documentTreeBloc.add(LoadDocumentTree(widget.projectId));
    _settingsBloc.add(LoadSettings(widget.projectId));
    _loadInitialDocument();
  }

  Future<void> _loadInitialDocument() async {
    final nodes = await _storageService.loadProjectTree(widget.projectId);
    if (nodes.isNotEmpty && nodes.first is DocumentLeafNode) {
      final node = nodes.first as DocumentLeafNode;
      _documentBloc.add(LoadDocument(node.document));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _documentTreeBloc),
        BlocProvider.value(value: _documentBloc),
        BlocProvider.value(value: _settingsBloc),
        BlocProvider(
          create: (context) {
            // Get initial document ID from tree state
            String documentId = widget.projectId;
            if (_documentTreeBloc.state is DocumentTreeLoaded) {
              final state = _documentTreeBloc.state as DocumentTreeLoaded;
              if (state.nodes.isNotEmpty &&
                  state.nodes.first is DocumentLeafNode) {
                documentId =
                    (state.nodes.first as DocumentLeafNode).document.id;
              }
            }

            return ChatBloc(
              aiService: context.read<AIService>(),
              storageService: _storageService,
              documentId: documentId,
            );
          },
        ),
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
                              // Create document through the bloc
                              _documentTreeBloc.add(CreateDocument(
                                documentName,
                                projectId: widget.projectId,
                                parentId: null,
                              ));

                              // Wait for the tree to update
                              await Future.delayed(
                                  const Duration(milliseconds: 100));

                              // Then load the document if it was created
                              if (mounted &&
                                  _documentTreeBloc.state
                                      is DocumentTreeLoaded) {
                                final state = _documentTreeBloc.state
                                    as DocumentTreeLoaded;
                                final node = state.selectedNode;
                                if (node is DocumentLeafNode) {
                                  _documentBloc
                                      .add(LoadDocument(node.document));
                                }
                              }
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
                            _documentBloc.add(LoadDocument(node.document));
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
                      projectId: widget.projectId,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  // Document Viewer
                  Expanded(
                    child: selectedNode is DocumentLeafNode
                        ? DocumentViewer(
                            document: selectedNode.document,
                            storageService: _storageService,
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
    super.dispose();
  }
}
