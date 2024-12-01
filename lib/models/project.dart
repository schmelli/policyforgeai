import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'document.dart';
import 'settings.dart';

part 'project.g.dart';

/// Represents a project in the system
@JsonSerializable(explicitToJson: true)
class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String createdBy;
  @JsonKey(toJson: _nodesToJson, fromJson: _nodesFromJson)
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

  /// Creates a new project with default settings
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

  /// Creates a copy of this project with the given fields replaced
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

  /// Converts this project to a JSON map
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  /// Creates a project from a JSON map
  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  static List<Map<String, dynamic>> _nodesToJson(List<DocumentNode> nodes) {
    return nodes.map((node) => node.toJson()).toList();
  }

  static List<DocumentNode> _nodesFromJson(List<dynamic> json) {
    return json.map((node) => DocumentNode.fromJson(node as Map<String, dynamic>)).toList();
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
  final String? parentId;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String createdBy;

  const DocumentNode({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
    required this.modifiedAt,
    required this.createdBy,
  });

  /// Creates a node from a JSON map
  static DocumentNode fromJson(Map<String, dynamic> json) {
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

  /// Converts this node to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'createdBy': createdBy,
      'type': _getNodeType(),
    };
  }

  String _getNodeType() {
    if (this is FolderNode) return 'folder';
    if (this is DocumentLeafNode) return 'document';
    throw Exception('Unknown node type: ${runtimeType.toString()}');
  }

  @override
  List<Object?> get props => [id, name, parentId, createdAt, modifiedAt, createdBy];
}

/// Represents a folder in the document tree
@JsonSerializable(explicitToJson: true)
class FolderNode extends DocumentNode {
  @JsonKey(toJson: Project._nodesToJson, fromJson: Project._nodesFromJson)
  final List<DocumentNode> children;

  const FolderNode({
    required super.id,
    required super.name,
    super.parentId,
    required super.createdAt,
    required super.modifiedAt,
    required super.createdBy,
    required this.children,
  });

  /// Creates a new folder node
  factory FolderNode.create({
    required String name,
    required String createdBy,
    String? parentId,
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

  /// Creates a copy of this folder with the given fields replaced
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

  /// Converts this folder to a JSON map
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll(_$FolderNodeToJson(this));
    return json;
  }

  /// Creates a folder from a JSON map
  factory FolderNode.fromJson(Map<String, dynamic> json) {
    final node = _$FolderNodeFromJson(json);
    return node;
  }

  @override
  List<Object?> get props => [...super.props, children];
}

/// Represents a document in the document tree
@JsonSerializable(explicitToJson: true)
class DocumentLeafNode extends DocumentNode {
  final PolicyDocument document;

  const DocumentLeafNode({
    required super.id,
    required super.name,
    super.parentId,
    required super.createdAt,
    required super.modifiedAt,
    required super.createdBy,
    required this.document,
  });

  /// Creates a new document node
  factory DocumentLeafNode.create({
    required String name,
    required String createdBy,
    required String projectId,
    String? parentId,
  }) {
    final now = DateTime.now();
    final id = const Uuid().v4();
    return DocumentLeafNode(
      id: id,
      name: name,
      parentId: parentId,
      createdAt: now,
      modifiedAt: now,
      createdBy: createdBy,
      document: PolicyDocument.create(
        title: name,
        createdBy: createdBy,
        projectId: projectId,
      ),
    );
  }

  /// Creates a copy of this document node with the given fields replaced
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

  /// Whether this document is read-only for the current user
  bool get readOnly {
    // TODO: Get current user ID from auth service
    const currentUserId = '';
    final permissions = document.permissions;
    
    // Owner and editors have write access
    if (permissions.owner == currentUserId || 
        permissions.editors.contains(currentUserId)) {
      return false;
    }
    
    // All other users (viewers, commenters) have read-only access
    return true;
  }

  /// Converts this document node to a JSON map
  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll(_$DocumentLeafNodeToJson(this));
    return json;
  }

  /// Creates a document node from a JSON map
  factory DocumentLeafNode.fromJson(Map<String, dynamic> json) {
    final node = _$DocumentLeafNodeFromJson(json);
    return node;
  }

  @override
  List<Object?> get props => [...super.props, document];
}
