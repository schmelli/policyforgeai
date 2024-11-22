import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Represents a policy document in the system
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
    this.version = 1,
  });

  /// Creates a new empty document
  factory PolicyDocument.create({
    required String title,
    required String createdBy,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return PolicyDocument(
      id: const Uuid().v4(),
      title: title,
      content: '',
      createdAt: now,
      modifiedAt: now,
      createdBy: createdBy,
      lastModifiedBy: createdBy,
      tags: tags,
      status: DocumentStatus.draft,
      metadata: DocumentMetadata.empty(),
      versions: [],
      comments: [],
      permissions: DocumentPermissions.defaults(createdBy),
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
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'createdBy': createdBy,
        'lastModifiedBy': lastModifiedBy,
        'tags': tags,
        'status': status.toString().split('.').last,
        'metadata': metadata.toJson(),
        'versions': versions.map((v) => v.toJson()).toList(),
        'comments': comments.map((c) => c.toJson()).toList(),
        'permissions': permissions.toJson(),
        'version': version,
      };

  factory PolicyDocument.fromJson(Map<String, dynamic> json) {
    return PolicyDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      lastModifiedBy: json['lastModifiedBy'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => DocumentStatus.draft,
      ),
      metadata: json['metadata'] != null
          ? DocumentMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : DocumentMetadata.empty(),
      versions: (json['versions'] as List<dynamic>?)
              ?.map((e) => DocumentVersion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => DocumentComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      permissions: json['permissions'] != null
          ? DocumentPermissions.fromJson(json['permissions'] as Map<String, dynamic>)
          : DocumentPermissions.defaults(json['createdBy'] as String),
      version: json['version'] as int? ?? 1,
    );
  }

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
  deleted
}

/// Metadata associated with a policy document
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

  Map<String, dynamic> toJson() => {
        'description': description,
        'category': category,
        'department': department,
        'customFields': customFields,
      };

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) {
    return DocumentMetadata(
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      department: json['department'] as String? ?? '',
      customFields: json['customFields'] as Map<String, dynamic>? ?? const {},
    );
  }

  @override
  List<Object?> get props => [description, category, department, customFields];
}

/// Represents a version of a document
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'comment': comment,
        'versionNumber': versionNumber,
      };

  factory DocumentVersion.fromJson(Map<String, dynamic> json) {
    return DocumentVersion(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      comment: json['comment'] as String? ?? '',
      versionNumber: json['versionNumber'] as int,
    );
  }

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'selection': selection?.toJson(),
        'replies': replies.map((r) => r.toJson()).toList(),
      };

  factory DocumentComment.fromJson(Map<String, dynamic> json) {
    return DocumentComment(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      selection: json['selection'] != null
          ? DocumentSelection.fromJson(json['selection'] as Map<String, dynamic>)
          : null,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => DocumentComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

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
class DocumentSelection extends Equatable {
  final int startOffset;
  final int endOffset;
  final String selectedText;

  const DocumentSelection({
    required this.startOffset,
    required this.endOffset,
    required this.selectedText,
  });

  Map<String, dynamic> toJson() => {
        'startOffset': startOffset,
        'endOffset': endOffset,
        'selectedText': selectedText,
      };

  factory DocumentSelection.fromJson(Map<String, dynamic> json) {
    return DocumentSelection(
      startOffset: json['startOffset'] as int,
      endOffset: json['endOffset'] as int,
      selectedText: json['selectedText'] as String,
    );
  }

  @override
  List<Object?> get props => [startOffset, endOffset, selectedText];
}

/// Represents document permissions
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

  Map<String, dynamic> toJson() => {
        'owner': owner,
        'editors': editors,
        'viewers': viewers,
        'commenters': commenters,
        'isPublic': isPublic,
        'customRoles': customRoles,
      };

  factory DocumentPermissions.fromJson(Map<String, dynamic> json) {
    return DocumentPermissions(
      owner: json['owner'] as String,
      editors: (json['editors'] as List<dynamic>?)?.cast<String>() ?? const [],
      viewers: (json['viewers'] as List<dynamic>?)?.cast<String>() ?? const [],
      commenters: (json['commenters'] as List<dynamic>?)?.cast<String>() ?? const [],
      isPublic: json['isPublic'] as bool? ?? false,
      customRoles: (json['customRoles'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as List<dynamic>).cast<String>()),
          ) ??
          const {},
    );
  }

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
