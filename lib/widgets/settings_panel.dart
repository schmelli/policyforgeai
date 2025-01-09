import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../models/settings.dart';
import '../utils/settings_validator.dart';
import '../services/settings_export_service.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late TextEditingController _projectNameController;
  late TextEditingController _organizationNameController;
  late TextEditingController _organizationIdController;
  late TextEditingController _apiKeyController;
  late TextEditingController _modelController;
  late TextEditingController _temperatureController;
  late TextEditingController _maxTokensController;

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController();
    _organizationNameController = TextEditingController();
    _organizationIdController = TextEditingController();
    _apiKeyController = TextEditingController();
    _modelController = TextEditingController();
    _temperatureController = TextEditingController();
    _maxTokensController = TextEditingController();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _organizationNameController.dispose();
    _organizationIdController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _temperatureController.dispose();
    _maxTokensController.dispose();
    super.dispose();
  }

  void _loadSettings(ProjectSettings settings) {
    _projectNameController.text = settings.projectName;
    _organizationNameController.text = settings.organizationName;
    _organizationIdController.text = settings.organizationId;
    _apiKeyController.text = settings.aiSettings.llmConfig.apiKey ?? '';
    _modelController.text = settings.aiSettings.llmConfig.model;
    _temperatureController.text = settings.aiSettings.temperature.toString();
    _maxTokensController.text = settings.aiSettings.maxTokens.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoaded) {
          _loadSettings(state.settings);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),

                // Project Information Section
                _buildSection(
                  context,
                  'Project Information',
                  [
                    TextField(
                      controller: _projectNameController,
                      decoration: const InputDecoration(
                        labelText: 'Project Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _organizationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Organization Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _organizationIdController,
                      decoration: const InputDecoration(
                        labelText: 'Organization ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),

                // Feature Toggles Section
                _buildSection(
                  context,
                  'Features',
                  [
                    SwitchListTile(
                      title: const Text('AI Assistance'),
                      subtitle:
                          const Text('Enable AI-powered document assistance'),
                      value: state.settings.aiEnabled,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdateSettings(
                                state.settings.copyWith(aiEnabled: value),
                              ),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Collaboration'),
                      subtitle: const Text('Enable multi-user collaboration'),
                      value: state.settings.collaborationEnabled,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdateSettings(
                                state.settings.copyWith(
                                  collaborationEnabled: value,
                                ),
                              ),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Version Control'),
                      subtitle: const Text('Enable document versioning'),
                      value: state.settings.versionControlEnabled,
                      onChanged: (value) {
                        context.read<SettingsBloc>().add(
                              UpdateSettings(
                                state.settings.copyWith(
                                  versionControlEnabled: value,
                                ),
                              ),
                            );
                      },
                    ),
                  ],
                ),

                // AI Configuration Section
                if (state.settings.aiEnabled)
                  _buildSection(
                    context,
                    'AI Configuration',
                    [
                      TextField(
                        controller: _apiKeyController,
                        decoration: const InputDecoration(
                          labelText: 'OpenAI API Key',
                          border: OutlineInputBorder(),
                          helperText:
                              'Your OpenAI API key for AI-powered features',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _modelController,
                        decoration: InputDecoration(
                          labelText: 'Model',
                          border: const OutlineInputBorder(),
                          helperText: 'The OpenAI model to use',
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            onSelected: (String value) {
                              _modelController.text = value;
                            },
                            itemBuilder: (BuildContext context) {
                              return const [
                                PopupMenuItem(
                                  value: 'gpt-4',
                                  child: Text('GPT-4'),
                                ),
                                PopupMenuItem(
                                  value: 'gpt-4-32k',
                                  child: Text('GPT-4 32K'),
                                ),
                                PopupMenuItem(
                                  value: 'gpt-3.5-turbo',
                                  child: Text('GPT-3.5 Turbo'),
                                ),
                                PopupMenuItem(
                                  value: 'gpt-3.5-turbo-16k',
                                  child: Text('GPT-3.5 Turbo 16K'),
                                ),
                              ];
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _temperatureController,
                              decoration: const InputDecoration(
                                labelText: 'Temperature',
                                border: OutlineInputBorder(),
                                helperText: 'Response creativity (0.0 - 1.0)',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _maxTokensController,
                              decoration: const InputDecoration(
                                labelText: 'Max Tokens',
                                border: OutlineInputBorder(),
                                helperText: 'Maximum response length',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Stream Responses'),
                        subtitle: const Text(
                          'Show AI responses as they are generated',
                        ),
                        value: state.settings.aiSettings.streamResponses,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(
                                UpdateSettings(
                                  state.settings.copyWith(
                                    aiSettings: state.settings.aiSettings
                                        .copyWith(streamResponses: value),
                                  ),
                                ),
                              );
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FilledButton(
                      onPressed: () async {
                        try {
                          if (!mounted) return;
                          final settings = state.settings.copyWith(
                            projectName: _projectNameController.text,
                            organizationName: _organizationNameController.text,
                            organizationId: _organizationIdController.text,
                            aiSettings: state.settings.aiSettings.copyWith(
                              llmConfig:
                                  state.settings.aiSettings.llmConfig.copyWith(
                                apiKey: _apiKeyController.text,
                                model: _modelController.text,
                              ),
                              temperature: double.tryParse(
                                    _temperatureController.text,
                                  ) ??
                                  0.7,
                              maxTokens:
                                  int.tryParse(_maxTokensController.text) ??
                                      1000,
                            ),
                          );

                          final validation =
                              SettingsValidator.validateProjectSettings(
                                  settings);
                          if (!validation.isValid) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(validation.errorMessage),
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              ),
                            );
                            return;
                          }

                          context
                              .read<SettingsBloc>()
                              .add(UpdateSettings(settings));

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings saved successfully'),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to save settings: $e'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                      },
                      child: const Text('Save Settings'),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            try {
                              if (!mounted) return;
                              await SettingsExportService.exportSettings(
                                  state.settings);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Settings exported successfully'),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to export settings: $e'),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          },
                          child: const Text('Export'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () async {
                            try {
                              if (!mounted) return;
                              final settings =
                                  await SettingsExportService.importSettings();
                              if (settings != null) {
                                context
                                    .read<SettingsBloc>()
                                    .add(UpdateSettings(settings));
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Settings imported successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Failed to import settings: $e'),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          },
                          child: const Text('Import'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: children,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
