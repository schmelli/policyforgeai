import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/storage_service.dart';
import '../pages/project_workspace.dart';
import '../widgets/project_selection_dialog.dart';

class OpenProjectButton extends StatelessWidget {
  final StorageService storageService;

  const OpenProjectButton({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        try {
          final projects = await storageService.listProjects();
          if (context.mounted) {
            final selectedProject = await showDialog<Project>(
              context: context,
              builder: (context) => ProjectSelectionDialog(
                projects: projects,
              ),
            );

            if (selectedProject != null && context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProjectWorkspace(
                    project: selectedProject,
                  ),
                ),
              );
            }
          }
        } catch (e, stackTrace) {
          print('Error loading projects: $e');
          print(stackTrace);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading projects: $e'),
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
      icon: const Icon(Icons.folder_open),
      label: const Text('Open Existing Project'),
    );
  }
}
