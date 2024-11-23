// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      rootNodes: Project._nodesFromJson(json['rootNodes'] as List),
      settings:
          ProjectSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'modifiedAt': instance.modifiedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'rootNodes': Project._nodesToJson(instance.rootNodes),
      'settings': instance.settings.toJson(),
    };

FolderNode _$FolderNodeFromJson(Map<String, dynamic> json) => FolderNode(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      children: Project._nodesFromJson(json['children'] as List),
    );

Map<String, dynamic> _$FolderNodeToJson(FolderNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentId': instance.parentId,
      'createdAt': instance.createdAt.toIso8601String(),
      'modifiedAt': instance.modifiedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'children': Project._nodesToJson(instance.children),
    };

DocumentLeafNode _$DocumentLeafNodeFromJson(Map<String, dynamic> json) =>
    DocumentLeafNode(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      createdBy: json['createdBy'] as String,
      document:
          PolicyDocument.fromJson(json['document'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DocumentLeafNodeToJson(DocumentLeafNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'parentId': instance.parentId,
      'createdAt': instance.createdAt.toIso8601String(),
      'modifiedAt': instance.modifiedAt.toIso8601String(),
      'createdBy': instance.createdBy,
      'document': instance.document.toJson(),
    };
