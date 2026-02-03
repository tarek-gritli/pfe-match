import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:mobile/core/config/routes.dart';
import '../../Services/enterprise_service.dart';

class CreateEnterpriseProfileScreen extends StatefulWidget {
  const CreateEnterpriseProfileScreen({super.key});

  @override
  State<CreateEnterpriseProfileScreen> createState() =>
      _CreateEnterpriseProfileScreenState();
}

class _CreateEnterpriseProfileScreenState
    extends State<CreateEnterpriseProfileScreen> {
  final EnterpriseService _enterpriseService = EnterpriseService();

  int _currentStep = 1;
  final int _totalSteps = 2;

  // -----------------------------------------------------------------------
  // Form controllers
  // -----------------------------------------------------------------------
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _foundedYearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _newTechController = TextEditingController();

  // -----------------------------------------------------------------------
  // Form data
  // -----------------------------------------------------------------------
  List<String> _technologies = [];
  File? _logoFile;
  Uint8List? _logoBytes;
  String _logoName = '';

  // -----------------------------------------------------------------------
  // State flags
  // -----------------------------------------------------------------------
  bool _isUploadingLogo = false;
  bool _isSubmitting = false;
  bool _showIndustryDropdown = false;
  bool _showSizeDropdown = false;

  // -----------------------------------------------------------------------
  // Validation errors
  // -----------------------------------------------------------------------
  Map<String, String> _errors = {};

  // -----------------------------------------------------------------------
  // Static suggestion data
  // -----------------------------------------------------------------------
  static const List<String> _industryOptions = [
    'Technology',
    'Finance & Banking',
    'Healthcare',
    'Education',
    'E-Commerce',
    'Telecommunications',
    'Energy & Utilities',
    'Real Estate',
    'Manufacturing',
    'Consulting',
    'Media & Entertainment',
    'Automotive',
    'Agriculture',
    'Logistics & Transportation',
    'Government',
    'Non-Profit',
    'Food & Beverage',
    'Retail',
    'Construction',
    'Cybersecurity',
  ];

  static const List<String> _sizeOptions = [
    '1-10 employees',
    '11-50 employees',
    '51-100 employees',
    '101-500 employees',
    '500+ employees',
  ];

  static const List<String> _allTechnologies = [
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'C++',
    'C#',
    'React',
    'Angular',
    'Vue.js',
    'Node.js',
    'Express',
    'Django',
    'Spring Boot',
    'Machine Learning',
    'Data Science',
    'SQL',
    'MongoDB',
    'PostgreSQL',
    'AWS',
    'Azure',
    'Google Cloud',
    'Docker',
    'Kubernetes',
    'Flutter',
    'Swift',
    'Kotlin',
    'Go',
    'Rust',
    'GraphQL',
    'REST API',
    'Microservices',
    'CI/CD',
    'Terraform',
    'Redis',
    'Elasticsearch',
    'SAP',
    'Salesforce',
  ];

  final List<Map<String, dynamic>> _steps = [
    {'id': 1, 'title': 'Company Info', 'icon': Icons.business},
    {'id': 2, 'title': 'Tech & Contact', 'icon': Icons.link},
  ];

  // -----------------------------------------------------------------------
  // Lifecycle
  // -----------------------------------------------------------------------
  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _locationController.dispose();
    _sizeController.dispose();
    _foundedYearController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _contactEmailController.dispose();
    _newTechController.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------------
  // Computed
  // -----------------------------------------------------------------------
  double get _progressValue => (_currentStep / _totalSteps) * 100;

  bool get _hasLogo => _logoBytes != null || _logoFile != null;

  List<String> get _suggestedIndustries {
    final query = _industryController.text.toLowerCase();
    if (query.isEmpty) return _industryOptions;
    return _industryOptions
        .where((i) => i.toLowerCase().contains(query))
        .toList();
  }

  List<String> get _suggestedTechs {
    final query = _newTechController.text.toLowerCase();
    if (query.isEmpty) return [];
    return _allTechnologies
        .where(
          (tech) =>
              !_technologies.contains(tech) &&
              tech.toLowerCase().contains(query),
        )
        .take(5)
        .toList();
  }

  // -----------------------------------------------------------------------
  // Validation
  // -----------------------------------------------------------------------
  bool _validateStep(int step) {
    final newErrors = <String, String>{};

    if (step == 1) {
      if (_nameController.text.trim().isEmpty) {
        newErrors['name'] = 'Company name is required';
      }
      if (_industryController.text.trim().isEmpty) {
        newErrors['industry'] = 'Industry is required';
      }
      if (_descriptionController.text.trim().isEmpty) {
        newErrors['description'] = 'Description is required';
      } else if (_descriptionController.text.trim().length < 20) {
        newErrors['description'] = 'Description must be at least 20 characters';
      }
      if (_foundedYearController.text.trim().isNotEmpty) {
        final year = int.tryParse(_foundedYearController.text.trim());
        if (year == null || year < 1900 || year > DateTime.now().year) {
          newErrors['foundedYear'] =
              'Enter a valid year between 1900 and ${DateTime.now().year}';
        }
      }
    }

    if (step == 2) {
      if (_contactEmailController.text.trim().isNotEmpty &&
          !_contactEmailController.text.trim().contains('@')) {
        newErrors['contactEmail'] = 'Enter a valid email address';
      }
      if (_websiteController.text.trim().isNotEmpty &&
          !_websiteController.text.trim().startsWith('http')) {
        newErrors['website'] = 'URL must start with http:// or https://';
      }
      if (_linkedinController.text.trim().isNotEmpty &&
          !_linkedinController.text.trim().startsWith('http')) {
        newErrors['linkedin'] = 'URL must start with http:// or https://';
      }
    }

    setState(() => _errors = newErrors);
    return newErrors.isEmpty;
  }

  // -----------------------------------------------------------------------
  // Navigation
  // -----------------------------------------------------------------------
  void _handleNext() {
    if (_validateStep(_currentStep)) {
      setState(() {
        _currentStep = (_currentStep + 1).clamp(1, _totalSteps);
      });
    }
  }

  void _handleBack() {
    setState(() {
      _currentStep = (_currentStep - 1).clamp(1, _totalSteps);
    });
  }

  // -----------------------------------------------------------------------
  // Technologies
  // -----------------------------------------------------------------------
  void _handleAddTech() {
    final tech = _newTechController.text.trim();
    if (tech.isNotEmpty && !_technologies.contains(tech)) {
      setState(() {
        _technologies.add(tech);
        _newTechController.clear();
      });
    }
  }

  void _handleRemoveTech(String tech) {
    setState(() => _technologies.remove(tech));
  }

  void _selectSuggestedTech(String tech) {
    setState(() {
      _technologies.add(tech);
      _newTechController.clear();
    });
  }

  // -----------------------------------------------------------------------
  // Logo upload  (same FilePicker pattern as student profile image)
  // -----------------------------------------------------------------------
  Future<void> _handleLogoUpload() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.single.bytes == null) return;

      final pickedFile = result.files.single;

      setState(() {
        _logoBytes = pickedFile.bytes;
        _logoName = pickedFile.name;
        _isUploadingLogo = true;
      });

      if (!kIsWeb && pickedFile.path != null) {
        _logoFile = File(pickedFile.path!);

        final response =
            await _enterpriseService.uploadLogo(_logoFile!);

        setState(() {
          _logoName = response['logo_url'] ?? _logoName;
          _logoFile = null;
        });
      }

      setState(() => _isUploadingLogo = false);
    } catch (e) {
      setState(() {
        _isUploadingLogo = false;
        _errors['logo'] = 'Failed to upload logo';
      });
    }
  }

  // -----------------------------------------------------------------------
  // Submit
  // -----------------------------------------------------------------------
  Future<void> _handleCreateProfile() async {
    if (!_validateStep(_currentStep)) return;

    setState(() => _isSubmitting = true);

    final payload = {
      'company_name': _nameController.text.trim(),
      'industry': _industryController.text.trim(),
      'location': _locationController.text.trim(),
      'employee_count': _sizeController.text.trim(),
      'company_description': _descriptionController.text.trim(),
      'website': _websiteController.text.trim(),
      'linkedin_url': _linkedinController.text.trim(),
      'contact_email': _contactEmailController.text.trim(),
      'technologies_used': _technologies,
      if (_foundedYearController.text.trim().isNotEmpty)
        'founded_year': int.parse(_foundedYearController.text.trim()),
    };

    try {
      await _enterpriseService.updateMyProfile(payload);
      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company profile created successfully!')),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.enterpriseProfile);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create profile: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // -----------------------------------------------------------------------
  // BUILD
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar:
          AppBar(title: const Text('Create Company Profile'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              _buildStepIndicator(theme),
              const SizedBox(height: 8),
              _buildProgressBar(theme),
              const SizedBox(height: 24),
              _buildStepContent(theme),
              const SizedBox(height: 24),
              _buildNavigationButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Header
  // -----------------------------------------------------------------------
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              'Create Company Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in your company details to get started',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Step indicator  (identical structure to student version)
  // -----------------------------------------------------------------------
  Widget _buildStepIndicator(ThemeData theme) {
    return Row(
      children: _steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isComplete = _currentStep > step['id'];
        final isActive = _currentStep == step['id'];

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isComplete
                            ? theme.colorScheme.primary
                            : isActive
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: isComplete || isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isComplete ? Icons.check : step['icon'],
                        size: 20,
                        color: isComplete
                            ? theme.colorScheme.onPrimary
                            : isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['title'],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isActive
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (index < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 24),
                    color: _currentStep > step['id']
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // -----------------------------------------------------------------------
  // Progress bar
  // -----------------------------------------------------------------------
  Widget _buildProgressBar(ThemeData theme) {
    return LinearProgressIndicator(
      value: _progressValue / 100,
      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
    );
  }

  // -----------------------------------------------------------------------
  // Step router
  // -----------------------------------------------------------------------
  Widget _buildStepContent(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _currentStep == 1
            ? _buildCompanyInfoStep(theme)
            : _buildTechAndContactStep(theme),
      ),
    );
  }

  // =======================================================================
  // STEP 1 — Company Information
  // =======================================================================
  Widget _buildCompanyInfoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Icon(Icons.business, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Company Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about your company',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),

        // Logo upload
        _buildLogoUploader(theme),
        const SizedBox(height: 24),

        // Company Name *
        _buildTextField(
          controller: _nameController,
          label: 'Company Name *',
          hint: 'e.g., Acme Corporation',
          error: _errors['name'],
          theme: theme,
        ),
        const SizedBox(height: 16),

        // Industry * (text field + dropdown suggestions)
        _buildIndustryField(theme),
        const SizedBox(height: 16),

        // Location
        _buildTextField(
          controller: _locationController,
          label: 'Location',
          hint: 'e.g., San Francisco, CA',
          theme: theme,
        ),
        const SizedBox(height: 16),

        // Company Size (text field + dropdown)
        _buildSizeField(theme),
        const SizedBox(height: 16),

        // Founded Year
        _buildTextField(
          controller: _foundedYearController,
          label: 'Founded Year',
          hint: 'e.g., 2015',
          error: _errors['foundedYear'],
          theme: theme,
          keyboardType: const TextInputType.numberWithOptions(signed: false),
          maxLength: 4,
        ),
        const SizedBox(height: 16),

        // Description *
        _buildTextField(
          controller: _descriptionController,
          label: 'Description *',
          hint:
              'Describe what your company does, your mission, and what makes you unique...',
          error: _errors['description'],
          maxLines: 4,
          theme: theme,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minimum 20 characters',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            Text(
              '${_descriptionController.text.length}/1000',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =======================================================================
  // STEP 2 — Technologies & Contact
  // =======================================================================
  Widget _buildTechAndContactStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Icon(Icons.code, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Technologies & Contact',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add your tech stack and contact details',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),

        // Technologies
        Text('Technologies & Stack', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildTagInput(
          controller: _newTechController,
          tags: _technologies,
          suggestions: _suggestedTechs,
          onAdd: _handleAddTech,
          onRemove: _handleRemoveTech,
          onSelectSuggestion: _selectSuggestedTech,
          hint: 'Add a technology...',
          theme: theme,
        ),
        const SizedBox(height: 24),

        // Links & Contact
        Text('Links & Contact', style: theme.textTheme.titleSmall),
        const SizedBox(height: 16),
        _buildLinkField(
          controller: _websiteController,
          label: 'Website',
          icon: Icons.web,
          hint: 'https://yourcompany.com',
          error: _errors['website'],
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildLinkField(
          controller: _linkedinController,
          label: 'LinkedIn',
          icon: Icons.business,
          hint: 'https://linkedin.com/company/yourcompany',
          error: _errors['linkedin'],
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildLinkField(
          controller: _contactEmailController,
          label: 'Email',
          icon: Icons.email_outlined,
          hint: 'contact@yourcompany.com',
          error: _errors['contactEmail'],
          theme: theme,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // =======================================================================
  // REUSABLE WIDGETS
  // =======================================================================

  // -----------------------------------------------------------------------
  // Logo uploader
  // -----------------------------------------------------------------------
  Widget _buildLogoUploader(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              // Logo circle
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.onSurface.withOpacity(0.08),
                  image: _logoBytes != null
                      ? DecorationImage(
                          image: MemoryImage(_logoBytes!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _logoBytes == null
                    ? Center(
                        child: Icon(
                          Icons.business,
                          size: 44,
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.35),
                        ),
                      )
                    : null,
              ),
              // Camera badge
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingLogo ? null : _handleLogoUpload,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: _isUploadingLogo
                        ? const Padding(
                            padding: EdgeInsets.all(7),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _hasLogo ? 'Tap to change logo' : 'Upload company logo',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          if (_errors['logo'] != null) ...[
            const SizedBox(height: 4),
            Text(
              _errors['logo']!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Industry field with dropdown
  // -----------------------------------------------------------------------
  Widget _buildIndustryField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Industry *', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _industryController,
                onChanged: (_) => setState(() => _showIndustryDropdown = true),
                onTap: () => setState(() => _showIndustryDropdown = true),
                decoration: InputDecoration(
                  hintText: 'e.g., Technology, Healthcare',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _errors['industry'] != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _errors['industry'] != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: _errors['industry'] != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: Icon(
                    _showIndustryDropdown
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Dropdown list
        if (_showIndustryDropdown && _suggestedIndustries.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestedIndustries.length,
              itemBuilder: (_, index) {
                final industry = _suggestedIndustries[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _industryController.text = industry;
                      _showIndustryDropdown = false;
                      _errors.remove('industry');
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Text(industry),
                  ),
                );
              },
            ),
          ),
        ],
        if (_errors['industry'] != null) ...[
          const SizedBox(height: 4),
          Text(
            _errors['industry']!,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Size field with dropdown
  // -----------------------------------------------------------------------
  Widget _buildSizeField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Company Size', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _sizeController,
          readOnly: true,
          onTap: () =>
              setState(() => _showSizeDropdown = !_showSizeDropdown),
          decoration: InputDecoration(
            hintText: 'Select company size',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            suffixIcon: Icon(
              _showSizeDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
        if (_showSizeDropdown) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _sizeOptions.map((size) {
                final isSelected = _sizeController.text == size;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _sizeController.text = size;
                      _showSizeDropdown = false;
                    });
                  },
                  child: Container(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.08)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(size),
                          if (isSelected)
                            Icon(Icons.check,
                                color: theme.colorScheme.primary, size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Generic text field (identical signature to student version +
  // keyboardType / maxLength overloads)
  // -----------------------------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
    String? error,
    int maxLines = 1,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          maxLength: maxLength,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: error != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: error != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: error != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Tag input (technologies)
  // -----------------------------------------------------------------------
  Widget _buildTagInput({
    required TextEditingController controller,
    required List<String> tags,
    required List<String> suggestions,
    required VoidCallback onAdd,
    required Function(String) onRemove,
    required Function(String) onSelectSuggestion,
    required String hint,
    required ThemeData theme,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => onAdd(),
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: onAdd, child: const Icon(Icons.add)),
          ],
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: suggestions.map((suggestion) {
                return InkWell(
                  onTap: () => onSelectSuggestion(suggestion),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Text(suggestion),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.isEmpty
              ? [
                  Text(
                    'No technologies added yet',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]
              : tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => onRemove(tag),
                  );
                }).toList(),
        ),
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Link / email field  (same row layout as student; supports optional error)
  // -----------------------------------------------------------------------
  Widget _buildLinkField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required ThemeData theme,
    String? error,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: error != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: error != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: error != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          // Indent the error to align under the text field (icon + label width)
          Padding(
            padding: const EdgeInsets.only(left: 108),
            child: Text(
              error,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }

  // -----------------------------------------------------------------------
  // Navigation buttons (identical structure to student version)
  // -----------------------------------------------------------------------
  Widget _buildNavigationButtons(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 1)
          OutlinedButton.icon(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          )
        else
          const SizedBox.shrink(),
        if (_currentStep < _totalSteps)
          ElevatedButton.icon(
            onPressed: _handleNext,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          )
        else
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : _handleCreateProfile,
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label:
                Text(_isSubmitting ? 'Creating...' : 'Create Profile'),
          ),
      ],
    );
  }
}