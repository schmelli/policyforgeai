import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/quill_delta.dart';
import '../models/document.dart';
import '../blocs/document/document_bloc.dart';
import '../blocs/document_tree/document_tree_bloc.dart';
import '../models/project.dart';

class DocumentStructure extends StatefulWidget {
  final PolicyDocument document;
  final Function? onContentChanged;
  final String projectId;

  const DocumentStructure({
    super.key,
    required this.document,
    required this.projectId,
    this.onContentChanged,
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
      print('Parsing sections from content: ${widget.document.content}');
      if (widget.document.content.isEmpty) {
        print('Empty document content');
        setState(() {
          _sections = [];
        });
        return;
      }

      final docJson = jsonDecode(widget.document.content);
      final doc = Document.fromJson(docJson);
      final List<DocumentSection> sections = [];

      // Handle empty document with just a newline
      if (doc.length <= 1 && doc.root.children.isEmpty != false) {
        print('Document is empty (only newline)');
        setState(() {
          _sections = [];
        });
        return;
      }

      // Iterate through each line
      var index = 0;
      doc.root.children.forEach((block) {
        final attrs = block.style.attributes;
        final text = block.toPlainText().trim();

        // Check if this is a header
        if (attrs[Attribute.header.key] != null && text.isNotEmpty) {
          final level = attrs[Attribute.header.key] as int;
          print('Found header level $level: $text');

          // Create new section
          final section = DocumentSection(
            title: text,
            level: level,
            index: index++,
          );

          // Add to sections list
          sections.add(section);
        }
      });

      print('Parsed ${sections.length} sections');
      setState(() {
        _sections = sections;
      });
    } catch (e, stackTrace) {
      print('Error parsing sections: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _sections = [];
      });
    }
  }

  Future<void> _addNewSection({DocumentSection? parent}) async {
    final formKey = GlobalKey<FormState>();
    String sectionTitle = '';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add ${parent != null ? 'Subsection' : 'Section'}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Enter section title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a section title';
              }
              return null;
            },
            onSaved: (value) {
              sectionTitle = value ?? '';
            },
            onFieldSubmitted: (value) {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.of(dialogContext).pop(true);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                formKey.currentState?.save();
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && sectionTitle.isNotEmpty) {
      try {
        print('Adding new section: $sectionTitle');
        final level = parent != null ? parent.level + 1 : 1;

        // Get the current document content from the bloc
        final currentState = context.read<DocumentBloc>().state;
        if (currentState is! DocumentLoaded) {
          print('Document not loaded in bloc');
          return;
        }

        final currentContent = currentState.document.document.content;
        final docJson = currentContent.isEmpty
            ? [
                {"insert": "\n"}
              ]
            : jsonDecode(currentContent);

        print('Current document content from bloc: $docJson');
        final doc = Document.fromJson(docJson);
        final length = doc.length;

        // Create delta for the new section
        final delta = Delta()
          ..retain(length > 0 ? length - 1 : 0) // Go to end of document
          ..insert('\n') // Add newline before header
          ..insert(sectionTitle) // Add section title
          ..insert('\n', {'header': level}) // Add header attribute
          ..insert('\n'); // Add extra newline after header

        // Apply the changes
        doc.compose(delta, ChangeSource.local);

        // Update document content
        final updatedContent = jsonEncode(doc.toDelta().toJson());
        print('Updated document content: $updatedContent');

        // Update the document through the bloc
        context.read<DocumentBloc>().add(UpdateDocument(
              documentId: widget.document.id,
              content: updatedContent,
            ));

        // Notify parent of content change
        if (widget.onContentChanged != null) {
          widget.onContentChanged!(updatedContent);
        }

        // Update local state
        setState(() {
          _parseSections();
        });
      } catch (e, stackTrace) {
        print('Error adding section: $e');
        print('Stack trace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding section: $e')),
          );
        }
      }
    }
  }

  Future<void> _updateSectionOrder() async {
    try {
      // Get the current document content from the bloc
      final currentState = context.read<DocumentBloc>().state;
      if (currentState is! DocumentLoaded) {
        print('Document not loaded in bloc');
        return;
      }

      // Create a new document with sections in the new order
      final doc = Document();

      for (var i = 0; i < _sections.length; i++) {
        final section = _sections[i];
        if (i > 0) doc.insert(doc.length, '\n');
        doc.insert(doc.length, section.title);
        doc.format(doc.length - section.title.length, section.title.length,
            Attribute.h1); // Use predefined header attribute
      }

      // Add final newline if needed
      if (doc.length == 0 || !doc.toPlainText().endsWith('\n')) {
        doc.insert(doc.length, '\n');
      }

      // Update document content
      final updatedContent = jsonEncode(doc.toDelta().toJson());
      print('Reordered document content: $updatedContent');

      // Update the document through the bloc
      context.read<DocumentBloc>().add(UpdateDocument(
            documentId: widget.document.id,
            content: updatedContent,
          ));

      // Notify parent of content change
      if (widget.onContentChanged != null) {
        widget.onContentChanged!(updatedContent);
      }
    } catch (e, stackTrace) {
      print('Error updating section order: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating section order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (state is DocumentLoaded) {
          // Update sections when document content changes
          if (state.document.document.content != widget.document.content) {
            print('Document content changed in bloc, updating sections');
            _parseSections();
          }
        }
      },
      child: Column(
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
      ),
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
