import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:mobile/core/config/routes.dart';
import '../../models/enterprise.dart';
import '../../Services/enterprise_service.dart';

class EditEnterpriseProfileScreen extends StatefulWidget {
  const EditEnterpriseProfileScreen({super.key});

  @override
  State<EditEnterpriseProfileScreen> createState() =>
      _EditEnterpriseProfileScreenState();
}

class _EditEnterpriseProfileScreenState
    extends State<EditEnterpriseProfileScreen> {
  final EnterpriseService _enterpriseService = EnterpriseService();
  Enterprise? _enterprise;
  bool _isLoading = true;
  String? _error;

  // ─── Controllers ──────────────────────────────────────────────────────────
  late final TextEditingController _nameController;
  late final TextEditingController _industryController;
  late final TextEditingController _locationController;
  late final TextEditingController _sizeController;
  late final TextEditingController _foundedYearController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _websiteController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _contactEmailController;
  final TextEditingController _newTechController = TextEditingController();

  // ─── Form state ───────────────────────────────────────────────────────────
  late List<String> _technologies;

  // Logo state (mirrors student profile-image pattern)
  String? _existingLogoUrl;        // original URL from server
  File? _newLogoFile;              // picked file (native)
  Uint8List? _newLogoBytes;        // picked file bytes (web / preview)
  bool _logoRemoved = false;       // user tapped "remove"

  // ─── Flags ────────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool _isUploadingLogo = false;
  bool _showIndustryDropdown = false;
  bool _showSizeDropdown = false;

  // ─── Validation ───────────────────────────────────────────────────────────
  Map<String, String> _errors = {};

  // ─── Static suggestion data (copied from CreateEnterpriseProfileScreen) ──
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

  // ─── Computed helpers ─────────────────────────────────────────────────────
  List<String> get _suggestedIndustries {
    final query = _industryController.text.toLowerCase();
    if (query.isEmpty) return _industryOptions;
    return _industryOptions
        .where((i) => i.toLowerCase().contains(query))
        .toList();
  }

  List<String> get _suggestedTechs {
    final query = _newTechController.text.trim().toLowerCase();
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

  /// Whether the user currently has *any* logo to show (existing or new).
  bool get _hasLogo =>
      !_logoRemoved &&
      (_newLogoBytes != null ||
          _newLogoFile != null ||
          (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty));

  // ─── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

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

  // ─── Load ─────────────────────────────────────────────────────────────────
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final enterprise = await _enterpriseService.getMyProfile();

      setState(() {
        _enterprise = enterprise;

        _existingLogoUrl =
            enterprise.logo != null && enterprise.logo!.isNotEmpty
                ? _enterpriseService.getLogoUrl(enterprise.logo)
                : null;

        _nameController =
            TextEditingController(text: enterprise.name);
        _industryController =
            TextEditingController(text: enterprise.industry ?? '');
        _locationController =
            TextEditingController(text: enterprise.location ?? '');
        _sizeController =
            TextEditingController(text: enterprise.size ?? '');
        _foundedYearController = TextEditingController(
            text: enterprise.foundedYear?.toString() ?? '');
        _descriptionController =
            TextEditingController(text: enterprise.description ?? '');
        _websiteController =
            TextEditingController(text: enterprise.website ?? '');
        _linkedinController =
            TextEditingController(text: enterprise.linkedinUrl ?? '');
        _contactEmailController =
            TextEditingController(text: enterprise.contactEmail ?? '');

        _technologies = List.from(enterprise.technologies);

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ─── Validation (same rules as CreateEnterpriseProfileScreen) ────────────
  bool _validate() {
    final errs = <String, String>{};

    if (_nameController.text.trim().isEmpty) {
      errs['name'] = 'Company name is required';
    }
    if (_industryController.text.trim().isEmpty) {
      errs['industry'] = 'Industry is required';
    }
    if (_descriptionController.text.trim().isEmpty) {
      errs['description'] = 'Description is required';
    } else if (_descriptionController.text.trim().length < 20) {
      errs['description'] = 'Description must be at least 20 characters';
    }
    if (_foundedYearController.text.trim().isNotEmpty) {
      final year = int.tryParse(_foundedYearController.text.trim());
      if (year == null || year < 1900 || year > DateTime.now().year) {
        errs['foundedYear'] =
            'Enter a valid year between 1900 and ${DateTime.now().year}';
      }
    }
    if (_contactEmailController.text.trim().isNotEmpty &&
        !_contactEmailController.text.trim().contains('@')) {
      errs['contactEmail'] = 'Enter a valid email address';
    }
    if (_websiteController.text.trim().isNotEmpty &&
        !_websiteController.text.trim().startsWith('http')) {
      errs['website'] = 'URL must start with http:// or https://';
    }
    if (_linkedinController.text.trim().isNotEmpty &&
        !_linkedinController.text.trim().startsWith('http')) {
      errs['linkedin'] = 'URL must start with http:// or https://';
    }

    setState(() => _errors = errs);
    return errs.isEmpty;
  }

  // ─── Technologies ─────────────────────────────────────────────────────────
  void _addTech() {
    final tech = _newTechController.text.trim();
    if (tech.isNotEmpty && !_technologies.contains(tech)) {
      setState(() {
        _technologies.add(tech);
        _newTechController.clear();
      });
    }
  }

  void _removeTech(String tech) {
    setState(() => _technologies.remove(tech));
  }

  void _selectSuggestedTech(String tech) {
    setState(() {
      _technologies.add(tech);
      _newTechController.clear();
    });
  }

  // ─── Logo picker (mirrors student _pickProfileImage + Create uploadLogo) ─
  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final pickedFile = result.files.single;

    setState(() {
      _newLogoBytes = pickedFile.bytes;
      _logoRemoved = false;
      _isUploadingLogo = true;
    });

    try {
      if (!kIsWeb && pickedFile.path != null) {
        _newLogoFile = File(pickedFile.path!);

        // Upload via the same service method used in CreateEnterpriseProfileScreen
        final response = await _enterpriseService.uploadLogo(_newLogoFile!);

        setState(() {
          _existingLogoUrl = response['logo_url'];
          _newLogoFile = null;
          _newLogoBytes = null; // server copy is now the source of truth
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logo uploaded successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _newLogoFile = null;
        _newLogoBytes = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload logo: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingLogo = false);
    }
  }

  void _removeLogo() {
    setState(() {
      _newLogoBytes = null;
      _newLogoFile = null;
      _logoRemoved = true;
    });
  }

  // ─── Submit ───────────────────────────────────────────────────────────────
  Future<void> _handleSave() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
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

    // Signal logo removal to backend if needed
    if (_logoRemoved) {
      payload['remove_logo'] = true;
    }

    try {
      // Reuses the same updateMyProfile from CreateEnterpriseProfileScreen
      await _enterpriseService.updateMyProfile(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Return `true` so EnterpriseProfileScreen knows to reload
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text('Error loading profile: $_error'),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLogoSection(),
              const SizedBox(height: 28),
              _buildBasicInfoCard(),
              const SizedBox(height: 20),
              _buildTechnologiesCard(),
              const SizedBox(height: 20),
              _buildLinksCard(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AppBar (identical style to EditStudentProfileScreen) ────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.editEnterpriseProfile),
      ),
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
      centerTitle: true,
    );
  }

  // ─── Logo section (mirrors student _buildProfileImageSection) ────────────
  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(child: _logoWidget()),
              ),
              // Camera overlay
              GestureDetector(
                onTap: _isUploadingLogo ? null : _pickLogo,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: _isUploadingLogo
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 17,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_hasLogo)
            GestureDetector(
              onTap: _removeLogo,
              child: const Text(
                'Remove logo',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const Text(
              'Tap camera to upload a logo',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
        ],
      ),
    );
  }

  Widget _logoWidget() {
    // 1) Newly picked bytes (works on web and native before server round-trip)
    if (_newLogoBytes != null) {
      return Image.memory(_newLogoBytes!, fit: BoxFit.cover);
    }
    // 2) Newly picked file (native only, before upload completes)
    if (_newLogoFile != null && !kIsWeb) {
      return Image.file(_newLogoFile!, fit: BoxFit.cover);
    }
    // 3) Existing server logo (not removed)
    if (!_logoRemoved &&
        _existingLogoUrl != null &&
        _existingLogoUrl!.isNotEmpty) {
      return Image.network(_existingLogoUrl!, fit: BoxFit.cover);
    }
    // 4) Fallback – first letter of company name
    final name = _enterprise?.name ?? '';
    final initial = name.isNotEmpty ? name.trimRight()[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Basic Info card ──────────────────────────────────────────────────────
  Widget _buildBasicInfoCard() {
    return _card(
      children: [
        _cardHeader(Icons.business_outlined, 'Basic Information'),
        const SizedBox(height: 20),
        // Company Name *
        _textField(
          controller: _nameController,
          label: 'Company Name *',
          hint: 'e.g., Acme Corporation',
          error: _errors['name'],
        ),
        const SizedBox(height: 16),
        // Industry * (text field + dropdown – same pattern as Create screen)
        _buildIndustryField(),
        const SizedBox(height: 16),
        // Location
        _textField(
          controller: _locationController,
          label: 'Location',
          hint: 'e.g., San Francisco, CA',
        ),
        const SizedBox(height: 16),
        // Company Size (read-only dropdown – same pattern as Create screen)
        _buildSizeField(),
        const SizedBox(height: 16),
        // Founded Year
        _textField(
          controller: _foundedYearController,
          label: 'Founded Year',
          hint: 'e.g., 2015',
          error: _errors['foundedYear'],
          keyboardType: const TextInputType.numberWithOptions(signed: false),
          maxLength: 4,
        ),
        const SizedBox(height: 16),
        // Description *
        _textField(
          controller: _descriptionController,
          label: 'Description *',
          hint:
              'Describe what your company does, your mission, and what makes you unique...',
          error: _errors['description'],
          maxLines: 4,
          maxLength: 1000,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minimum 20 characters',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            Text(
              '${_descriptionController.text.length}/1000',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Industry field with dropdown (mirrors Create screen exactly) ────────
  Widget _buildIndustryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Industry *',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _industryController,
          onChanged: (_) => setState(() => _showIndustryDropdown = true),
          onTap: () => setState(() => _showIndustryDropdown = true),
          decoration: InputDecoration(
            hintText: 'e.g., Technology, Healthcare',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: _inputBorder(_errors['industry'] != null),
            enabledBorder: _inputBorder(_errors['industry'] != null),
            focusedBorder:
                _inputBorder(_errors['industry'] != null, focused: true),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: Icon(
              _showIndustryDropdown
                  ? Icons.arrow_drop_up
                  : Icons.arrow_drop_down,
              color: Colors.grey[500],
            ),
          ),
        ),
        // Dropdown list
        if (_showIndustryDropdown && _suggestedIndustries.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
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
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(
                      industry,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
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
            style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
          ),
        ],
      ],
    );
  }

  // ─── Size field with dropdown (mirrors Create screen exactly) ─────────────
  Widget _buildSizeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company Size',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _sizeController,
          readOnly: true,
          onTap: () => setState(() => _showSizeDropdown = !_showSizeDropdown),
          decoration: InputDecoration(
            hintText: 'Select company size',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: _inputBorder(false),
            enabledBorder: _inputBorder(false),
            focusedBorder: _inputBorder(false, focused: true),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: Icon(
              _showSizeDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.grey[500],
            ),
          ),
        ),
        if (_showSizeDropdown) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
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
                        ? const Color(0xFF4F46E5).withOpacity(0.08)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            size,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: Color(0xFF4F46E5),
                              size: 18,
                            ),
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

  // ─── Technologies card (tag input with suggestions) ──────────────────────
  Widget _buildTechnologiesCard() {
    return _card(
      children: [
        _cardHeader(Icons.code_outlined, 'Technologies & Stack'),
        const SizedBox(height: 20),
        _tagInput(
          controller: _newTechController,
          tags: _technologies,
          suggestions: _suggestedTechs,
          onAdd: _addTech,
          onRemove: _removeTech,
          onSuggestion: _selectSuggestedTech,
          hint: 'Add a technology…',
          tagColor: const Color(0xFF4F46E5),
          tagTextColor: Colors.white,
        ),
      ],
    );
  }

  // ─── Links & Contact card ─────────────────────────────────────────────────
  Widget _buildLinksCard() {
    return _card(
      children: [
        _cardHeader(Icons.link, 'Links & Contact'),
        const SizedBox(height: 20),
        _linkField(
          _websiteController,
          'Website',
          Icons.web,
          'https://yourcompany.com',
          error: _errors['website'],
        ),
        const SizedBox(height: 12),
        _linkField(
          _linkedinController,
          'LinkedIn',
          Icons.business,
          'https://linkedin.com/company/yourcompany',
          error: _errors['linkedin'],
        ),
        const SizedBox(height: 12),
        _linkField(
          _contactEmailController,
          'Email',
          Icons.email_outlined,
          'contact@yourcompany.com',
          error: _errors['contactEmail'],
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  // ─── Save button (identical style to EditStudentProfileScreen) ───────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _handleSave,
        icon: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(_isSubmitting ? 'Saving…' : 'Save Changes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          disabledBackgroundColor: const Color(0xFF4F46E5).withOpacity(0.5),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REUSABLE WIDGET HELPERS  (matched to EditStudentProfileScreen styling)
  // ─────────────────────────────────────────────────────────────────────────

  /// White card container with rounded corners and subtle border.
  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Section header row: icon + title.
  Widget _cardHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.grey[700]),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  /// Outlined TextField – mirrors EditStudentProfileScreen's _textField.
  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? error,
    int maxLines = 1,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          maxLength: maxLength,
          buildCounter: (BuildContext _, {required int currentLength, int? maxLength, required bool isFocused}) {
            return const SizedBox.shrink(); // hide default counter
          },
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: _inputBorder(error != null),
            enabledBorder: _inputBorder(error != null),
            focusedBorder: _inputBorder(error != null, focused: true),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error,
            style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _inputBorder(bool hasError, {bool focused = false}) {
    final Color color = hasError
        ? const Color(0xFFEF4444)
        : focused
            ? const Color(0xFF4F46E5)
            : Colors.grey[300]!;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: focused ? 2 : 1.5),
    );
  }

  /// Tag input for technologies – mirrors EditStudentProfileScreen's _tagInput.
  Widget _tagInput({
    required TextEditingController controller,
    required List<String> tags,
    required List<String> suggestions,
    required VoidCallback onAdd,
    required Function(String) onRemove,
    required Function(String) onSuggestion,
    required String hint,
    required Color tagColor,
    required Color tagTextColor,
    Color? tagBorder,
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
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: _inputBorder(false),
                  enabledBorder: _inputBorder(false),
                  focusedBorder: _inputBorder(false, focused: true),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add, color: Colors.white),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        // Suggestions dropdown
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: suggestions.map((s) {
                return InkWell(
                  onTap: () => onSuggestion(s),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(
                      s,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
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
            style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
          ),
        ],
        const SizedBox(height: 12),
        // Tag chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.isEmpty
              ? [
                  Text(
                    'No technologies added yet',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]
              : tags.map((tag) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          tagBorder != null ? Border.all(color: tagBorder) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tag,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: tagTextColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => onRemove(tag),
                          child: Icon(
                            Icons.close,
                            size: 15,
                            color: tagTextColor.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
        ),
      ],
    );
  }

  /// Link row – icon + label + text field (mirrors EditStudentProfileScreen's _linkField).
  Widget _linkField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint, {
    String? error,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[500]),
            const SizedBox(width: 10),
            SizedBox(
              width: 78,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: _inputBorder(error != null),
                  enabledBorder: _inputBorder(error != null),
                  focusedBorder: _inputBorder(error != null, focused: true),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          // Indent error to align under the text field (icon 20 + gap 10 + label 78 = 108)
          Padding(
            padding: const EdgeInsets.only(left: 108),
            child: Text(
              error,
              style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ],
    );
  }
}