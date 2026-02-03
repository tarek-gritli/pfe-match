import 'package:flutter/material.dart';

class PFEFormDialog extends StatefulWidget {
  const PFEFormDialog({Key? key}) : super(key: key);

  @override
  State<PFEFormDialog> createState() => _PFEFormDialogState();
}

class _PFEFormDialogState extends State<PFEFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _departmentCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();

  String _category = '';
  String _duration = '';
  DateTime? _deadline;

  final List<String> _categories = [
    'Artificial Intelligence',
    'Web Development',
    'Mobile Development',
    'Data Science',
    'Cybersecurity',
    'Cloud Computing',
    'DevOps',
    'Blockchain',
    'IoT',
    'Game Development'
  ];

  final List<String> _durations = [
    '2 months',
    '3 months',
    '4 months',
    '5 months',
    '6 months'
  ];

  final List<String> _availableSkills = [
    'Python',
    'JavaScript',
    'TypeScript',
    'Java',
    'C++',
    'React',
    'Angular',
    'Vue.js',
    'Node.js',
    'Django',
    'Flask',
    'Spring Boot',
    'TensorFlow',
    'PyTorch',
    'Machine Learning',
    'Deep Learning',
    'NLP',
    'Computer Vision',
    'SQL',
    'MongoDB',
    'PostgreSQL',
    'Docker',
    'Kubernetes',
    'AWS',
    'Azure',
    'GCP',
    'Git',
    'REST API',
    'GraphQL',
    'Microservices'
  ];

  final List<String> _selectedSkills = [];
  String? _dropdownValue;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _departmentCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _addSkill(String? skill) {
    if (skill != null && skill.isNotEmpty && !_selectedSkills.contains(skill)) {
      if (_selectedSkills.length < 10) {
        setState(() {
          _selectedSkills.add(skill);
          _dropdownValue = null; // Reset dropdown after adding
        });
      }
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _selectedSkills.remove(skill);
    });
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4F46E5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_duration.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a duration')),
      );
      return;
    }

    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
      return;
    }

    final payload = {
      'title': _titleCtrl.text.trim(),
      'category': _category,
      'duration': _duration,
      'description': _descriptionCtrl.text.trim(),
      'department': _departmentCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'status': 'open',
      'skills': _selectedSkills,
      if (_deadline != null) 'deadline': _deadline!.toIso8601String(),
    };

    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Create PFE Listing',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'e.g., AI-Powered Chatbot Development',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),

                  // Category
                  DropdownButtonFormField<String>(
                    value: _category.isEmpty ? null : _category,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (v) => setState(() => _category = v ?? ''),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Duration
                  DropdownButtonFormField<String>(
                    value: _duration.isEmpty ? null : _duration,
                    decoration: const InputDecoration(
                      labelText: 'Duration *',
                      border: OutlineInputBorder(),
                    ),
                    items: _durations.map((dur) {
                      return DropdownMenuItem(value: dur, child: Text(dur));
                    }).toList(),
                    onChanged: (v) => setState(() => _duration = v ?? ''),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description *',
                      hintText: 'Describe the project objectives and tasks...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    maxLength: 1000,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Department (optional)
                  TextFormField(
                    controller: _departmentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Department (optional)',
                      hintText: 'e.g., Engineering, R&D',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),

                  // Location (optional)
                  TextFormField(
                    controller: _locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Location (optional)',
                      hintText: 'e.g., Tunis, Remote',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deadline (optional)
                  InkWell(
                    onTap: _selectDeadline,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Application Deadline (optional)',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _deadline == null
                            ? 'Select deadline'
                            : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                        style: TextStyle(
                          color: _deadline == null
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Skills section
                  const Text(
                    'Required Skills *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_selectedSkills.length} selected, max 10',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),

                  // Skills dropdown selector
                  DropdownButtonFormField<String>(
                    key: ValueKey(_selectedSkills.length), // Force rebuild when skills change
                    value: _dropdownValue,
                    decoration: InputDecoration(
                      hintText: 'Add a skill...',
                      border: const OutlineInputBorder(),
                      enabled: _selectedSkills.length < 10,
                    ),
                    hint: const Text('Add a skill...'),
                    items: _availableSkills
                        .where((skill) => !_selectedSkills.contains(skill))
                        .map((skill) {
                      return DropdownMenuItem<String>(
                        value: skill,
                        child: Text(skill),
                      );
                    }).toList(),
                    onChanged: _selectedSkills.length >= 10 ? null : _addSkill,
                  ),
                  const SizedBox(height: 12),

                  // Selected skills chips
                  if (_selectedSkills.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedSkills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeSkill(skill),
                          backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontSize: 14,
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Create PFE'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
