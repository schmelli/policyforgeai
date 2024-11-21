import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'document.dart';

/// Represents a project in the system
class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String createdBy;
  final List<DocumentNode> rootNodes;
  final ProjectSettings settings;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.modifiedAt,
    required this.createdBy,
    required this.rootNodes,
    required this.settings,
  });

  factory Project.create({
    required String name,
    required String description,
    required String createdBy,
  }) {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdAt: now,
      modifiedAt: now,
      createdBy: createdBy,
      rootNodes: const [],
      settings: ProjectSettings.defaults(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdAt,
        modifiedAt,
        createdBy,
        rootNodes,
        settings,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'createdBy': createdBy,
        'settings': settings.toJson(),
      };

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      rootNodes: const [],  // Note: rootNodes are loaded separately via loadProjectTree
      settings: ProjectSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );
  }
}

/// Settings specific to a project
class ProjectSettings extends Equatable {
  final String defaultBranch;
  final bool enableAIFeatures;
  final bool enableCollaboration;
  final Map<String, dynamic> aiSettings;
  final Map<String, dynamic> customSettings;

  const ProjectSettings({
    required this.defaultBranch,
    required this.enableAIFeatures,
    required this.enableCollaboration,
    required this.aiSettings,
    required this.customSettings,
  });

  factory ProjectSettings.defaults() {
    return const ProjectSettings(
      defaultBranch: 'main',
      enableAIFeatures: true,
      enableCollaboration: true,
      aiSettings: {},
      customSettings: {},
    );
  }

  @override
  List<Object?> get props => [
        defaultBranch,
        enableAIFeatures,
        enableCollaboration,
        aiSettings,
        customSettings,
      ];

  Map<String, dynamic> toJson() => {
        'defaultBranch': defaultBranch,
        'enableAIFeatures': enableAIFeatures,
        'enableCollaboration': enableCollaboration,
        'aiSettings': aiSettings,
        'customSettings': customSettings,
      };

  factory ProjectSettings.fromJson(Map<String, dynamic> json) {
    return ProjectSettings(
      defaultBranch: json['defaultBranch'] as String? ?? 'main',
      enableAIFeatures: json['enableAIFeatures'] as bool? ?? true,
      enableCollaboration: json['enableCollaboration'] as bool? ?? true,
      aiSettings: Map<String, dynamic>.from(json['aiSettings'] as Map? ?? {}),
      customSettings: Map<String, dynamic>.from(json['customSettings'] as Map? ?? {}),
    );
  }
}

/// Represents a node in the document tree
abstract class DocumentNode extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String createdBy;
  final String? parentId;

  const DocumentNode({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.modifiedAt,
    required this.createdBy,
    this.parentId,
  });

  bool get isFolder;
  bool get isDocument;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'modifiedAt': modifiedAt.toIso8601String(),
    'createdBy': createdBy,
    'parentId': parentId,
  };
}

/// Represents a folder in the document tree
class FolderNode extends DocumentNode {
  final List<DocumentNode> children;

  const FolderNode({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.modifiedAt,
    required super.createdBy,
    super.parentId,
    required this.children,
  });

  factory FolderNode.create({
    required String name,
    required String createdBy,
    String? parentId,
  }) {
    final now = DateTime.now();
    return FolderNode(
      id: const Uuid().v4(),
      name: name,
      createdAt: now,
      modifiedAt: now,
      createdBy: createdBy,
      parentId: parentId,
      children: const [],
    );
  }

  @override
  bool get isFolder => true;

  @override
  bool get isDocument => false;

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        modifiedAt,
        createdBy,
        parentId,
        children,
      ];

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'type': 'folder',
        'children': children.map((c) => c.toJson()).toList(),
      };

  factory FolderNode.fromJson(Map<String, dynamic> json) {
    return FolderNode(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      parentId: json['parentId'] as String?,
      children: (json['children'] as List<dynamic>)
          .map((c) => c['type'] == 'folder'
              ? FolderNode.fromJson(c as Map<String, dynamic>)
              : DocumentLeafNode.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents a document in the document tree
class DocumentLeafNode extends DocumentNode {
  final PolicyDocument document;

  const DocumentLeafNode({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.modifiedAt,
    required super.createdBy,
    super.parentId,
    required this.document,
  });

  factory DocumentLeafNode.create({
    required String name,
    required String createdBy,
    String? parentId,
  }) {
    final now = DateTime.now();
    return DocumentLeafNode(
      id: const Uuid().v4(),
      name: name,
      createdAt: now,
      modifiedAt: now,
      createdBy: createdBy,
      parentId: parentId,
      document: PolicyDocument.create(
        title: name,
        createdBy: createdBy,
      ),
    );
  }

  @override
  bool get isFolder => false;

  @override
  bool get isDocument => true;

  @override
  List<Object?> get props => [
        id,
        name,
        createdAt,
        modifiedAt,
        createdBy,
        parentId,
        document,
      ];

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'type': 'document',
        'document': document.toJson(),
      };

  factory DocumentLeafNode.fromJson(Map<String, dynamic> json) {
    return DocumentLeafNode(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      parentId: json['parentId'] as String?,
      document: PolicyDocument.fromJson(json['document'] as Map<String, dynamic>),
    );
  }
}
