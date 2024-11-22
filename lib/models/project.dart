import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'document.dart';
import 'settings.dart';

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

  Project copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? createdBy,
    List<DocumentNode>? rootNodes,
    ProjectSettings? settings,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      createdBy: createdBy ?? this.createdBy,
      rootNodes: rootNodes ?? this.rootNodes,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'createdBy': createdBy,
      'rootNodes': rootNodes.map((node) => node.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      rootNodes: (json['rootNodes'] as List<dynamic>)
          .map((node) => DocumentNode.fromJson(node as Map<String, dynamic>))
          .toList(),
      settings: ProjectSettings.fromJson(json['settings'] as Map<String, dynamic>),
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
}

/// Represents a node in the document tree
abstract class DocumentNode extends Equatable {
  final String id;
  final String name;
  final String parentId;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String createdBy;

  const DocumentNode({
    required this.id,
    required this.name,
    required this.parentId,
    required this.createdAt,
    required this.modifiedAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson();

  factory DocumentNode.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'folder':
        return FolderNode.fromJson(json);
      case 'document':
        return DocumentLeafNode.fromJson(json);
      default:
        throw Exception('Unknown node type: $type');
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        parentId,
        createdAt,
        modifiedAt,
        createdBy,
      ];
}

/// Represents a folder in the document tree
class FolderNode extends DocumentNode {
  final List<DocumentNode> children;

  const FolderNode({
    required super.id,
    required super.name,
    required super.parentId,
    required super.createdAt,
    required super.modifiedAt,
    required super.createdBy,
    required this.children,
  });

  factory FolderNode.create({
    required String name,
    required String parentId,
    required String createdBy,
  }) {
    final now = DateTime.now();
    return FolderNode(
      id: const Uuid().v4(),
      name: name,
      parentId: parentId,
      createdAt: now,
      modifiedAt: now,
      createdBy: createdBy,
      children: const [],
    );
  }

  @override
  FolderNode copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? createdBy,
    List<DocumentNode>? children,
  }) {
    return FolderNode(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      createdBy: createdBy ?? this.createdBy,
      children: children ?? this.children,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'folder',
      'id': id,
      'name': name,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'createdBy': createdBy,
      'children': children.map((node) => node.toJson()).toList(),
    };
  }

  factory FolderNode.fromJson(Map<String, dynamic> json) {
    return FolderNode(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      children: (json['children'] as List<dynamic>)
          .map((node) => DocumentNode.fromJson(node as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        children,
      ];
}

/// Represents a document in the document tree
class DocumentLeafNode extends DocumentNode {
  final PolicyDocument? document;

  const DocumentLeafNode({
    required super.id,
    required super.name,
    required super.parentId,
    required super.createdAt,
    required super.modifiedAt,
    required super.createdBy,
    this.document,
  });

  factory DocumentLeafNode.create({
    required String name,
    required String parentId,
    required String createdBy,
  }) {
    final now = DateTime.now();
    return DocumentLeafNode(
      id: const Uuid().v4(),
      name: name,
      parentId: parentId,
      createdAt: now,
      modifiedAt: now,
      createdBy: createdBy,
    );
  }

  @override
  DocumentLeafNode copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? createdBy,
    PolicyDocument? document,
  }) {
    return DocumentLeafNode(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      createdBy: createdBy ?? this.createdBy,
      document: document ?? this.document,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'document',
      'id': id,
      'name': name,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'createdBy': createdBy,
      'document': document?.toJson(),
    };
  }

  factory DocumentLeafNode.fromJson(Map<String, dynamic> json) {
    return DocumentLeafNode(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      document: json['document'] == null
          ? null
          : PolicyDocument.fromJson(json['document'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        document,
      ];
}
