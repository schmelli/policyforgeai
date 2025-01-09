import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/project.dart';
import '../models/chat.dart';
import '../models/settings.dart';
import '../models/document.dart';
import '../utils/logger.dart';

/// Service for handling persistent storage using Hive
class StorageService {
  static const String _projectsBox = 'projects';
  static const String _documentsBox = 'documents';
  static const String _projectTreeBox = 'project_tree';
  static const String _chatThreadsBox = 'chat_threads';
  static const String _settingsBox = 'settings';

  /// Initialize storage service and open required boxes
  Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_projectsBox);
    await Hive.openBox(_documentsBox);
    await Hive.openBox(_projectTreeBox);
    await Hive.openBox<String>(_chatThreadsBox);
    await Hive.openBox<String>(_settingsBox);
  }

  /// Save a project to storage
  Future<void> saveProject(Project project) async {
    final box = Hive.box(_projectsBox);
    appLogger.d('Saving project: ${project.id}');
    await box.put(project.id, jsonEncode(project.toJson()));
  }

  /// Load a project from storage by ID
  Future<Project?> loadProject(String projectId) async {
    final box = Hive.box(_projectsBox);
    appLogger.d('Loading project: $projectId');
    final projectJson = box.get(projectId);
    if (projectJson == null) return null;

    try {
      final projectData = jsonDecode(projectJson);
      final project = Project.fromJson(projectData);

      // Load the project tree separately since it's stored in a different box
      final tree = await loadProjectTree(projectId);
      return project.copyWith(rootNodes: tree);
    } catch (e) {
      appLogger.e('Error loading project: $e');
      return null;
    }
  }

  /// List all projects in storage
  Future<List<Project>> listProjects() async {
    final box = Hive.box(_projectsBox);
    final projects = <Project>[];

    for (final key in box.keys) {
      try {
        final project = await loadProject(key.toString());
        if (project != null) {
          projects.add(project);
        }
      } catch (e) {
        appLogger.e('Error loading project $key: $e');
        continue;
      }
    }

    return projects;
  }

  /// Save a document to storage
  Future<void> saveDocument(String projectId, PolicyDocument document) async {
    final box = Hive.box(_documentsBox);
    appLogger.d('Saving document: ${document.id}');
    await box.put('$projectId/${document.id}', jsonEncode(document.toJson()));
  }

  /// Load a document from storage by project ID and document ID
  Future<PolicyDocument?> loadDocument(
      String projectId, String documentId) async {
    final box = Hive.box(_documentsBox);
    appLogger.d('Loading document: $documentId');
    final documentJson = box.get('$projectId/$documentId');
    if (documentJson == null) return null;

    try {
      final documentData = jsonDecode(documentJson);
      return PolicyDocument.fromJson(documentData);
    } catch (e) {
      appLogger.e('Error loading document: $e');
      return null;
    }
  }

  /// Save a project's document tree to storage
  Future<void> saveProjectTree(
      String projectId, List<DocumentNode> nodes) async {
    final box = Hive.box(_projectTreeBox);
    appLogger.d('Saving project tree: $projectId');
    final treeData = nodes.map((node) => node.toJson()).toList();
    await box.put(projectId, jsonEncode(treeData));
  }

  /// Load a project's document tree from storage
  Future<List<DocumentNode>> loadProjectTree(String projectId) async {
    final box = Hive.box(_projectTreeBox);
    appLogger.d('Loading project tree: $projectId');
    final treeJson = box.get(projectId);
    if (treeJson == null) return [];

    try {
      final treeData = jsonDecode(treeJson) as List<dynamic>;
      return treeData
          .map((node) => DocumentNode.fromJson(node as Map<String, dynamic>))
          .toList();
    } catch (e) {
      appLogger.e('Error loading project tree: $e');
      return [];
    }
  }

  /// Load a chat thread from storage by document ID
  Future<ChatThread?> loadChatThread(String documentId) async {
    final box = Hive.box<String>(_chatThreadsBox);
    final threadJson = box.get(documentId);
    if (threadJson == null) return null;

    try {
      final threadData = jsonDecode(threadJson);
      return ChatThread.fromJson(threadData);
    } catch (e) {
      appLogger.e('Error loading chat thread: $e');
      return null;
    }
  }

  /// Save a chat thread to storage
  Future<void> saveChatThread(String documentId, ChatThread thread) async {
    final box = Hive.box<String>(_chatThreadsBox);
    await box.put(documentId, jsonEncode(thread.toJson()));
  }

  /// Clear the chat thread for a document
  Future<void> clearChatThread(String documentId) async {
    final box = Hive.box<String>(_chatThreadsBox);
    await box.delete(documentId);
  }

  /// Load project settings from storage
  Future<ProjectSettings?> loadProjectSettings(String projectId) async {
    final box = Hive.box<String>(_settingsBox);
    final settingsJson = box.get('settings_$projectId');
    if (settingsJson == null) return null;

    try {
      final settingsData = jsonDecode(settingsJson);
      return ProjectSettings.fromJson(settingsData);
    } catch (e) {
      appLogger.e('Error loading project settings: $e');
      return null;
    }
  }

  /// Save project settings to storage
  Future<void> saveProjectSettings(
      String projectId, ProjectSettings settings) async {
    final box = Hive.box<String>(_settingsBox);
    await box.put('settings_$projectId', jsonEncode(settings.toJson()));
  }

  /// Delete a project and all its associated data
  Future<void> deleteProject(String projectId) async {
    final projectBox = Hive.box(_projectsBox);
    final documentsBox = Hive.box(_documentsBox);
    final treeBox = Hive.box(_projectTreeBox);
    final chatBox = Hive.box<String>(_chatThreadsBox);
    final settingsBox = Hive.box<String>(_settingsBox);

    // Delete project data
    await projectBox.delete(projectId);
    await treeBox.delete(projectId);
    await settingsBox.delete('settings_$projectId');

    // Delete all documents associated with the project
    final projectDocKeys = documentsBox.keys
        .where((key) => key.toString().startsWith('$projectId/'));
    for (final key in projectDocKeys) {
      await documentsBox.delete(key);
    }

    // Delete all chat threads associated with the project's documents
    final projectChatKeys =
        chatBox.keys.where((key) => key.toString().startsWith('$projectId/'));
    for (final key in projectChatKeys) {
      await chatBox.delete(key);
    }
  }

  /// Load document content from storage
  Future<String?> loadDocumentContent(
      String projectId, String documentId) async {
    final document = await loadDocument(projectId, documentId);
    return document?.content;
  }

  /// Save document content to storage
  Future<void> saveDocumentContent(
      String projectId, String documentId, String content) async {
    final document = await loadDocument(projectId, documentId);
    if (document != null) {
      final updatedDocument = document.copyWith(
        content: content,
        modifiedAt: DateTime.now(),
      );
      await saveDocument(projectId, updatedDocument);
    }
  }
}
