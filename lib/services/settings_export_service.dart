import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../models/settings.dart';
import '../utils/settings_migrator.dart';
import '../utils/settings_validator.dart';

class SettingsExportService {
  static Future<void> exportSettings(ProjectSettings settings) async {
    try {
      // Prepare settings for export
      final json = SettingsMigrator.prepareForStorage(settings);
      final jsonString = const JsonEncoder.withIndent('  ').convert(json);

      // Get save location
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Settings',
        fileName: 'policyforge_settings.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
      );

      if (result != null) {
        // Write settings to file
        await writeFile(result, jsonString);
      }
    } catch (e) {
      throw Exception('Failed to export settings: $e');
    }
  }

  static Future<ProjectSettings?> importSettings() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import Settings',
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      // Read and parse file
      final file = result.files.first;
      if (file.path == null) {
        throw Exception('Invalid file path');
      }

      final content = await readFile(file.path!);
      final json = jsonDecode(content);

      // Validate JSON structure
      if (json is! Map<String, dynamic>) {
        throw Exception('Invalid settings file format');
      }

      // Migrate settings if needed
      final settings = SettingsMigrator.migrate(json);

      // Validate settings
      final validation = SettingsValidator.validateProjectSettings(settings);
      if (!validation.isValid) {
        throw Exception('Invalid settings: ${validation.errorMessage}');
      }

      return settings;
    } catch (e) {
      throw Exception('Failed to import settings: $e');
    }
  }

  static Future<void> writeFile(String path, String content) async {
    try {
      // Platform-specific file writing implementation
      throw UnimplementedError('Platform-specific implementation required');
    } catch (e) {
      throw Exception('Failed to write file: $e');
    }
  }

  static Future<String> readFile(String path) async {
    try {
      // Platform-specific file reading implementation
      throw UnimplementedError('Platform-specific implementation required');
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }
}
