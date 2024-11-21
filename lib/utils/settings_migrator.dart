import '../models/settings.dart';

class SettingsMigrator {
  static const int currentVersion = 2;

  static ProjectSettings migrate(Map<String, dynamic> json) {
    final version = json['version'] as int? ?? 1;
    var migratedJson = Map<String, dynamic>.from(json);

    // Apply migrations in sequence
    if (version < 2) {
      migratedJson = _migrateTo2(migratedJson);
    }

    // Add more version migrations here as needed
    // if (version < 3) {
    //   migratedJson = _migrateTo3(migratedJson);
    // }

    // Set the current version
    migratedJson['version'] = currentVersion;

    return ProjectSettings.fromJson(migratedJson);
  }

  static Map<String, dynamic> _migrateTo2(Map<String, dynamic> json) {
    // Migrate from version 1 to 2:
    // - Add AI settings
    // - Convert organization domain to organization ID
    // - Remove project description
    return {
      'projectName': json['projectName'] ?? '',
      'organizationName': json['organizationName'] ?? '',
      'organizationId': json['organizationDomain'] ?? '',
      'aiEnabled': json['aiEnabled'] ?? true,
      'collaborationEnabled': json['collaborationEnabled'] ?? false,
      'versionControlEnabled': json['versionControlEnabled'] ?? false,
      'allowedFileTypes': json['allowedFileTypes'] ?? [],
      'customMetadata': json['customMetadata'] ?? {},
      'aiSettings': {
        'apiKey': null,
        'model': 'gpt-3.5-turbo',
        'temperature': 0.7,
        'maxTokens': 1000,
        'streamResponses': true,
      },
    };
  }

  static Map<String, dynamic> prepareForStorage(ProjectSettings settings) {
    return {
      ...settings.toJson(),
      'version': currentVersion,
    };
  }
}
