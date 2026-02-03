import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/applicant.dart';
import '../../Services/pfe_service.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final Applicant applicant;

  const ApplicantDetailScreen({
    Key? key,
    required this.applicant,
  }) : super(key: key);

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  final PFEService _pfeService = PFEService();
  late Applicant _applicant;
  bool _loading = false;
  bool _statusUpdating = false;

  @override
  void initState() {
    super.initState();
    _applicant = widget.applicant;
    _loadDetailedInfo();
  }

  Future<void> _loadDetailedInfo() async {
    setState(() => _loading = true);
    try {
      final detailed = await _pfeService.getApplicantDetail(_applicant.id);
      if (mounted) {
        setState(() {
          _applicant = detailed;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _statusUpdating = true);

    try {
      final updated = await _pfeService.updateApplicationStatus(_applicant.id, newStatus);
      if (mounted) {
        setState(() {
          _applicant = updated;
          _statusUpdating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${updated.statusLabel}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showStatusDialog() {
    final statuses = ['pending', 'reviewed', 'shortlisted', 'interview', 'accepted', 'rejected'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Application Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              final isCurrentStatus = status == _applicant.status.toLowerCase();
              return RadioListTile<String>(
                title: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(
                    fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                value: status,
                groupValue: _applicant.status.toLowerCase(),
                onChanged: (value) {
                  if (value != null && value != _applicant.status.toLowerCase()) {
                    Navigator.pop(context);
                    _updateStatus(value);
                  }
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open URL')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'shortlisted':
        return Colors.blue;
      case 'interview':
        return Colors.orange;
      case 'reviewed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getMatchColor(int matchRate) {
    if (matchRate >= 70) return Colors.green;
    if (matchRate >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Applicant Details',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_applicant.resumeUrl != null)
            IconButton(
              icon: const Icon(Icons.description, color: Color(0xFF4F46E5)),
              onPressed: () => _launchUrl(_applicant.resumeUrl!),
              tooltip: 'View Resume',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Color(int.parse(_applicant.avatarColor.replaceFirst('#', '0xFF'))),
                          backgroundImage: _applicant.profilePicture != null
                              ? NetworkImage(_applicant.profilePicture!)
                              : null,
                          child: _applicant.profilePicture == null
                              ? Text(
                                  _applicant.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          _applicant.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // University
                        Text(
                          _applicant.university,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        if (_applicant.fieldOfStudy.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _applicant.fieldOfStudy,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Match Score
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: _getMatchColor(_applicant.matchRate).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars,
                                color: _getMatchColor(_applicant.matchRate),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_applicant.matchRate}% Match',
                                style: TextStyle(
                                  color: _getMatchColor(_applicant.matchRate),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Status and Action Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(_applicant.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _applicant.statusLabel,
                                style: TextStyle(
                                  color: _getStatusColor(_applicant.status),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _statusUpdating ? null : _showStatusDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                foregroundColor: Colors.white,
                              ),
                              child: _statusUpdating
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Change Status'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Information
                  _buildSection(
                    'Contact Information',
                    Icons.contact_mail,
                    [
                      _buildInfoRow(Icons.email, 'Email', _applicant.email),
                      if (_applicant.linkedinUrl != null && _applicant.linkedinUrl!.isNotEmpty)
                        _buildLinkRow(Icons.work, 'LinkedIn', _applicant.linkedinUrl!),
                      if (_applicant.githubUrl != null && _applicant.githubUrl!.isNotEmpty)
                        _buildLinkRow(Icons.code, 'GitHub', _applicant.githubUrl!),
                      if (_applicant.portfolioUrl != null && _applicant.portfolioUrl!.isNotEmpty)
                        _buildLinkRow(Icons.web, 'Portfolio', _applicant.portfolioUrl!),
                    ],
                  ),

                  // Bio
                  if (_applicant.bio != null && _applicant.bio!.isNotEmpty)
                    _buildSection(
                      'About',
                      Icons.person,
                      [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            _applicant.bio!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B5563),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Skills
                  if (_applicant.skills.isNotEmpty)
                    _buildSection(
                      'Skills',
                      Icons.star,
                      [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _applicant.skills.map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  skill,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4F46E5),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),

                  // Technologies
                  if (_applicant.technologies != null && _applicant.technologies!.isNotEmpty)
                    _buildSection(
                      'Technologies',
                      Icons.build,
                      [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _applicant.technologies!.map((tech) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Text(
                                  tech,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),

                  // Application Details
                  _buildSection(
                    'Application Details',
                    Icons.info,
                    [
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Applied',
                        _formatDate(_applicant.applicationDate),
                      ),
                      _buildInfoRow(
                        Icons.business,
                        'Position',
                        _applicant.appliedTo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: const Color(0xFF4F46E5)),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow(IconData icon, String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _launchUrl(url),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            Expanded(
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4F46E5),
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.open_in_new, size: 16, color: Color(0xFF4F46E5)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
