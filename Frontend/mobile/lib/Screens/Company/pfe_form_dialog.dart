// filepath: /Users/fedynouri/Desktop/pfe-match/Frontend/mobile/lib/Screens/Company/pfe_form_dialog.dart

import 'package:flutter/material.dart';

class PFEFormDialog extends StatefulWidget {
  const PFEFormDialog({Key? key}) : super(key: key);

  @override
  State<PFEFormDialog> createState() => _PFEFormDialogState();
}

class _PFEFormDialogState extends State<PFEFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  String _category = '';
  String _duration = '';
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _departmentCtrl = TextEditingController();
  final List<String> _availableSkills = [
    'Python',
    'Dart',
    'Flutter',
    'Machine Learning',
    'IoT',
    'React',
    'Node.js'
  ];
  final List<String> _selectedSkills = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _departmentCtrl.dispose();
    super.dispose();
  }

  void _toggleSkill(String s) {
    setState(() {
      if (_selectedSkills.contains(s)) {
        _selectedSkills.remove(s);
      } else {
        if (_selectedSkills.length < 10) _selectedSkills.add(s);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _selectedSkills.isEmpty) {
      // mark fields
      return;
    }

    final payload = {
      'title': _titleCtrl.text.trim(),
      'category': _category,
      'duration': _duration,
      'description': _descriptionCtrl.text.trim(),
      'department': _departmentCtrl.text.trim(),
      'status': 'open',
      'skills': _selectedSkills,
    };

    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create PFE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _category.isEmpty ? null : _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'Artificial Intelligence', child: Text('Artificial Intelligence')),
                        DropdownMenuItem(value: 'Mobile Development', child: Text('Mobile Development')),
                        DropdownMenuItem(value: 'Web Development', child: Text('Web Development')),
                        DropdownMenuItem(value: 'Data Science', child: Text('Data Science')),
                        DropdownMenuItem(value: 'IoT', child: Text('IoT')),
                      ],
                      onChanged: (v) => setState(() => _category = v ?? ''),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _duration.isEmpty ? null : _duration,
                      decoration: const InputDecoration(labelText: 'Duration'),
                      items: const [
                        DropdownMenuItem(value: '2 months', child: Text('2 months')),
                        DropdownMenuItem(value: '3 months', child: Text('3 months')),
                        DropdownMenuItem(value: '4 months', child: Text('4 months')),
                        DropdownMenuItem(value: '6 months', child: Text('6 months')),
                      ],
                      onChanged: (v) => setState(() => _duration = v ?? ''),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionCtrl,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 4,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _departmentCtrl,
                      decoration: const InputDecoration(labelText: 'Department (optional)'),
                    ),
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerLeft, child: Text('Skills', style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableSkills.map((s) {
                        final selected = _selectedSkills.contains(s);
                        return ChoiceChip(
                          label: Text(s),
                          selected: selected,
                          onSelected: (_) => _toggleSkill(s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                        const SizedBox(width: 8),
                        ElevatedButton(onPressed: _submit, child: const Text('Create')),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

