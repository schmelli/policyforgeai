import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../models/settings.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SettingsError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is SettingsLoaded) {
          return _SettingsForm(settings: state.settings);
        }

        return const SizedBox();
      },
    );
  }
}

class _SettingsForm extends StatefulWidget {
  final ProjectSettings settings;

  const _SettingsForm({required this.settings});

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _orgNameController;
  late TextEditingController _orgDomainController;
  late bool _aiEnabled;
  late bool _collaborationEnabled;
  late bool _versionControlEnabled;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.settings.projectName);
    _descriptionController =
        TextEditingController(text: widget.settings.projectDescription);
    _orgNameController =
        TextEditingController(text: widget.settings.organizationName);
    _orgDomainController =
        TextEditingController(text: widget.settings.organizationDomain);
    _aiEnabled = widget.settings.aiEnabled;
    _collaborationEnabled = widget.settings.collaborationEnabled;
    _versionControlEnabled = widget.settings.versionControlEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _orgNameController.dispose();
    _orgDomainController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final updatedSettings = widget.settings.copyWith(
      projectName: _nameController.text,
      projectDescription: _descriptionController.text,
      organizationName: _orgNameController.text,
      organizationDomain: _orgDomainController.text,
      aiEnabled: _aiEnabled,
      collaborationEnabled: _collaborationEnabled,
      versionControlEnabled: _versionControlEnabled,
    );

    context.read<SettingsBloc>().add(UpdateSettings(updatedSettings));
    context.read<SettingsBloc>().add(const SaveSettings());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Project Settings',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            // Project Details Section
            Text(
              'Project Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Project Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            // Organization Section
            Text(
              'Organization',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orgNameController,
              decoration: const InputDecoration(
                labelText: 'Organization Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orgDomainController,
              decoration: const InputDecoration(
                labelText: 'Organization Domain',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            // Features Section
            Text(
              'Features',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('AI Assistance'),
              subtitle: const Text('Enable AI-powered document assistance'),
              value: _aiEnabled,
              onChanged: (value) => setState(() => _aiEnabled = value),
            ),
            SwitchListTile(
              title: const Text('Collaboration'),
              subtitle: const Text('Enable real-time collaboration features'),
              value: _collaborationEnabled,
              onChanged: (value) =>
                  setState(() => _collaborationEnabled = value),
            ),
            SwitchListTile(
              title: const Text('Version Control'),
              subtitle: const Text('Enable document version control'),
              value: _versionControlEnabled,
              onChanged: (value) =>
                  setState(() => _versionControlEnabled = value),
            ),
            const SizedBox(height: 32),
            // Save Button
            Center(
              child: FilledButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
