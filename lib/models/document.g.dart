// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PolicyDocument _$PolicyDocumentFromJson(Map<String, dynamic> json) =>
    PolicyDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      lastModifiedBy: json['lastModifiedBy'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      status: $enumDecode(_$DocumentStatusEnumMap, json['status']),
      metadata:
          DocumentMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
      versions: (json['versions'] as List<dynamic>)
          .map((e) => DocumentVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => DocumentComment.fromJson(e as Map<String, dynamic>))
          .toList(),
      permissions: DocumentPermissions.fromJson(
          json['permissions'] as Map<String, dynamic>),
      projectId: json['projectId'] as String,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$PolicyDocumentToJson(PolicyDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'modifiedAt': instance.modifiedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'lastModifiedBy': instance.lastModifiedBy,
      'tags': instance.tags,
      'status': _$DocumentStatusEnumMap[instance.status]!,
      'metadata': instance.metadata,
      'versions': instance.versions,
      'comments': instance.comments,
      'permissions': instance.permissions,
      'version': instance.version,
      'projectId': instance.projectId,
    };

const _$DocumentStatusEnumMap = {
  DocumentStatus.draft: 'draft',
  DocumentStatus.inReview: 'inReview',
  DocumentStatus.approved: 'approved',
  DocumentStatus.published: 'published',
  DocumentStatus.archived: 'archived',
  DocumentStatus.deprecated: 'deprecated',
};

DocumentMetadata _$DocumentMetadataFromJson(Map<String, dynamic> json) =>
    DocumentMetadata(
      description: json['description'] as String,
      category: json['category'] as String,
      department: json['department'] as String,
      customFields: json['customFields'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$DocumentMetadataToJson(DocumentMetadata instance) =>
    <String, dynamic>{
      'description': instance.description,
      'category': instance.category,
      'department': instance.department,
      'customFields': instance.customFields,
    };

DocumentVersion _$DocumentVersionFromJson(Map<String, dynamic> json) =>
    DocumentVersion(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      comment: json['comment'] as String,
      versionNumber: (json['versionNumber'] as num).toInt(),
    );

Map<String, dynamic> _$DocumentVersionToJson(DocumentVersion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'comment': instance.comment,
      'versionNumber': instance.versionNumber,
    };

DocumentComment _$DocumentCommentFromJson(Map<String, dynamic> json) =>
    DocumentComment(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      selection: json['selection'] == null
          ? null
          : DocumentSelection.fromJson(
              json['selection'] as Map<String, dynamic>),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => DocumentComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DocumentCommentToJson(DocumentComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'selection': instance.selection,
      'replies': instance.replies,
    };

DocumentSelection _$DocumentSelectionFromJson(Map<String, dynamic> json) =>
    DocumentSelection(
      startOffset: (json['startOffset'] as num).toInt(),
      endOffset: (json['endOffset'] as num).toInt(),
      selectedText: json['selectedText'] as String,
    );

Map<String, dynamic> _$DocumentSelectionToJson(DocumentSelection instance) =>
    <String, dynamic>{
      'startOffset': instance.startOffset,
      'endOffset': instance.endOffset,
      'selectedText': instance.selectedText,
    };

DocumentPermissions _$DocumentPermissionsFromJson(Map<String, dynamic> json) =>
    DocumentPermissions(
      owner: json['owner'] as String,
      editors: (json['editors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      viewers: (json['viewers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      commenters: (json['commenters'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isPublic: json['isPublic'] as bool? ?? false,
      customRoles: (json['customRoles'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
                k, (e as List<dynamic>).map((e) => e as String).toList()),
          ) ??
          const {},
    );

Map<String, dynamic> _$DocumentPermissionsToJson(
        DocumentPermissions instance) =>
    <String, dynamic>{
      'owner': instance.owner,
      'editors': instance.editors,
      'viewers': instance.viewers,
      'commenters': instance.commenters,
      'isPublic': instance.isPublic,
      'customRoles': instance.customRoles,
    };
