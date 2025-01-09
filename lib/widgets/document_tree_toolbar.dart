import 'package:flutter/material.dart';

class DocumentTreeToolbar extends StatelessWidget {
  final VoidCallback onCreateDocument;
  final VoidCallback onCreateFolder;

  const DocumentTreeToolbar({
    super.key,
    required this.onCreateDocument,
    required this.onCreateFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.note_add),
            tooltip: 'New Document',
            onPressed: onCreateDocument,
          ),
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            tooltip: 'New Folder',
            onPressed: onCreateFolder,
          ),
        ],
      ),
    );
  }
}
