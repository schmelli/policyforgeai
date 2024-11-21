import 'package:flutter/material.dart';

class CreateNodeDialog extends StatefulWidget {
  final String title;
  final String type;
  final String? parentName;

  const CreateNodeDialog({
    super.key,
    required this.title,
    required this.type,
    this.parentName,
  });

  @override
  State<CreateNodeDialog> createState() => _CreateNodeDialogState();
}

class _CreateNodeDialogState extends State<CreateNodeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.parentName != null) ...[
              Text(
                'Creating ${widget.type} in: ${widget.parentName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '${widget.type} Name',
                hintText: 'Enter a name for the ${widget.type.toLowerCase()}',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_nameController.text);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
