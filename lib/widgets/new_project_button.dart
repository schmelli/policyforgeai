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
        try {
          final project = Project.create(
            name: 'New Project',
            description: 'A new policy management project',
            createdBy: 'current-user',
          );
          await storageService.saveProject(project);
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ProjectWorkspace(
                  project: project,
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
      },
      icon: const Icon(Icons.add),
      label: const Text('Create New Project'),
    );
  }
}
