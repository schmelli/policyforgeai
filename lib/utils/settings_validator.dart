import '../models/settings.dart';

class SettingsValidator {
  static const List<String> _supportedModels = [
    'gpt-4',
    'gpt-4-32k',
    'gpt-3.5-turbo',
    'gpt-3.5-turbo-16k',
  ];

  static ValidationResult validateAISettings(AISettings settings) {
    final errors = <String>[];

    // Validate API Key
    if (settings.apiKey != null && settings.apiKey!.isEmpty) {
      errors.add('API Key cannot be empty if provided');
    }

    // Validate model
    if (!_supportedModels.contains(settings.model)) {
      errors.add(
        'Unsupported model. Must be one of: ${_supportedModels.join(", ")}',
      );
    }

    // Validate temperature
    if (settings.temperature < 0.0 || settings.temperature > 1.0) {
      errors.add('Temperature must be between 0.0 and 1.0');
    }

    // Validate max tokens
    if (settings.maxTokens < 1 || settings.maxTokens > 32000) {
      errors.add('Max tokens must be between 1 and 32000');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  static ValidationResult validateProjectSettings(ProjectSettings settings) {
    final errors = <String>[];

    // Validate project name
    if (settings.projectName.isEmpty) {
      errors.add('Project name is required');
    }

    // Validate organization name
    if (settings.organizationName.isEmpty) {
      errors.add('Organization name is required');
    }

    // Validate organization ID
    if (settings.organizationId.isEmpty) {
      errors.add('Organization ID is required');
    }

    // Validate AI settings if AI is enabled
    if (settings.aiEnabled) {
      final aiValidation = validateAISettings(settings.aiSettings);
      if (!aiValidation.isValid) {
        errors.addAll(aiValidation.errors);
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  String get errorMessage => errors.join('\n');
}
