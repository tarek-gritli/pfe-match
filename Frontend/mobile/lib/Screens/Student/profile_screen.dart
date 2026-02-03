import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/Screens/pdf_viewer_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/student.dart';
import '../../Services/student_service.dart';
import '../../core/config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_navbar.dart';

class ProfileCompleteness {
  final int percentage;
  final String tip;

  ProfileCompleteness({required this.percentage, required this.tip});
}

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final StudentService _studentService = StudentService();
  Student? _student;
  bool _isLoading = true;
  String? _error;
  ProfileCompleteness _profileCompleteness = ProfileCompleteness(
    percentage: 0,
    tip: '',
  );
  

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
        _profileCompleteness = _calculateProfileCompleteness(student);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

void _openPdfViewer() {
  if (_student!.resumeName == null || _student!.resumeName!.isEmpty) return;

  final pdfUrl = StudentService().getPdfUrl(_student!.resumeName!);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PdfViewerScreen(url: pdfUrl),
    ),
  );
}

   ProfileCompleteness _calculateProfileCompleteness(Student student) {
    int completed = 0;
    int total = 0;
    List<String> tips = [];

    // Basic info (40 points)
    total += 10;
    if (student.firstName.isNotEmpty) {
      completed += 10;
    } else {
      tips.add('Add your full name');
    }

    total += 10;
    if (student.university != null && student.university!.isNotEmpty) {
      completed += 10;
    } else {
      tips.add('Add your university');
    }

    total += 10;
    if (student.title != null && student.title!.isNotEmpty) {
      completed += 10;
    } else {
      tips.add('Add a professional title');
    }

    total += 10;
    if (student.bio != null && student.bio!.isNotEmpty) {
      completed += 10;
    } else {
      tips.add('Write a bio about yourself');
    }

    // Skills and technologies (30 points)
    total += 15;
    if (student.skills.isNotEmpty) {
      completed += 15;
    } else {
      tips.add('Add your skills');
    }

    total += 15;
    if (student.technologies.isNotEmpty) {
      completed += 15;
    } else {
      tips.add('Add technologies you know');
    }

    // Links (20 points)
    total += 10;
    if (student.linkedinUrl != null && student.linkedinUrl!.isNotEmpty) {
      completed += 10;
    } else {
      tips.add('Add your LinkedIn profile');
    }

    total += 10;
    if (student.githubUrl != null && student.githubUrl!.isNotEmpty) {
      completed += 10;
    } else {
      tips.add('Add your GitHub profile');
    }

    // Resume (10 points)
    total += 10;
    if (student.resumeName != null && student.resumeName!.isNotEmpty) {
      completed += 10;
    } else {
      tips.add('Upload your resume');
    }

    final percentage = ((completed / total) * 100).round();
    final tip = tips.isNotEmpty ? tips[0] : 'Your profile is complete!';

    return ProfileCompleteness(percentage: percentage, tip: tip);
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    return name
        .split(' ')
        .where((n) => n.isNotEmpty)
        .map((n) => n[0])
        .join('')
        .toUpperCase();
  }

  Future<void> _navigateToEdit() async {
    if (_student == null) return;

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editStudentProfile,
      arguments: _student,
    );

    if (result == true) {
      _loadProfile();
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $url')));
      }
    }
  }

  void _onNotificationTap() {
    // TODO: Navigate to notifications
  }

  void _onProfileTap() {
    // Already on profile screen, could scroll to top or refresh
    _loadProfile();
  }

  Future<void> _onLogoutTap() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _student != null
        ? '${_student!.firstName} ${_student!.lastName}'.trim()
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Reusable Navbar with dropdown menu
            AppNavbar(
              userInitials: _getInitials(fullName),
              notificationCount: 3,
              userType: UserType.student,
              onNotificationTap: _onNotificationTap,
              onProfileTap: _onProfileTap,
              onLogoutTap: _onLogoutTap,
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? _buildErrorState()
                  : _buildProfileContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: const Color(0xFF4F46E5),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return _buildWideLayout();
                }
                return _buildNarrowLayout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _navigateToEdit,
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Edit Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildSkillsCard(),
              const SizedBox(height: 20),
              _buildLinksCard(),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildCompletenessCard(),
              const SizedBox(height: 20),
              _buildResumeCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildProfileCard(),
        const SizedBox(height: 20),
        _buildCompletenessCard(),
        const SizedBox(height: 20),
        _buildSkillsCard(),
        const SizedBox(height: 20),
        _buildResumeCard(),
        const SizedBox(height: 20),
        _buildLinksCard(),
      ],
    );
  }

  Widget _buildProfileCard() {
    final fullName = _student!.fullName;
    final email = _student!.email ?? '';
    final imageUrl = _student!.profileImage != null
    ? _studentService.getProfileImageUrl(_student!.profileImage)
    : null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  image:
                      imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    imageUrl == null || imageUrl.isEmpty
                    ? Center(
                        child: Text(
                          _getInitials(fullName).isNotEmpty
                              ? _getInitials(fullName)[0]
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isNotEmpty ? fullName : 'No name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                    if (_student!.title != null &&
                        _student!.title!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _student!.title!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (_student!.university != null &&
                        _student!.university!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _student!.university!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_student!.bio != null && _student!.bio!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(
              _student!.bio!,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletenessCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Completeness',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_profileCompleteness.percentage}%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _profileCompleteness.percentage / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(_profileCompleteness.percentage),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: Colors.amber[600],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _profileCompleteness.tip,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF22C55E);
    if (percentage >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Widget _buildSkillsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, size: 22, color: Colors.grey[700]),
              const SizedBox(width: 10),
              const Text(
                'Skills & Technologies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Skills',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          if (_student!.skills.isEmpty)
            Text(
              'No skills added yet',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _student!.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          const Text(
            'Tools & Technologies',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          if (_student!.technologies.isEmpty)
            Text(
              'No technologies added yet',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _student!.technologies.map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    tech,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _downloadResume() {
    if (_student?.resumeUrl != null && _student!.resumeUrl!.isNotEmpty) {
      _openLink(_student!.resumeUrl!);
    }
  }

Widget _buildResumeCard() {
    final hasResume =
        _student!.resumeName != null && _student!.resumeName!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 22,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 10),
              const Text(
                'Resume',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (hasResume) ...[
            InkWell(
              onTap: () => _openPdfViewer(),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red[400], size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _student!.resumeName!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Tap to view',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                    if (_student!.resumeUrl != null &&
                        _student!.resumeUrl!.isNotEmpty)
                      IconButton(
                        onPressed: _downloadResume,
                        icon: Icon(Icons.download, color: Colors.grey[600]),
                        tooltip: 'Download Resume',
                      ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No resume uploaded',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _navigateToEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF374151),
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Upload Resume'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ...existing code...
  Widget _buildLinksCard() {
    final hasLinks =
        (_student!.linkedinUrl != null && _student!.linkedinUrl!.isNotEmpty) ||
        (_student!.githubUrl != null && _student!.githubUrl!.isNotEmpty) ||
        (_student!.customLinkUrl != null &&
            _student!.customLinkUrl!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 22, color: Colors.grey[700]),
              const SizedBox(width: 10),
              const Text(
                'Links',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!hasLinks)
            Text(
              'No links added yet',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            )
          else ...[
            if (_student!.linkedinUrl != null &&
                _student!.linkedinUrl!.isNotEmpty)
              _buildLinkItem(
                icon: Icons.business,
                label: 'LinkedIn',
                url: _student!.linkedinUrl!,
              ),
            if (_student!.githubUrl != null && _student!.githubUrl!.isNotEmpty)
              _buildLinkItem(
                icon: Icons.code,
                label: 'GitHub',
                url: _student!.githubUrl!,
              ),
            if (_student!.customLinkUrl != null &&
                _student!.customLinkUrl!.isNotEmpty)
              _buildLinkItem(
                icon: Icons.web,
                label: _student!.customLinkLabel ?? 'Portfolio',
                url: _student!.customLinkUrl!,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkItem({
    required IconData icon,
    required String label,
    required String url,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openLink(url),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                '$label: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Expanded(
                child: Text(
                  url,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4F46E5),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.open_in_new, size: 18, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
