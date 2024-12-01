import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'pages/project_selection_screen.dart';

class MyApp extends StatelessWidget {
  final StorageService storageService;

  const MyApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolicyForge AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ).copyWith(
          primaryContainer: Colors.blue.shade50,
          onPrimaryContainer: Colors.blue.shade900,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ).copyWith(
          primaryContainer: Colors.blue.shade900,
          onPrimaryContainer: Colors.blue.shade50,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (context) {
          try {
            return ProjectSelectionScreen(storageService: storageService);
          } catch (e, stackTrace) {
            print('Error building ProjectSelectionScreen: $e');
            print(stackTrace);
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Error: $e'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => MyApp(storageService: storageService),
                          ),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
