import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/config/routes.dart';

class CreateStudentProfileScreen extends StatefulWidget {
  const CreateStudentProfileScreen({super.key});

  @override
  State<CreateStudentProfileScreen> createState() =>
      _CreateStudentProfileScreenState();
}

class _CreateStudentProfileScreenState
    extends State<CreateStudentProfileScreen> {
  int _currentStep = 1;
  final _formKey = GlobalKey<FormState>();
  final _errors = <String, String>{};

  final _titleController = TextEditingController();
  final _universityController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();

  // Resume state
  String _resumeName = '';
  Uint8List? _resumeBytes;
  int _resumeSize = 0;
  bool _isUploadingResume = false;
  String? _resumeError;

  final List<String> _skills = [];
  bool _isCreatingProfile = false;

  double get _progressValue => _currentStep / 2;

  String get _formattedFileSize {
    if (_resumeSize < 1024) return '$_resumeSize B';
    if (_resumeSize < 1024 * 1024)
      return '${(_resumeSize / 1024).toStringAsFixed(1)} KB';
    return '${(_resumeSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _universityController.dispose();
    _bioController.dispose();
    _skillController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  bool _validateStep(int step) {
    final newErrors = <String, String>{};

    if (step == 1) {
      if (_titleController.text.trim().isEmpty) {
        newErrors['title'] = 'Desired job role is required';
      }
      if (_universityController.text.trim().isEmpty) {
        newErrors['university'] = 'University is required';
      }
      if (_bioController.text.trim().isEmpty) {
        newErrors['bio'] = 'Bio is required';
      } else if (_bioController.text.trim().length < 20) {
        newErrors['bio'] = 'Bio must be at least 20 characters';
      }
    }

    setState(() {
      _errors.clear();
      _errors.addAll(newErrors);
    });
    return newErrors.isEmpty;
  }

  void _handleNext() {
    if (_validateStep(_currentStep)) {
      setState(() => _currentStep = 2);
    }
  }

  void _handleBack() {
    setState(() => _currentStep = 1);
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  Future<void> _pickResume() async {
    setState(() {
      _resumeError = null;
      _isUploadingResume = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true, // Required for web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          setState(() {
            _resumeError = 'File size must be less than 5MB';
            _isUploadingResume = false;
          });
          return;
        }

        // Check if it's a PDF
        if (file.extension?.toLowerCase() != 'pdf') {
          setState(() {
            _resumeError = 'Only PDF files are allowed';
            _isUploadingResume = false;
          });
          return;
        }

        setState(() {
          _resumeName = file.name;
          _resumeBytes = file.bytes;
          _resumeSize = file.size;
          _isUploadingResume = false;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Resume "${file.name}" uploaded successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() => _isUploadingResume = false);
      }
    } catch (e) {
      setState(() {
        _resumeError = 'Failed to upload file: ${e.toString()}';
        _isUploadingResume = false;
      });
    }
  }

  void _clearResume() {
    setState(() {
      _resumeName = '';
      _resumeBytes = null;
      _resumeSize = 0;
      _resumeError = null;
    });
  }

  Future<void> _createProfile() async {
    setState(() => _isCreatingProfile = true);

    try {
      // Prepare profile data
      final profileData = {
        'title': _titleController.text.trim(),
        'university': _universityController.text.trim(),
        'bio': _bioController.text.trim(),
        'linkedin': _linkedinController.text.trim(),
        'github': _githubController.text.trim(),
        'skills': _skills,
        'resumeName': _resumeName,
        'resumeSize': _resumeSize,
      };

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile created successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create profile: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingProfile = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStepIndicator(),
              const SizedBox(height: 24),
              _buildStepContent(),
              const SizedBox(height: 24),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 32, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text(
              'Create Your Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Complete your profile to start applying for PFE opportunities',
          style: TextStyle(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStepItem(1, 'Basic Info', Icons.person),
            Container(
              height: 2,
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: _currentStep > 1
                  ? AppColors.primary
                  : Colors.grey.withOpacity(0.3),
            ),
            _buildStepItem(2, 'Resume', Icons.description),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progressValue,
            backgroundColor: Colors.grey.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(int step, String title, IconData icon) {
    final isComplete = _currentStep > step;
    final isActive = _currentStep == step;

    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isComplete
                  ? AppColors.primary
                  : (isActive
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent),
              border: Border.all(
                color: isComplete || isActive
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              isComplete ? Icons.check : icon,
              size: 20,
              color: isComplete
                  ? Colors.white
                  : (isActive ? AppColors.primary : Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive || isComplete ? AppColors.primary : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.person, 'Basic Information'),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _titleController,
          label: 'Desired Job Role *',
          hint: 'e.g., Full Stack Developer',
          icon: Icons.work_outline,
          error: _errors['title'],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _universityController,
          label: 'University *',
          hint: 'e.g., INSAT',
          icon: Icons.school_outlined,
          error: _errors['university'],
        ),
        const SizedBox(height: 16),
        _buildBioField(),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(Icons.description, 'Resume & Skills'),
        const SizedBox(height: 16),
        _buildResumeUpload(),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _linkedinController,
          label: 'LinkedIn',
          hint: 'https://linkedin.com/in/...',
          icon: Icons.link,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _githubController,
          label: 'GitHub',
          hint: 'https://github.com/...',
          icon: Icons.code,
        ),
        const SizedBox(height: 24),
        _buildSkillsSection(),
      ],
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: error != null ? AppColors.error : AppColors.border,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              error,
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Short Bio *',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bioController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tell us about yourself...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: _errors['bio'] != null
                    ? AppColors.error
                    : AppColors.border,
              ),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_errors['bio'] != null)
              Text(
                _errors['bio']!,
                style: TextStyle(color: AppColors.error, fontSize: 12),
              )
            else
              const SizedBox.shrink(),
            Text(
              '${_bioController.text.length} chars',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResumeUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Resume',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PDF only',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Upload Area
        InkWell(
          onTap: _isUploadingResume ? null : _pickResume,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _resumeName.isNotEmpty
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
              border: Border.all(
                color: _resumeError != null
                    ? AppColors.error
                    : (_resumeName.isNotEmpty
                          ? AppColors.primary.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3)),
                width: 2,
                style: _resumeName.isEmpty
                    ? BorderStyle.solid
                    : BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isUploadingResume
                ? _buildUploadingState()
                : (_resumeName.isNotEmpty
                      ? _buildUploadedState()
                      : _buildEmptyState()),
          ),
        ),

        // Error Message
        if (_resumeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  _resumeError!,
                  style: TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ],
            ),
          ),

        // Helper Text
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Maximum file size: 5MB',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cloud_upload_outlined,
            size: 32,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Click to upload your resume',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'or drag and drop',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf, size: 16, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'PDF',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Uploading...',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          'Please wait',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildUploadedState() {
    return Row(
      children: [
        // PDF Icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.picture_as_pdf, size: 28, color: Colors.red),
        ),
        const SizedBox(width: 16),

        // File Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _resumeName,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Uploaded • $_formattedFileSize',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Replace Button
            IconButton(
              onPressed: _pickResume,
              icon: Icon(Icons.refresh, size: 20, color: AppColors.primary),
              tooltip: 'Replace',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 4),
            // Delete Button
            IconButton(
              onPressed: _clearResume,
              icon: Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red[400],
              ),
              tooltip: 'Remove',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skills',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                decoration: InputDecoration(
                  hintText: 'Add a skill...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _addSkill(),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 48,
              width: 48,
              child: ElevatedButton(
                onPressed: _addSkill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_skills.isEmpty)
          Text(
            'No skills added',
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeSkill(skill),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 1) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _handleBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _isCreatingProfile
                ? null
                : (_currentStep < 2 ? _handleNext : _createProfile),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isCreatingProfile
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentStep < 2 ? 'Next' : 'Create Profile',
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }
}
