import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

part 'document.g.dart';

/// Represents a policy document in the system
@JsonSerializable()
class PolicyDocument extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String createdBy;
  final String lastModifiedBy;
  final List<String> tags;
  final DocumentStatus status;
  final DocumentMetadata metadata;
  final List<DocumentVersion> versions;
  final List<DocumentComment> comments;
  final DocumentPermissions permissions;
  final int version;
  final String projectId;

  const PolicyDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    required this.createdBy,
    required this.lastModifiedBy,
    required this.tags,
    required this.status,
    required this.metadata,
    required this.versions,
    required this.comments,
    required this.permissions,
    required this.projectId,
    this.version = 1,
  });

  /// Creates a new empty document
  factory PolicyDocument.create({
    required String title,
    required String createdBy,
    required String projectId,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    final emptyContent = jsonEncode([{"insert": "\n"}]);
    return PolicyDocument(
      id: const Uuid().v4(),
      title: title,
      content: emptyContent,
      createdAt: now,
      modifiedAt: now,
      createdBy: createdBy,
      lastModifiedBy: createdBy,
      tags: tags,
      status: DocumentStatus.draft,
      metadata: DocumentMetadata.empty(),
      versions: const [],
      comments: const [],
      permissions: DocumentPermissions.defaults(createdBy),
      projectId: projectId,
    );
  }

  PolicyDocument copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? createdBy,
    String? lastModifiedBy,
    List<String>? tags,
    DocumentStatus? status,
    DocumentMetadata? metadata,
    List<DocumentVersion>? versions,
    List<DocumentComment>? comments,
    DocumentPermissions? permissions,
    String? projectId,
    int? version,
  }) {
    return PolicyDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      createdBy: createdBy ?? this.createdBy,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      versions: versions ?? this.versions,
      comments: comments ?? this.comments,
      permissions: permissions ?? this.permissions,
      projectId: projectId ?? this.projectId,
      version: version ?? this.version,
    );
  }

  /// Converts this document to a JSON map
  Map<String, dynamic> toJson() => _$PolicyDocumentToJson(this);

  /// Creates a document from a JSON map
  factory PolicyDocument.fromJson(Map<String, dynamic> json) =>
      _$PolicyDocumentFromJson(json);

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        createdAt,
        modifiedAt,
        createdBy,
        lastModifiedBy,
        tags,
        status,
        metadata,
        versions,
        comments,
        permissions,
        projectId,
        version,
      ];
}

/// Status of a policy document
enum DocumentStatus {
  draft,
  inReview,
  approved,
  published,
  archived,
  deprecated
}

/// Metadata associated with a policy document
@JsonSerializable()
class DocumentMetadata extends Equatable {
  final String description;
  final String category;
  final String department;
  final Map<String, dynamic> customFields;

  const DocumentMetadata({
    required this.description,
    required this.category,
    required this.department,
    this.customFields = const {},
  });

  /// Creates an empty metadata instance
  factory DocumentMetadata.empty() {
    return const DocumentMetadata(
      description: '',
      category: '',
      department: '',
    );
  }

  DocumentMetadata copyWith({
    String? description,
    String? category,
    String? department,
    Map<String, dynamic>? customFields,
  }) {
    return DocumentMetadata(
      description: description ?? this.description,
      category: category ?? this.category,
      department: department ?? this.department,
      customFields: customFields ?? this.customFields,
    );
  }

  /// Converts this metadata to a JSON map
  Map<String, dynamic> toJson() => _$DocumentMetadataToJson(this);

  /// Creates a metadata instance from a JSON map
  factory DocumentMetadata.fromJson(Map<String, dynamic> json) =>
      _$DocumentMetadataFromJson(json);

  @override
  List<Object?> get props => [
        description,
        category,
        department,
        customFields,
      ];
}

/// Represents a version of a document
@JsonSerializable()
class DocumentVersion extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;
  final String createdBy;
  final String comment;
  final int versionNumber;

  const DocumentVersion({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    required this.comment,
    required this.versionNumber,
  });

  DocumentVersion copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    String? createdBy,
    String? comment,
    int? versionNumber,
  }) {
    return DocumentVersion(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      comment: comment ?? this.comment,
      versionNumber: versionNumber ?? this.versionNumber,
    );
  }

  /// Converts this version to a JSON map
  Map<String, dynamic> toJson() => _$DocumentVersionToJson(this);

  /// Creates a version from a JSON map
  factory DocumentVersion.fromJson(Map<String, dynamic> json) =>
      _$DocumentVersionFromJson(json);

  @override
  List<Object?> get props => [
        id,
        content,
        createdAt,
        createdBy,
        comment,
        versionNumber,
      ];
}

/// Represents a comment on a document
@JsonSerializable()
class DocumentComment extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;
  final String createdBy;
  final DocumentSelection? selection;
  final List<DocumentComment> replies;

  const DocumentComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    this.selection,
    this.replies = const [],
  });

  DocumentComment copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    String? createdBy,
    DocumentSelection? selection,
    List<DocumentComment>? replies,
  }) {
    return DocumentComment(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      selection: selection ?? this.selection,
      replies: replies ?? this.replies,
    );
  }

  /// Converts this comment to a JSON map
  Map<String, dynamic> toJson() => _$DocumentCommentToJson(this);

  /// Creates a comment from a JSON map
  factory DocumentComment.fromJson(Map<String, dynamic> json) =>
      _$DocumentCommentFromJson(json);

  @override
  List<Object?> get props => [
        id,
        content,
        createdAt,
        createdBy,
        selection,
        replies,
      ];
}

/// Represents text selection in a document
@JsonSerializable()
class DocumentSelection extends Equatable {
  final int startOffset;
  final int endOffset;
  final String selectedText;

  const DocumentSelection({
    required this.startOffset,
    required this.endOffset,
    required this.selectedText,
  });

  /// Converts this selection to a JSON map
  Map<String, dynamic> toJson() => _$DocumentSelectionToJson(this);

  /// Creates a selection from a JSON map
  factory DocumentSelection.fromJson(Map<String, dynamic> json) =>
      _$DocumentSelectionFromJson(json);

  @override
  List<Object?> get props => [
        startOffset,
        endOffset,
        selectedText,
      ];
}

/// Represents document permissions
@JsonSerializable()
class DocumentPermissions extends Equatable {
  final String owner;
  final List<String> editors;
  final List<String> viewers;
  final List<String> commenters;
  final bool isPublic;
  final Map<String, List<String>> customRoles;

  const DocumentPermissions({
    required this.owner,
    this.editors = const [],
    this.viewers = const [],
    this.commenters = const [],
    this.isPublic = false,
    this.customRoles = const {},
  });

  /// Creates default permissions for a document
  factory DocumentPermissions.defaults(String owner) {
    return DocumentPermissions(owner: owner);
  }

  DocumentPermissions copyWith({
    String? owner,
    List<String>? editors,
    List<String>? viewers,
    List<String>? commenters,
    bool? isPublic,
    Map<String, List<String>>? customRoles,
  }) {
    return DocumentPermissions(
      owner: owner ?? this.owner,
      editors: editors ?? this.editors,
      viewers: viewers ?? this.viewers,
      commenters: commenters ?? this.commenters,
      isPublic: isPublic ?? this.isPublic,
      customRoles: customRoles ?? this.customRoles,
    );
  }

  /// Converts these permissions to a JSON map
  Map<String, dynamic> toJson() => _$DocumentPermissionsToJson(this);

  /// Creates permissions from a JSON map
  factory DocumentPermissions.fromJson(Map<String, dynamic> json) =>
      _$DocumentPermissionsFromJson(json);

  @override
  List<Object?> get props => [
        owner,
        editors,
        viewers,
        commenters,
        isPublic,
        customRoles,
      ];
}
