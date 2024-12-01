import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/new_project_button.dart';
import '../widgets/open_project_button.dart';

class ProjectSelectionScreen extends StatelessWidget {
  final StorageService storageService;

  const ProjectSelectionScreen({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome to PolicyForge AI',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  NewProjectButton(storageService: storageService),
                  const SizedBox(height: 16),
                  OpenProjectButton(storageService: storageService),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
