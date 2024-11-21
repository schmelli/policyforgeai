import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/project.dart';
import '../models/document.dart';
import '../models/chat.dart';
import '../utils/settings_migrator.dart';

class StorageService {
  static const String _projectsBox = 'projects';
  static const String _documentsBox = 'documents';
  static const String _projectTreeBox = 'project_tree';
  static const String _chatThreadsBox = 'chat_threads';
  static const String _settingsBox = 'settings';

  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_projectsBox);
    await Hive.openBox(_documentsBox);
    await Hive.openBox(_projectTreeBox);
    await Hive.openBox<String>(_chatThreadsBox);
    await Hive.openBox<String>(_settingsBox);
  }

  // Project Methods
  Future<void> saveProject(Project project) async {
    final box = Hive.box(_projectsBox);
    await box.put(project.id, jsonEncode(project.toJson()));
  }

  Future<Project?> loadProject(String projectId) async {
    final box = Hive.box(_projectsBox);
    final projectJson = box.get(projectId);
    if (projectJson == null) return null;

    final projectData = jsonDecode(projectJson);
    final project = Project.fromJson(projectData);
    
    // Load the project tree separately since it's stored in a different box
    project.rootNodes.addAll(await loadProjectTree(projectId));
    
    return project;
  }

  Future<List<Project>> listProjects() async {
    final box = Hive.box(_projectsBox);
    final projects = <Project>[];
    for (final key in box.keys) {
      final project = await loadProject(key.toString());
      if (project != null) {
        projects.add(project);
      }
    }
    return projects;
  }

  // Document Methods
  Future<void> saveDocument(String projectId, DocumentLeafNode document) async {
    final box = Hive.box(_documentsBox);
    await box.put('$projectId/${document.id}', jsonEncode(document.toJson()));
  }

  Future<DocumentLeafNode?> loadDocument(String projectId, String documentId) async {
    final box = Hive.box(_documentsBox);
    final documentJson = box.get('$projectId/$documentId');
    if (documentJson == null) return null;

    final documentData = jsonDecode(documentJson);
    return DocumentLeafNode.fromJson(documentData);
  }

  // Project Tree Methods
  Future<void> saveProjectTree(String projectId, List<DocumentNode> nodes) async {
    final box = Hive.box(_projectTreeBox);
    final treeData = nodes.map((node) => node.toJson()).toList();
    await box.put(projectId, jsonEncode(treeData));
  }

  Future<List<DocumentNode>> loadProjectTree(String projectId) async {
    final box = Hive.box(_projectTreeBox);
    final treeJson = box.get(projectId);
    if (treeJson == null) return [];

    final treeData = jsonDecode(treeJson) as List;
    return treeData.map<DocumentNode>((nodeData) {
      final type = nodeData['type'] as String;
      if (type == 'folder') {
        return FolderNode.fromJson(nodeData);
      } else {
        return DocumentLeafNode.fromJson(nodeData);
      }
    }).toList();
  }

  // Chat thread methods
  Future<ChatThread?> loadChatThread(String documentId) async {
    final box = Hive.box<String>(_chatThreadsBox);
    final threadJson = box.get(documentId);
    if (threadJson == null) return null;

    final threadData = jsonDecode(threadJson);
    return ChatThread.fromJson(threadData);
  }

  Future<void> saveChatThread(String documentId, ChatThread thread) async {
    final box = Hive.box<String>(_chatThreadsBox);
    await box.put(documentId, jsonEncode(thread.toJson()));
  }

  Future<String?> getDocumentContent(String documentId) async {
    final box = await Hive.openBox<String>(_documentsBox);
    return box.get(documentId);
  }

  Future<void> saveProjectSettings(ProjectSettings settings) async {
    final box = Hive.box<String>(_settingsBox);
    await box.put('settings', jsonEncode(settings.toJson()));
  }

  Future<ProjectSettings?> loadProjectSettings() async {
    final box = Hive.box<String>(_settingsBox);
    final settingsJson = box.get('settings');
    if (settingsJson == null) return null;

    final settingsData = jsonDecode(settingsJson);
    return ProjectSettings.fromJson(settingsData);
  }
}
