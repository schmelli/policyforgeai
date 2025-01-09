import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/settings.dart';
import '../models/document.dart';
import '../services/storage_service.dart';
import '../pages/project_workspace.dart';
import '../utils/logger.dart';
import 'dart:convert';

class NewProjectButton extends StatelessWidget {
  final StorageService storageService;

  const NewProjectButton({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () async {
        appLogger.i('New Project button pressed');
        final formKey = GlobalKey<FormState>();
        String projectName = '';
        String projectDescription = '';

        appLogger.i('Showing new project dialog');
        final shouldCreate = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('New Project'),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Project Name',
                        hintText: 'Enter project name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a project name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        projectName = value ?? '';
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter project description',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a project description';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        projectDescription = value ?? '';
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  appLogger.i('Project creation cancelled');
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  appLogger.i('Create project button pressed');
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    appLogger.i('Form validated, creating project "$projectName"');
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );

        appLogger.i('Dialog result: $shouldCreate');
        if (shouldCreate == true) {
          try {
            appLogger.i('Creating new project "$projectName"');
            final project = Project.create(
              name: projectName,
              description: projectDescription,
              createdBy: 'current-user',
            );

            // Create initial welcome document
            final welcomeContent = '''# Welcome to your new project!

Getting Started
--------------
• Create new documents using the + button in the sidebar
• Organize your documents into folders
• Use the AI assistant to help you write and edit

Need help? Click the help icon in the top right corner.''';

            final node = DocumentLeafNode.create(
              name: 'Welcome',
              createdBy: 'current-user',
              projectId: project.id,
              content: welcomeContent,
            );

            // Create initial settings
            final settings = ProjectSettings.defaults();

            // Save everything
            await storageService.saveProject(project);
            await storageService.saveDocument(project.id, node.document);
            await storageService.saveProjectTree(project.id, [node]);
            await storageService.saveProjectSettings(project.id, settings);

            appLogger.i('Project created successfully');

            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProjectWorkspace(
                    projectId: project.id,
                  ),
                ),
              );
            }
          } catch (e, stackTrace) {
            appLogger.e('Error creating project: $e', error: e, stackTrace: stackTrace);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error creating project: $e'),
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () {
                      // Retry button pressed
                    },
                  ),
                ),
              );
            }
          }
        }
      },
      icon: const Icon(Icons.add),
      label: const Text('Create New Project'),
    );
  }
}
