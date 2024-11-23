import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/quill_delta.dart';
import '../models/document.dart';
import '../blocs/document/document_bloc.dart';

class DocumentStructure extends StatefulWidget {
  final PolicyDocument document;

  const DocumentStructure({
    super.key,
    required this.document,
  });

  @override
  State<DocumentStructure> createState() => _DocumentStructureState();
}

class _DocumentStructureState extends State<DocumentStructure> {
  List<DocumentSection> _sections = [];
  final TextEditingController _newSectionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _parseSections();
  }

  @override
  void didUpdateWidget(DocumentStructure oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      _parseSections();
    }
  }

  void _parseSections() {
    try {
      // Parse the QuillEditor content to extract sections
      final docJson = jsonDecode(widget.document.content);
      if (docJson is! List) {
        throw FormatException('Invalid document format');
      }

      final List<DocumentSection> sections = [];
      int currentLevel = 1;
      DocumentSection? currentSection;
      
      int currentIndex = 0;
      for (final op in docJson) {
        if (op is! Map<String, dynamic>) continue;
        
        if (op.containsKey('insert') && op.containsKey('attributes')) {
          final attrs = op['attributes'] as Map<String, dynamic>;
          if (attrs.containsKey('header')) {
            final level = attrs['header'] as int;
            final text = op['insert'] as String? ?? '';
            
            if (text.trim().isNotEmpty) {
              final newSection = DocumentSection(
                title: text.trim(),
                level: level,
                index: currentIndex,
              );

              if (level == 1) {
                sections.add(newSection);
                currentSection = newSection;
                currentLevel = 1;
              } else if (currentSection != null && level > currentLevel) {
                currentSection.subsections.add(newSection);
                currentLevel = level;
              } else if (currentSection != null && level == currentLevel) {
                final parent = _findParentSection(sections, level - 1);
                if (parent != null) {
                  parent.subsections.add(newSection);
                } else {
                  sections.add(newSection);
                }
              } else if (level < currentLevel) {
                final parent = _findParentSection(sections, level - 1);
                if (parent != null) {
                  parent.subsections.add(newSection);
                } else {
                  sections.add(newSection);
                }
                currentLevel = level;
              }
            }
          }
        }
        
        // Update the current index based on the insert length
        if (op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is String) {
            currentIndex += insert.length;
          }
        }
      }

      setState(() {
        _sections = sections;
      });
    } catch (e) {
      print('Error parsing sections: $e');
      setState(() {
        _sections = [];
      });
    }
  }

  DocumentSection? _findParentSection(List<DocumentSection> sections, int targetLevel) {
    for (var section in sections.reversed) {
      if (section.level == targetLevel) {
        return section;
      }
      final parent = _findParentSection(section.subsections, targetLevel);
      if (parent != null) {
        return parent;
      }
    }
    return null;
  }

  Future<void> _addNewSection({DocumentSection? parent}) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${parent != null ? 'Subsection' : 'Section'}'),
        content: TextField(
          controller: _newSectionController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Title',
            hintText: 'Enter section title',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _newSectionController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final level = parent != null ? parent.level + 1 : 1;
        final docJson = jsonDecode(widget.document.content);
        final doc = Document.fromJson(docJson);
        
        // Create header block
        final delta = Delta()
          ..insert(result)
          ..insert('\n', {'header': level});
        
        // If we have a parent, insert after it and its subsections
        if (parent != null) {
          int insertIndex = parent.index;
          for (var subsection in parent.subsections) {
            if (subsection.index > insertIndex) {
              insertIndex = subsection.index;
            }
          }
          delta.retain(insertIndex + 1);  // +1 for the newline
        }
        
        doc.compose(delta, ChangeSource.local);
        
        // Update document content
        final updatedContent = jsonEncode(doc.toDelta().toJson());
        
        // Save the document
        context.read<DocumentBloc>().add(UpdateDocument(
          documentId: widget.document.id,
          content: updatedContent,
        ));
        
        _parseSections();
      } catch (e) {
        print('Error adding section: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding section: $e')),
        );
      }
    }
    _newSectionController.clear();
  }

    void _updateSectionOrder() {
    try {
      final delta = Delta()
        ..retain(0); // Start at the beginning
      
      // Create a new document with sections in the new order
      for (var section in _sections) {
        delta.insert(section.title);
        delta.insert('\n', {'header': section.level});
        
        // Add subsections
        for (var subsection in section.subsections) {
          delta.insert(subsection.title);
          delta.insert('\n', {'header': subsection.level});
        }
      }
      
      // Create new document with the reordered content
      final doc = Document.fromDelta(delta);
      final updatedContent = jsonEncode(doc.toDelta().toJson());
      
      // Save the document
      context.read<DocumentBloc>().add(UpdateDocument(
        documentId: widget.document.id,
        content: updatedContent,
      ));
    } catch (e) {
      print('Error updating section order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating section order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text(
                'Document Structure',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Section',
                onPressed: () => _addNewSection(),
              ),
            ],
          ),
        ),
        const Divider(),
        // Section List
        Expanded(
          child: _sections.isEmpty
              ? const Center(
                  child: Text('No sections found'),
                )
              : ReorderableListView.builder(
                  itemCount: _sections.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = _sections.removeAt(oldIndex);
                      _sections.insert(newIndex, item);
                      _updateSectionOrder();
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildSectionTile(_sections[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSectionTile(DocumentSection section, int index) {
    return Card(
      key: ValueKey(section.hashCode),
      margin: EdgeInsets.only(
        left: 8.0 * (section.level - 1),
        right: 8.0,
        bottom: 4.0,
      ),
      child: ListTile(
        title: Text(section.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Subsection',
              onPressed: () => _addNewSection(parent: section),
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
          ],
        ),
        onTap: () {
          // TODO: Scroll document to this section
        },
      ),
    );
  }

  @override
  void dispose() {
    _newSectionController.dispose();
    super.dispose();
  }
}

class DocumentSection {
  final String title;
  final int level;
  final int index;
  final List<DocumentSection> subsections;

  DocumentSection({
    required this.title,
    required this.level,
    required this.index,
    List<DocumentSection>? subsections,
  }) : subsections = subsections ?? [];
}
