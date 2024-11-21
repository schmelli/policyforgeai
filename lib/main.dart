import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/document_tree/document_tree_bloc.dart';
import 'blocs/document/document_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/chat/chat_bloc.dart';
import 'models/project.dart';
import 'services/storage_service.dart';
import 'services/ai_service.dart';
import 'widgets/document_tree.dart';
import 'widgets/project_selection_dialog.dart';
import 'widgets/settings_panel.dart';
import 'widgets/chat_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = StorageService();
  await storageService.initialize();

  final settings = await storageService.loadProjectSettings();
  final aiService = AIService(
    apiKey: settings?.aiSettings.apiKey ?? const String.fromEnvironment('OPENAI_API_KEY'),
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
      home: ProjectSelectionScreen(storageService: storageService),
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
                      final project = Project.create(
                        name: 'New Project',
                        description: 'A new policy management project',
                        createdBy: 'current-user', // TODO: Get from auth
                      );
                      await storageService.saveProject(project);
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ProjectWorkspace(
                              storageService: storageService,
                              projectId: project.id,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Project'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
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
                                storageService: storageService,
                                projectId: selectedProject.id,
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
  final StorageService storageService;
  final String projectId;

  const ProjectWorkspace({
    super.key,
    required this.storageService,
    required this.projectId,
  });

  @override
  State<ProjectWorkspace> createState() => _ProjectWorkspaceState();
}

class _ProjectWorkspaceState extends State<ProjectWorkspace> {
  int _selectedIndex = 0;
  late final DocumentTreeBloc _documentTreeBloc;
  late final DocumentBloc _documentBloc;
  late final SettingsBloc _settingsBloc;

  @override
  void initState() {
    super.initState();
    _documentTreeBloc = DocumentTreeBloc(
      storageService: widget.storageService,
      projectId: widget.projectId,
    );
    _documentBloc = DocumentBloc(
      storageService: widget.storageService,
      projectId: widget.projectId,
    );
    _settingsBloc = SettingsBloc(
      storageService: widget.storageService,
      projectId: widget.projectId,
    );
    _documentTreeBloc.add(LoadDocumentTree(widget.projectId));
    _settingsBloc.add(LoadSettings(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder),
                label: Text('Documents'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _documentTreeBloc),
                BlocProvider.value(value: _documentBloc),
                BlocProvider.value(value: _settingsBloc),
              ],
              child: _selectedIndex == 0
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Document Tree Panel
                        SizedBox(
                          width: 250,
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: DocumentTree(
                              onCreateFolder: (String name, String? parentId) {
                                _documentTreeBloc.add(CreateFolder(name, parentId: parentId));
                              },
                              onCreateDocument: (String name, String? parentId) {
                                _documentTreeBloc.add(CreateDocument(name, parentId: parentId));
                              },
                            ),
                          ),
                        ),
                        // Document Viewer Panel
                        Expanded(
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: BlocBuilder<DocumentTreeBloc, DocumentTreeState>(
                              builder: (context, state) {
                                if (state is DocumentTreeLoaded &&
                                    state.selectedNode != null) {
                                  if (state.selectedNode is DocumentLeafNode) {
                                    return DocumentViewer(
                                      document: (state.selectedNode
                                              as DocumentLeafNode)
                                          .document,
                                      onSave: (String content) {
                                        _documentBloc
                                            .add(UpdateDocument(content: content));
                                      },
                                    );
                                  }
                                }
                                return const Center(
                                  child: Text('Select a document to view'),
                                );
                              },
                            ),
                          ),
                        ),
                        // Chat Panel
                        SizedBox(
                          width: 300,
                          child: BlocBuilder<DocumentTreeBloc, DocumentTreeState>(
                            builder: (context, state) {
                              final documentId = state is DocumentTreeLoaded && 
                                state.selectedNode is DocumentLeafNode
                                  ? (state.selectedNode as DocumentLeafNode).document.id
                                  : '';
                              
                              return BlocProvider(
                                create: (context) => ChatBloc(
                                  aiService: context.read<AIService>(),
                                  storageService: context.read<StorageService>(),
                                  documentId: documentId,
                                ),
                                child: ChatPanel(
                                  documentId: documentId,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const Card(
                      margin: EdgeInsets.all(8.0),
                      child: SettingsPanel(),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _documentTreeBloc.close();
    _documentBloc.close();
    _settingsBloc.close();
    super.dispose();
  }
}

class DocumentViewer extends StatelessWidget {
  final PolicyDocument? document;
  final void Function(String)? onSave;

  const DocumentViewer({super.key, this.document, this.onSave});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: Text(document?.name ?? 'Untitled Document'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: onSave != null
                  ? () => _handleSaveDocument(context)
                  : null,
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: document != null
                  ? TextEditingController(text: document.content)
                  : null,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: onSave,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSaveDocument(BuildContext context) {
    final state = context.read<DocumentBloc>().state;
    if (state is DocumentLoaded) {
      context.read<DocumentBloc>().add(SaveDocument());
    }
  }
}

class AIChatPanel extends StatelessWidget {
  const AIChatPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('AI Assistant'),
          centerTitle: true,
        ),
        Expanded(
          child: Column(
            children: [
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('Chat messages will appear here'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          // TODO: Implement chat
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        // TODO: Implement send message
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
