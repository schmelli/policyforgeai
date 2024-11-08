import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Policy Forge AI',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
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
        title: Text('Policy Forge AI'),
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
                          title: Text('File 1'),
                          onTap: () {
                            setState(() {
                              selectedFileContent = 'Content of File 1';
                            });
                          },
                        ),
                        ListTile(
                          title: Text('File 2'),
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
                          title: Text('Section 1'),
                          onTap: () {
                            setState(() {
                              selectedSectionContent = 'Content of Section 1';
                            });
                          },
                        ),
                        ListTile(
                          title: Text('Section 2'),
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
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'File Content:\n$selectedFileContent\n\nSection Content:\n$selectedSectionContent',
                        style: TextStyle(fontSize: 16),
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
                    child: Center(
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
