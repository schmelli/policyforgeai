import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/storage_service.dart';
import '../pages/project_workspace.dart';

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
        print('New Project button pressed');
        final formKey = GlobalKey<FormState>();
        String projectName = '';
        String projectDescription = '';

        print('Showing dialog...');
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
                  print('Cancel pressed');
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  print('Create pressed');
                  if (formKey.currentState?.validate() ?? false) {
                    formKey.currentState?.save();
                    print(
                        'Form validated, name: $projectName, desc: $projectDescription');
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );

        print('Dialog result: $shouldCreate');
        if (shouldCreate == true) {
          try {
            print('Creating project...');
            final project = Project.create(
              name: projectName,
              description: projectDescription,
              createdBy: 'current-user',
            );
            await storageService.saveProject(project);
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
            print('Error creating project: $e');
            print(stackTrace);
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
