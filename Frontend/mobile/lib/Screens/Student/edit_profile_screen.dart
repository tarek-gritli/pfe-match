import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/student.dart';
import '../../Services/student_service.dart';

class EditStudentProfileScreen extends StatefulWidget {
  const EditStudentProfileScreen({super.key});

  @override
  State<EditStudentProfileScreen> createState() =>
      _EditStudentProfileScreenState();
}

class _EditStudentProfileScreenState extends State<EditStudentProfileScreen> {
  final StudentService _studentService = StudentService();
  Student? _student;
  bool _isLoading = true;
  String? _error;


  // ─── Controllers ────────────────────────────────────────────────────────────
  late final TextEditingController _titleController;
  late final TextEditingController _universityController;
  late final TextEditingController _bioController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _githubController;
  late final TextEditingController _portfolioController;
  late final TextEditingController _portfolioLabelController;
  final TextEditingController _newSkillController = TextEditingController();
  final TextEditingController _newTechController = TextEditingController();

  // ─── Form state ─────────────────────────────────────────────────────────────
  late List<String> _skills;
  late List<String> _technologies;

  // Profile image
  String? _existingProfileImageUrl;   // original URL from the server
  File? _newProfileImageFile;         // picked file (native)
  Uint8List? _newProfileImageBytes;   // picked file bytes (web / preview)
  bool _profileImageRemoved = false;  // user tapped "remove"

  // Resume
  String? _existingResumeName;        // original name from server
  String? _existingResumeUrl;         // original URL from server
  File? _newResumeFile;               // picked file (native)
  Uint8List? _newResumeBytes;         // picked file bytes (web)
  String? _newResumeName;             // picked file name
  bool _resumeRemoved = false;        // user tapped "remove"

  // ─── Flags ──────────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  bool _isUploadingImage = false;
  bool _isUploadingResume = false;

  // ─── Validation ─────────────────────────────────────────────────────────────
  Map<String, String> _errors = {};

  // ─── Skill / Tech suggestions ───────────────────────────────────────────────
  static const List<String> _allSkills = [
    'JavaScript', 'TypeScript', 'Python', 'Java', 'C++', 'React', 'Angular',
    'Vue.js', 'Node.js', 'Express', 'Django', 'Spring Boot',
    'Machine Learning', 'Data Science', 'SQL', 'MongoDB', 'PostgreSQL',
    'AWS', 'Docker', 'Kubernetes', 'Flutter', 'Dart', 'Swift', 'Kotlin',
    'Go', 'Rust', 'GraphQL', 'REST API',
  ];

  List<String> get _suggestedSkills {
    final q = _newSkillController.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _allSkills
        .where((s) => !_skills.contains(s) && s.toLowerCase().contains(q))
        .take(5)
        .toList();
  }

  List<String> get _suggestedTechs {
    final q = _newTechController.text.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _allSkills
        .where((t) => !_technologies.contains(t) && t.toLowerCase().contains(q))
        .take(5)
        .toList();
  }

  
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final student = await _studentService.getMyProfile();

      setState(() {
        _student = student;

        _existingProfileImageUrl =
        student.profileImage != null && student.profileImage!.isNotEmpty
            ? _studentService.getProfileImageUrl(student.profileImage)
            : null;

        // Initialize controllers with loaded values
        _titleController = TextEditingController(text: student.title ?? '');
        _universityController =
            TextEditingController(text: student.university ?? '');
        _bioController = TextEditingController(text: student.bio ?? '');
        _linkedinController =
            TextEditingController(text: student.linkedinUrl ?? '');
        _githubController =
            TextEditingController(text: student.githubUrl ?? '');
        _portfolioController =
            TextEditingController(text: student.customLinkUrl ?? '');
        _portfolioLabelController =
            TextEditingController(text: student.customLinkLabel ?? '');

        _skills = List.from(student.skills);
        _technologies = List.from(student.technologies);

        _existingResumeName = student.resumeName;
        _existingResumeUrl = student.resumeUrl;

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }


  // ─── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadProfile(); // fetch latest data from server
  }

  @override
  void dispose() {
    _titleController.dispose();
    _universityController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _portfolioLabelController.dispose();
    _newSkillController.dispose();
    _newTechController.dispose();
    super.dispose();
  }

  // ─── Computed helpers ───────────────────────────────────────────────────────
  /// Whether the user currently has *any* profile image to show (existing or new).
  bool get _hasProfileImage =>
      !_profileImageRemoved &&
      (_newProfileImageBytes != null ||
          _newProfileImageFile != null ||
          (_existingProfileImageUrl != null &&
              _existingProfileImageUrl!.isNotEmpty));

  /// Whether there is a resume to display (existing or newly picked).
  bool get _hasResume =>
      !_resumeRemoved &&
      (_newResumeName != null ||
          (_existingResumeName != null && _existingResumeName!.isNotEmpty));

  /// The visible resume file-name.
  String get _visibleResumeName =>
      _newResumeName ?? _existingResumeName ?? '';

  // ─── Validation ─────────────────────────────────────────────────────────────
  bool _validate() {
    final errs = <String, String>{};

    if (_titleController.text.trim().isEmpty) {
      errs['title'] = 'Desired job role is required';
    }
    if (_bioController.text.trim().isEmpty) {
      errs['bio'] = 'Bio is required';
    } else if (_bioController.text.trim().length < 20) {
      errs['bio'] = 'Bio must be at least 20 characters';
    }

    setState(() => _errors = errs);
    return errs.isEmpty;
  }

  // ─── Skill / Tech actions ───────────────────────────────────────────────────
  void _addSkill() {
    final v = _newSkillController.text.trim();
    if (v.isNotEmpty && !_skills.contains(v)) {
      setState(() {
        _skills.add(v);
        _newSkillController.clear();
        _errors.remove('skills');
      });
    }
  }

  void _addTech() {
    final v = _newTechController.text.trim();
    if (v.isNotEmpty && !_technologies.contains(v)) {
      setState(() {
        _technologies.add(v);
        _newTechController.clear();
      });
    }
  }

  // ─── Image picker ───────────────────────────────────────────────────────────
  Future<void> _pickProfileImage() async {
  // Pick image from gallery
  final result = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (result == null) return;

  final file = File(result.path);

  setState(() {
    _newProfileImageFile = file; // for local preview
    _isUploadingImage = true; // show loading spinner if you want
  });

  try {
    // 1️⃣ Upload to backend
    final response = await _studentService.uploadStudentProfilePicture(file);

    // 2️⃣ Update UI with server image URL
    setState(() {
      _existingProfileImageUrl = response['profile_picture_url'];
      _newProfileImageFile = null; // clear local preview if needed
      _profileImageRemoved = false;
      _isUploadingImage = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image uploaded successfully!')),
    );
  } catch (e) {
    setState(() {
      _newProfileImageFile = null;
      _isUploadingImage = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
    );
  }
}


  void _removeProfileImage() {
    setState(() {
      _newProfileImageBytes  = null;
      _newProfileImageFile   = null;
      _profileImageRemoved   = true;
    });
  }

  // ─── Resume picker ──────────────────────────────────────────────────────────
  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
    );
    if (result == null) return;
    final file = result.files.single;
    if (file.bytes == null && file.path == null) return;

    setState(() {
      _newResumeName  = file.name;
      _resumeRemoved  = false;
      _isUploadingResume = true;
      if (kIsWeb) {
        _newResumeBytes = file.bytes;
        _newResumeFile  = null;
      } else {
        _newResumeFile  = File(file.path!);
        _newResumeBytes = file.bytes;
      }
    });

    // Optionally trigger server upload here and extract data, same as Create flow.
    try {
      if (!kIsWeb && _newResumeFile != null) {
        final response = await _studentService.uploadResume(_newResumeFile!);
        if (response['extracted_data'] != null) {
          final data = response['extracted_data'];
          setState(() {
            if (data['github_url'] != null && _githubController.text.isEmpty)
              _githubController.text = data['github_url'];
            if (data['linkedin_url'] != null && _linkedinController.text.isEmpty)
              _linkedinController.text = data['linkedin_url'];
            if (data['skills'] != null && _skills.isEmpty)
              _skills = List<String>.from(data['skills']);
            if (data['technologies'] != null && _technologies.isEmpty)
              _technologies = List<String>.from(data['technologies']);
          });
        }
      }
    } catch (_) {
      setState(() => _errors['resume'] = 'Failed to upload resume');
    } finally {
      setState(() => _isUploadingResume = false);
    }
  }

  void _removeResume() {
    setState(() {
      _newResumeName  = null;
      _newResumeFile  = null;
      _newResumeBytes = null;
      _resumeRemoved  = true;
    });
  }

  // ─── Submit ─────────────────────────────────────────────────────────────────
  Future<void> _handleSave() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
      'university':       _universityController.text.trim(),
      'short_bio':        _bioController.text.trim(),
      'desired_job_role': _titleController.text.trim(),
      'linkedin_url':     _linkedinController.text.trim(),
      'github_url':       _githubController.text.trim(),
      'portfolio_url':    _portfolioController.text.trim(),
      'skills':           _skills,
      'technologies':     _technologies,
    };

    // If portfolio label changed, include it (adjust key to match your API).
    if (_portfolioLabelController.text.trim().isNotEmpty) {
      payload['portfolio_label'] = _portfolioLabelController.text.trim();
    }

    // Signal image removal to backend if needed.
    if (_profileImageRemoved) {
      payload['remove_profile_image'] = true;
    }
    // Signal resume removal to backend if needed.
    if (_resumeRemoved) {
      payload['remove_resume'] = true;
    }

    try {
      await _studentService.updateMyProfile(payload);

      // TODO: upload _newProfileImageFile / _newResumeFile via dedicated
      //       service methods if the backend requires multipart uploads.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Return `true` so ProfileScreen knows to reload.
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

  // ─────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────────
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
              _buildProfileImageSection(),
              const SizedBox(height: 28),
              _buildBasicInfoCard(),
              const SizedBox(height: 20),
              _buildSkillsCard(),
              const SizedBox(height: 20),
              _buildResumeCard(),
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

  // ─── AppBar ─────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        onPressed: () => Navigator.pop(context),
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

  // ─── Profile Image ──────────────────────────────────────────────────────────
  Widget _buildProfileImageSection() {
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
                child: ClipOval(child: _profileImageWidget()),
              ),
              // Camera overlay
              GestureDetector(
                onTap: _isUploadingImage ? null : _pickProfileImage,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, size: 17, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Remove link
          if (_hasProfileImage)
            GestureDetector(
              onTap: _removeProfileImage,
              child: const Text(
                'Remove photo',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const Text(
              'Tap camera to upload a photo',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
        ],
      ),
    );
  }

  Widget _profileImageWidget() {
    // 1) Newly picked image (bytes – works everywhere)
    if (_newProfileImageBytes != null) {
      return Image.memory(_newProfileImageBytes!, fit: BoxFit.cover);
    }
    // 2) Newly picked image (file – native only)
    if (_newProfileImageFile != null && !kIsWeb) {
      return Image.file(_newProfileImageFile!, fit: BoxFit.cover);
    }
    // 3) Existing server image (not removed)
    if (!_profileImageRemoved &&
        _existingProfileImageUrl != null &&
        _existingProfileImageUrl!.isNotEmpty) {
      return Image.network(_existingProfileImageUrl!, fit: BoxFit.cover);
    }
    // 4) Fallback – initials / placeholder
    final name = _student?.fullName ?? '';
    final initial =
        name.isNotEmpty ? name.trimRight()[0].toUpperCase() : '?';
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

  // ─── Basic info card ────────────────────────────────────────────────────────
  Widget _buildBasicInfoCard() {
    return _card(
      children: [
        _cardHeader(Icons.person_outline, 'Basic Information'),
        const SizedBox(height: 20),
        _textField(
          controller: _titleController,
          label: 'Desired Job Role *',
          hint: 'e.g., Full Stack Developer',
          error: _errors['title'],
        ),
        const SizedBox(height: 16),
        _textField(
          controller: _universityController,
          label: 'University',
          hint: 'e.g., MIT, Stanford University',
        ),
        const SizedBox(height: 16),
        _textField(
          controller: _bioController,
          label: 'Bio *',
          hint: 'Tell us about yourself, your interests, and career goals…',
          error: _errors['bio'],
          maxLines: 4,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Minimum 20 characters',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text('${_bioController.text.length}/500',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  // ─── Skills & Technologies ──────────────────────────────────────────────────
  Widget _buildSkillsCard() {
    return _card(
      children: [
        _cardHeader(Icons.person_outline, 'Skills & Technologies'),
        const SizedBox(height: 20),
        // Skills
        Text('Skills',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 10),
        _tagInput(
          controller: _newSkillController,
          tags: _skills,
          suggestions: _suggestedSkills,
          onAdd: _addSkill,
          onRemove: (s) => setState(() => _skills.remove(s)),
          onSuggestion: (s) =>
              setState(() { _skills.add(s); _newSkillController.clear(); }),
          hint: 'Add a skill…',
          error: _errors['skills'],
          tagColor: const Color(0xFF4F46E5),
          tagTextColor: Colors.white,
        ),
        const SizedBox(height: 24),
        // Technologies
        Text('Tools & Technologies',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 10),
        _tagInput(
          controller: _newTechController,
          tags: _technologies,
          suggestions: _suggestedTechs,
          onAdd: _addTech,
          onRemove: (t) => setState(() => _technologies.remove(t)),
          onSuggestion: (t) =>
              setState(() { _technologies.add(t); _newTechController.clear(); }),
          hint: 'Add a technology…',
          tagColor: Colors.grey[100]!,
          tagTextColor: Colors.grey[700]!,
          tagBorder: Colors.grey[300]!,
        ),
      ],
    );
  }

  // ─── Resume ─────────────────────────────────────────────────────────────────
  Widget _buildResumeCard() {
    return _card(
      children: [
        _cardHeader(Icons.description_outlined, 'Resume'),
        const SizedBox(height: 20),
        if (_hasResume) _resumeExisting() else _resumeUploadArea(),
      ],
    );
  }

  Widget _resumeExisting() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: Colors.red[400], size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_visibleResumeName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
                Text(_newResumeName != null ? 'New – will be uploaded' : 'Uploaded',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          // Replace
          IconButton(
            icon: Icon(Icons.swap_horiz, color: Colors.grey[600]),
            tooltip: 'Replace',
            onPressed: _pickResume,
          ),
          // Remove
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
            tooltip: 'Remove',
            onPressed: _removeResume,
          ),
        ],
      ),
    );
  }

  Widget _resumeUploadArea() {
    return GestureDetector(
      onTap: _isUploadingResume ? null : _pickResume,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 10),
              const Text('Tap to upload your resume',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 4),
              const Text('PDF only, max 5 MB',
                  style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Links ──────────────────────────────────────────────────────────────────
  Widget _buildLinksCard() {
    return _card(
      children: [
        _cardHeader(Icons.link, 'Links'),
        const SizedBox(height: 20),
        _linkField(_linkedinController, 'LinkedIn', Icons.business,
            'https://linkedin.com/in/username'),
        const SizedBox(height: 12),
        _linkField(_githubController, 'GitHub', Icons.code,
            'https://github.com/username'),
        const SizedBox(height: 12),
        _linkField(_portfolioController, 'Portfolio', Icons.web,
            'https://yourportfolio.com'),
        const SizedBox(height: 12),
        // Portfolio / custom-link label
        _textField(
          controller: _portfolioLabelController,
          label: 'Portfolio Label',
          hint: 'e.g., My Portfolio',
        ),
      ],
    );
  }

  // ─── Save button ────────────────────────────────────────────────────────────
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
                    strokeWidth: 2, color: Colors.white),
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

  // ─────────────────────────────────────────────────────────────────────────────
  // REUSABLE WIDGET HELPERS (matched to CreateProfileScreen styling)
  // ─────────────────────────────────────────────────────────────────────────────

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
        Text(title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
      ],
    );
  }

  /// Outlined TextField – mirrors CreateProfileScreen's _buildTextField.
  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? error,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: label.contains('Bio') ? 500 : null,
          buildCounter: (BuildContext _, {required int currentLength, int? maxLength, required bool isFocused}) {
  return const SizedBox.shrink(); // hide default counter
}, // hide default counter; we show our own for bio
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: _inputBorder(error != null),
            enabledBorder: _inputBorder(error != null),
            focusedBorder: _inputBorder(error != null, focused: true),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error, style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
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

  /// Tag input (skills / techs) – mirrors CreateProfileScreen's _buildTagInput.
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: suggestions.map((s) {
                return InkWell(
                  onTap: () => onSuggestion(s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Text(s, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(error, style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444))),
        ],
        const SizedBox(height: 12),
        // Tag chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.isEmpty
              ? [
                  Text('No items added yet',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[500], fontStyle: FontStyle.italic),),
                ]
              : tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(20),
                      border: tagBorder != null ? Border.all(color: tagBorder) : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tag,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: tagTextColor)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => onRemove(tag),
                          child: Icon(Icons.close, size: 15, color: tagTextColor.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
        ),
      ],
    );
  }

  /// Link row – icon + label + text field (mirrors CreateProfileScreen's _buildLinkField).
  Widget _linkField(
      TextEditingController controller, String label, IconData icon, String hint) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: _inputBorder(false),
              enabledBorder: _inputBorder(false),
              focusedBorder: _inputBorder(false, focused: true),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}