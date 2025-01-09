// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:policyforgeai/main.dart';
import 'package:policyforgeai/services/storage_service.dart';
import 'package:policyforgeai/services/ai_service.dart';
import 'package:policyforgeai/models/llm_provider.dart';
import 'package:policyforgeai/models/project.dart';
import 'package:policyforgeai/models/settings.dart';

void main() {
  group('App', () {
    late StorageService storageService;
    late AIService aiService;

    setUp(() async {
      storageService = StorageService();
      await storageService.initialize();

      aiService = AIService(
        config: const LLMConfig(
          provider: LLMProvider.ollama,
          model: 'llama2',
          baseUrl: 'http://localhost:11434/api/chat',
        ),
        temperature: 0.7,
        maxTokens: 1000,
      );
    });

    testWidgets('shows welcome screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: storageService),
            RepositoryProvider.value(value: aiService),
          ],
          child: MyApp(storageService: storageService),
        ),
      );

      expect(find.text('Welcome to PolicyForge AI'), findsOneWidget);
      expect(find.text('Create New Project'), findsOneWidget);
      expect(find.text('Open Existing Project'), findsOneWidget);
    });

    testWidgets('creates new project', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: storageService),
            RepositoryProvider.value(value: aiService),
          ],
          child: MyApp(storageService: storageService),
        ),
      );

      // Create project and initial document
      final project = Project.create(
        name: 'Test Project',
        description: 'A test project',
        createdBy: 'test-user',
      );

      // Create document node
      final node = DocumentLeafNode.create(
        name: 'Welcome',
        createdBy: 'test-user',
        projectId: project.id,
      );

      // Create initial settings
      final settings = ProjectSettings.defaults();

      // Save everything
      await storageService.saveProject(project);
      await storageService.saveDocument(project.id, node.document);
      await storageService.saveProjectTree(project.id, [node]);
      await storageService.saveProjectSettings(project.id, settings);

      // Navigate to project workspace
      await tester.pumpWidget(
        MaterialApp(
          home: MultiRepositoryProvider(
            providers: [
              RepositoryProvider.value(value: storageService),
              RepositoryProvider.value(value: aiService),
            ],
            child: ProjectWorkspace(projectId: project.id),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify we're in the project workspace
      expect(find.byType(ProjectWorkspace), findsOneWidget);

      // Clean up
      await storageService.deleteProject(project.id);
    });
  });
}
