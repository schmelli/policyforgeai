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
      metadata: DocumentMetadata.initial(),
      versions: const [],
      comments: const [],
      permissions: DocumentPermissions.defaultPermissions(),
      version: 1,
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

  PolicyDocument copyWith({
    String? title,
    String? content,
    DateTime? modifiedAt,
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
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      createdBy: createdBy,
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
      tags: List<String>.from(json['tags'] as List),
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      metadata: DocumentMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      versions: (json['versions'] as List<dynamic>)
          .map((v) => DocumentVersion.fromJson(v as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>)
          .map((c) => DocumentComment.fromJson(c as Map<String, dynamic>))
          .toList(),
      permissions: DocumentPermissions.fromJson(json['permissions'] as Map<String, dynamic>),
      version: json['version'] as int? ?? 1,
    );
  }
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
class DocumentMetadata extends Equatable {
  final String projectId;
  final int wordCount;
  final int characterCount;
  final double readabilityScore;
  final Map<String, dynamic> aiAnalysis;
  final Map<String, String> customFields;

  const DocumentMetadata({
    required this.projectId,
    required this.wordCount,
    required this.characterCount,
    required this.readabilityScore,
    required this.aiAnalysis,
    required this.customFields,
  });

  factory DocumentMetadata.initial() {
    return const DocumentMetadata(
      projectId: '',
      wordCount: 0,
      characterCount: 0,
      readabilityScore: 0,
      aiAnalysis: {},
      customFields: {},
    );
  }

  @override
  List<Object?> get props => [
        projectId,
        wordCount,
        characterCount,
        readabilityScore,
        aiAnalysis,
        customFields,
      ];

  Map<String, dynamic> toJson() => {
        'projectId': projectId,
        'wordCount': wordCount,
        'characterCount': characterCount,
        'readabilityScore': readabilityScore,
        'aiAnalysis': aiAnalysis,
        'customFields': customFields,
      };

  factory DocumentMetadata.fromJson(Map<String, dynamic> json) {
    return DocumentMetadata(
      projectId: json['projectId'] as String,
      wordCount: json['wordCount'] as int,
      characterCount: json['characterCount'] as int,
      readabilityScore: (json['readabilityScore'] as num).toDouble(),
      aiAnalysis: Map<String, dynamic>.from(json['aiAnalysis'] as Map),
      customFields: Map<String, String>.from(json['customFields'] as Map),
    );
  }
}

/// Represents a version of a document
class DocumentVersion extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;
  final String createdBy;
  final String message;
  final String branch;
  final String? parentVersionId;

  const DocumentVersion({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    required this.message,
    required this.branch,
    this.parentVersionId,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        createdAt,
        createdBy,
        message,
        branch,
        parentVersionId,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'message': message,
        'branch': branch,
        'parentVersionId': parentVersionId,
      };

  factory DocumentVersion.fromJson(Map<String, dynamic> json) {
    return DocumentVersion(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      message: json['message'] as String,
      branch: json['branch'] as String,
      parentVersionId: json['parentVersionId'] as String?,
    );
  }
}

/// Represents a comment on a document
class DocumentComment extends Equatable {
  final String id;
  final String content;
  final DateTime createdAt;
  final String createdBy;
  final String? parentCommentId;
  final bool resolved;
  final DocumentSelection selection;

  const DocumentComment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
    this.parentCommentId,
    this.resolved = false,
    required this.selection,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        createdAt,
        createdBy,
        parentCommentId,
        resolved,
        selection,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'parentCommentId': parentCommentId,
        'resolved': resolved,
        'selection': selection.toJson(),
      };

  factory DocumentComment.fromJson(Map<String, dynamic> json) {
    return DocumentComment(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      parentCommentId: json['parentCommentId'] as String?,
      resolved: json['resolved'] as bool? ?? false,
      selection: DocumentSelection.fromJson(json['selection'] as Map<String, dynamic>),
    );
  }
}

/// Represents text selection in a document
class DocumentSelection extends Equatable {
  final int start;
  final int end;

  const DocumentSelection({
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [start, end];

  Map<String, dynamic> toJson() => {
        'start': start,
        'end': end,
      };

  factory DocumentSelection.fromJson(Map<String, dynamic> json) {
    return DocumentSelection(
      start: json['start'] as int,
      end: json['end'] as int,
    );
  }
}

/// Represents document permissions
class DocumentPermissions extends Equatable {
  final List<String> readers;
  final List<String> writers;
  final List<String> reviewers;
  final List<String> owners;
  final bool isPublic;
  final DateTime? expiresAt;
  final String? password;
  final bool enableComments;
  final bool trackViews;

  const DocumentPermissions({
    required this.readers,
    required this.writers,
    required this.reviewers,
    required this.owners,
    required this.isPublic,
    this.expiresAt,
    this.password,
    required this.enableComments,
    required this.trackViews,
  });

  factory DocumentPermissions.defaultPermissions() {
    return const DocumentPermissions(
      readers: [],
      writers: [],
      reviewers: [],
      owners: [],
      isPublic: false,
      enableComments: true,
      trackViews: true,
    );
  }

  @override
  List<Object?> get props => [
        readers,
        writers,
        reviewers,
        owners,
        isPublic,
        expiresAt,
        password,
        enableComments,
        trackViews,
      ];

  Map<String, dynamic> toJson() => {
        'readers': readers,
        'writers': writers,
        'reviewers': reviewers,
        'owners': owners,
        'isPublic': isPublic,
        'expiresAt': expiresAt?.toIso8601String(),
        'password': password,
        'enableComments': enableComments,
        'trackViews': trackViews,
      };

  factory DocumentPermissions.fromJson(Map<String, dynamic> json) {
    return DocumentPermissions(
      readers: List<String>.from(json['readers'] as List),
      writers: List<String>.from(json['writers'] as List),
      reviewers: List<String>.from(json['reviewers'] as List),
      owners: List<String>.from(json['owners'] as List),
      isPublic: json['isPublic'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      password: json['password'] as String?,
      enableComments: json['enableComments'] as bool? ?? true,
      trackViews: json['trackViews'] as bool? ?? true,
    );
  }
}
