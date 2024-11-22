import 'package:equatable/equatable.dart';

/// Represents project-wide settings for a PolicyForge project
class ProjectSettings extends Equatable {
  final String projectName;
  final String organizationName;
  final String organizationId;
  final bool aiEnabled;
  final bool collaborationEnabled;
  final bool versionControlEnabled;
  final List<String> allowedFileTypes;
  final Map<String, dynamic> customMetadata;
  final AISettings aiSettings;

  const ProjectSettings({
    required this.projectName,
    required this.organizationName,
    required this.organizationId,
    this.aiEnabled = true,
    this.collaborationEnabled = false,
    this.versionControlEnabled = false,
    this.allowedFileTypes = const ['md', 'txt', 'doc', 'docx', 'pdf'],
    this.customMetadata = const {},
    this.aiSettings = const AISettings(),
  });

  /// Creates a default project settings instance
  factory ProjectSettings.defaults() {
    return const ProjectSettings(
      projectName: 'New Project',
      organizationName: 'Default Organization',
      organizationId: 'default-org',
    );
  }

  /// Creates a copy of this project settings with the given fields replaced
  ProjectSettings copyWith({
    String? projectName,
    String? organizationName,
    String? organizationId,
    bool? aiEnabled,
    bool? collaborationEnabled,
    bool? versionControlEnabled,
    List<String>? allowedFileTypes,
    Map<String, dynamic>? customMetadata,
    AISettings? aiSettings,
  }) {
    return ProjectSettings(
      projectName: projectName ?? this.projectName,
      organizationName: organizationName ?? this.organizationName,
      organizationId: organizationId ?? this.organizationId,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      collaborationEnabled: collaborationEnabled ?? this.collaborationEnabled,
      versionControlEnabled: versionControlEnabled ?? this.versionControlEnabled,
      allowedFileTypes: allowedFileTypes ?? this.allowedFileTypes,
      customMetadata: customMetadata ?? this.customMetadata,
      aiSettings: aiSettings ?? this.aiSettings,
    );
  }

  /// Converts this project settings to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'organizationName': organizationName,
      'organizationId': organizationId,
      'aiEnabled': aiEnabled,
      'collaborationEnabled': collaborationEnabled,
      'versionControlEnabled': versionControlEnabled,
      'allowedFileTypes': allowedFileTypes,
      'customMetadata': customMetadata,
      'aiSettings': aiSettings.toJson(),
    };
  }

  /// Creates a project settings instance from a JSON map
  factory ProjectSettings.fromJson(Map<String, dynamic> json) {
    return ProjectSettings(
      projectName: json['projectName'] as String? ?? 'New Project',
      organizationName: json['organizationName'] as String? ?? 'Default Organization',
      organizationId: json['organizationId'] as String? ?? 'default-org',
      aiEnabled: json['aiEnabled'] as bool? ?? true,
      collaborationEnabled: json['collaborationEnabled'] as bool? ?? false,
      versionControlEnabled: json['versionControlEnabled'] as bool? ?? false,
      allowedFileTypes: (json['allowedFileTypes'] as List<dynamic>?)?.cast<String>() ?? 
          const ['md', 'txt', 'doc', 'docx', 'pdf'],
      customMetadata: json['customMetadata'] as Map<String, dynamic>? ?? const {},
      aiSettings: json['aiSettings'] != null 
          ? AISettings.fromJson(json['aiSettings'] as Map<String, dynamic>) 
          : const AISettings(),
    );
  }

  @override
  List<Object?> get props => [
        projectName,
        organizationName,
        organizationId,
        aiEnabled,
        collaborationEnabled,
        versionControlEnabled,
        allowedFileTypes,
        customMetadata,
        aiSettings,
      ];
}

/// Represents AI-specific settings for a PolicyForge project
class AISettings extends Equatable {
  final String? apiKey;
  final String model;
  final double temperature;
  final int maxTokens;
  final bool streamResponses;

  const AISettings({
    this.apiKey,
    this.model = 'gpt-3.5-turbo',
    this.temperature = 0.7,
    this.maxTokens = 1000,
    this.streamResponses = true,
  });

  /// Creates a copy of this AI settings with the given fields replaced
  AISettings copyWith({
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
    bool? streamResponses,
  }) {
    return AISettings(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      streamResponses: streamResponses ?? this.streamResponses,
    );
  }

  /// Converts this AI settings to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'model': model,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'streamResponses': streamResponses,
    };
  }

  /// Creates an AI settings instance from a JSON map
  factory AISettings.fromJson(Map<String, dynamic> json) {
    return AISettings(
      apiKey: json['apiKey'] as String?,
      model: json['model'] as String? ?? 'gpt-3.5-turbo',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: json['maxTokens'] as int? ?? 1000,
      streamResponses: json['streamResponses'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        apiKey,
        model,
        temperature,
        maxTokens,
        streamResponses,
      ];
}
