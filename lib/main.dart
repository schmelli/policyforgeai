// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Policy Forge AI',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String selectedFileContent = 'No file selected';
  String selectedSectionContent = 'No section selected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Forge AI'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            // Desktop Layout with three panes
            return Row(
              children: [
                // File Explorer Pane (Left)
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey[200],
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text('File 1'),
                          onTap: () {
                            setState(() {
                              selectedFileContent = 'Content of File 1';
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('File 2'),
                          onTap: () {
                            setState(() {
                              selectedFileContent = 'Content of File 2';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Document Navigation Pane (Middle)
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey[300],
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text('Section 1'),
                          onTap: () {
                            setState(() {
                              selectedSectionContent = 'Content of Section 1';
                            });
                          },
                        ),
                        ListTile(
                          title: const Text('Section 2'),
                          onTap: () {
                            setState(() {
                              selectedSectionContent = 'Content of Section 2';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Main Document Pane (Right)
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'File Content:\n$selectedFileContent\n\nSection Content:\n$selectedSectionContent',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Mobile Layout with single pane
            return Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: const Center(
                      child: Text(
                        'Please use a larger screen to view the three-pane layout.',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
