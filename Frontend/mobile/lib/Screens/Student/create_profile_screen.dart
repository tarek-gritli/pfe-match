import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/config/routes.dart';
import 'package:provider/provider.dart';
import '../../Services/student_service.dart';
import '../../providers/auth_provider.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final StudentService _studentService = StudentService();

  int _currentStep = 1;
  final int _totalSteps = 2;

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _githubController = TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  final TextEditingController _newSkillController = TextEditingController();
  final TextEditingController _newTechController = TextEditingController();

  // Form data
  String _profileImage = '';
  List<String> _skills = [];
  List<String> _technologies = [];
  String _resumeName = '';
  File? _resumeFile;
  Uint8List? _resumeBytes; // For web
  File? _profileImageFile;
  Uint8List? _profileImageBytes; // For web

  // State flags
  bool _isUploadingResume = false;
  bool _isUploadingImage = false;
  bool _isSubmitting = false;

  // Errors
  Map<String, String> _errors = {};

  // Skill suggestions
  final List<String> _allSkills = [
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'C++',
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
    'Docker',
    'Kubernetes',
    'Flutter',
    'Dart',
    'Swift',
    'Kotlin',
    'Go',
    'Rust',
    'GraphQL',
    'REST API',
  ];

  final List<Map<String, dynamic>> _steps = [
    {'id': 1, 'title': 'Basic Information', 'icon': Icons.person},
    {'id': 2, 'title': 'Resume', 'icon': Icons.description},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _universityController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _newSkillController.dispose();
    _newTechController.dispose();
    super.dispose();
  }

  double get _progressValue => (_currentStep / _totalSteps) * 100;

  List<String> get _suggestedSkills {
    final query = _newSkillController.text.toLowerCase();
    if (query.isEmpty) return [];
    return _allSkills
        .where(
          (skill) =>
              !_skills.contains(skill) && skill.toLowerCase().contains(query),
        )
        .take(5)
        .toList();
  }

  List<String> get _suggestedTechs {
    final query = _newTechController.text.toLowerCase();
    if (query.isEmpty) return [];
    return _allSkills
        .where(
          (tech) =>
              !_technologies.contains(tech) &&
              tech.toLowerCase().contains(query),
        )
        .take(5)
        .toList();
  }

  bool _validateStep(int step) {
    final newErrors = <String, String>{};

    if (step == 1) {
      if (_titleController.text.trim().isEmpty) {
        newErrors['title'] = 'Desired job role is required';
      }
      if (_bioController.text.trim().isEmpty) {
        newErrors['bio'] = 'Bio is required';
      } else if (_bioController.text.trim().length < 20) {
        newErrors['bio'] = 'Bio must be at least 20 characters';
      }
    }

    if (step == 2) {
      if (_resumeName.isNotEmpty && _skills.isEmpty) {
        newErrors['skills'] = 'At least one skill is required';
      }
    }

    setState(() => _errors = newErrors);
    return newErrors.isEmpty;
  }

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

  void _handleAddSkill() {
    final skill = _newSkillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _newSkillController.clear();
        _errors.remove('skills');
      });
    }
  }

  void _handleRemoveSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

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
    setState(() {
      _technologies.remove(tech);
    });
  }

  void _selectSuggestedSkill(String skill) {
    setState(() {
      _skills.add(skill);
      _newSkillController.clear();
      _errors.remove('skills');
    });
  }

  void _selectSuggestedTech(String tech) {
    setState(() {
      _technologies.add(tech);
      _newTechController.clear();
    });
  }

  Future<void> _handleResumeUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb, // Get bytes for web
    );

    if (result != null && result.files.single.bytes != null ||
        result != null && result.files.single.path != null) {
      setState(() {
        _resumeName = result.files.single.name;
        _isUploadingResume = true;
        if (kIsWeb) {
          _resumeBytes = result.files.single.bytes;
        } else {
          _resumeFile = File(result.files.single.path!);
        }
      });

      try {
        // For now, skip actual upload on web if service doesn't support bytes
        if (!kIsWeb && _resumeFile != null) {
          final response = await _studentService.uploadResume(_resumeFile!);
          if (response['extracted_data'] != null) {
            final extractedData = response['extracted_data'];
            setState(() {
              if (extractedData['github_url'] != null &&
                  _githubController.text.isEmpty) {
                _githubController.text = extractedData['github_url'];
              }
              if (extractedData['linkedin_url'] != null &&
                  _linkedinController.text.isEmpty) {
                _linkedinController.text = extractedData['linkedin_url'];
              }
              if (extractedData['skills'] != null && _skills.isEmpty) {
                _skills = List<String>.from(extractedData['skills']);
              }
              if (extractedData['technologies'] != null &&
                  _technologies.isEmpty) {
                _technologies = List<String>.from(
                  extractedData['technologies'],
                );
              }
            });
          }
        }
        setState(() {
          _isUploadingResume = false;
        });
      } catch (e) {
        setState(() {
          _isUploadingResume = false;
          _errors['resume'] = 'Failed to upload resume';
        });
      }
    }
  }

  Future<void> _handleProfileImageUpload() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true, // for web preview
    );

    if (result == null || result.files.single.bytes == null) return;

    final pickedFile = result.files.single;

    setState(() {
      _profileImageBytes = pickedFile.bytes; // preview
      _profileImage = pickedFile.name;
      _isUploadingImage = true;
    });

    // For mobile: create a File from path
    if (!kIsWeb && pickedFile.path != null) {
      _profileImageFile = File(pickedFile.path!);

      // Upload immediately
      final response =
          await _studentService.uploadStudentProfilePicture(_profileImageFile!);

      setState(() {
        _profileImage = response['profile_picture_url'] ?? _profileImage;
        _profileImageFile = null; // clear local file after upload
      });
    }
    setState(() {
      _isUploadingImage = false;
    });
  } catch (e) {
    setState(() {
      _isUploadingImage = false;
      _errors['profileImage'] = 'Failed to upload image';
    });
  }
}


  void _clearResume() {
    setState(() {
      _resumeName = '';
      _resumeFile = null;
      _resumeBytes = null;
    });
  }


  Future<void> _handleCreateProfile() async {
    if (!_validateStep(_currentStep)) return;

    setState(() => _isSubmitting = true);

    final payload = {
      'university': _universityController.text,
      'short_bio': _bioController.text,
      'desired_job_role': _titleController.text,
      'linkedin_url': _linkedinController.text,
      'github_url': _githubController.text,
      'portfolio_url': _portfolioController.text,
      'skills': _skills,
      'technologies': _technologies,
    };

    try {
      await _studentService.updateMyProfile(payload);

      // Mark profile as completed in auth provider
      if (mounted) {
        context.read<AuthProvider>().setProfileCompleted(true);
      }

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile created successfully!')),
        );
        // Navigate to main screen (student home with tabs)
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
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

  // Helper to check if we have a profile image
  bool get _hasProfileImage =>
      _profileImageBytes != null || _profileImageFile != null;

  // Build the profile image widget
  Widget _buildProfileImage(ThemeData theme) {
    if (_profileImageBytes != null) {
      // Use bytes (works on web and mobile)
      return CircleAvatar(
        radius: 48,
        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
        backgroundImage: MemoryImage(_profileImageBytes!),
      );
    } else if (_profileImageFile != null && !kIsWeb) {
      // Use file (mobile only)
      return CircleAvatar(
        radius: 48,
        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
        backgroundImage: FileImage(_profileImageFile!),
      );
    } else {
      // Placeholder
      return CircleAvatar(
        radius: 48,
        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
        child: Icon(
          Icons.person,
          size: 48,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('Create Profile'), centerTitle: true),
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

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              'Create Your Profile',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Complete your profile to get started',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

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
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
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

  Widget _buildProgressBar(ThemeData theme) {
    return LinearProgressIndicator(
      value: _progressValue / 100,
      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _currentStep == 1
            ? _buildBasicInfoStep(theme)
            : _buildResumeStep(theme),
      ),
    );
  }

  Widget _buildBasicInfoStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Basic Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about yourself',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),

        // Profile Picture - Updated to use the new method
        Center(
          child: Stack(
            children: [
              _buildProfileImage(theme),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _handleProfileImageUpload,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingImage
                        ? const Padding(
                            padding: EdgeInsets.all(8),
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
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            _hasProfileImage
                ? 'Tap to change picture'
                : 'Upload a profile picture',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title/Desired Job Role
        _buildTextField(
          controller: _titleController,
          label: 'Desired Job Role *',
          hint: 'e.g., Full Stack Developer, Data Scientist',
          error: _errors['title'],
          theme: theme,
        ),
        const SizedBox(height: 16),

        // University
        _buildTextField(
          controller: _universityController,
          label: 'University',
          hint: 'e.g., MIT, Stanford University',
          theme: theme,
        ),
        const SizedBox(height: 16),

        // Bio
        _buildTextField(
          controller: _bioController,
          label: 'Bio *',
          hint: 'Tell us about yourself, your interests, and career goals...',
          error: _errors['bio'],
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
              '${_bioController.text.length}/500',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumeStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Resume & Skills',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Upload your resume and add your skills',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 24),

        // Resume Upload
        Text('Resume (PDF)', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildResumeUploadArea(theme),
        const SizedBox(height: 24),

        // Skills
        Text('Skills', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        _buildTagInput(
          controller: _newSkillController,
          tags: _skills,
          suggestions: _suggestedSkills,
          onAdd: _handleAddSkill,
          onRemove: _handleRemoveSkill,
          onSelectSuggestion: _selectSuggestedSkill,
          hint: 'Add a skill...',
          error: _errors['skills'],
          theme: theme,
        ),
        const SizedBox(height: 24),

        // Technologies
        Text('Technologies', style: theme.textTheme.titleSmall),
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

        // Links
        Text('Links', style: theme.textTheme.titleSmall),
        const SizedBox(height: 16),
        _buildLinkField(
          controller: _linkedinController,
          label: 'LinkedIn',
          icon: Icons.link,
          hint: 'https://linkedin.com/in/username',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildLinkField(
          controller: _githubController,
          label: 'GitHub',
          icon: Icons.code,
          hint: 'https://github.com/username',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildLinkField(
          controller: _portfolioController,
          label: 'Portfolio',
          icon: Icons.web,
          hint: 'https://yourportfolio.com',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeData theme,
    String? error,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResumeUploadArea(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.5),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isUploadingResume ? null : _handleResumeUpload,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _resumeName.isNotEmpty
                ? Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _resumeName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _isUploadingResume
                                  ? 'Uploading...'
                                  : 'Resume uploaded',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _clearResume,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 40,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload your resume',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'PDF only, max 5MB',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

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
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.isEmpty
              ? [
                  Text(
                    'No items added yet',
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

  Widget _buildLinkField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required ThemeData theme,
  }) {
    return Row(
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
      ],
    );
  }

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
            label: Text(_isSubmitting ? 'Creating...' : 'Create Profile'),
          ),
      ],
    );
  }
}