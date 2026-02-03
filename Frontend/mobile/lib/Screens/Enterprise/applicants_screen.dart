import 'package:flutter/material.dart';
import '../../Services/pfe_service.dart';
import '../../models/applicant.dart';
import 'applicant_detail_screen.dart';

class ApplicantsScreen extends StatefulWidget {
  final int pfeId;
  final String pfeTitle;

  const ApplicantsScreen({
    Key? key,
    required this.pfeId,
    required this.pfeTitle,
  }) : super(key: key);

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  final PFEService _pfeService = PFEService();

  bool _loading = true;
  List<Applicant> _applicants = [];
  List<Applicant> _filteredApplicants = [];
  String? _error;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final applicants = await _pfeService.getApplicantsForPFE(widget.pfeId);
      if (mounted) {
        setState(() {
          _applicants = applicants;
          _filterApplicants();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  void _filterApplicants() {
    if (_selectedFilter == 'all') {
      _filteredApplicants = _applicants;
    } else {
      _filteredApplicants = _applicants
          .where((a) => a.status.toLowerCase() == _selectedFilter)
          .toList();
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterApplicants();
    });
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

  void _navigateToDetail(Applicant applicant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplicantDetailScreen(applicant: applicant),
      ),
    );

    // Reload if status was updated
    if (result == true) {
      _loadApplicants();
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Applicants',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.pfeTitle,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all', _applicants.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Pending',
                    'pending',
                    _applicants.where((a) => a.status.toLowerCase() == 'pending').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Shortlisted',
                    'shortlisted',
                    _applicants.where((a) => a.status.toLowerCase() == 'shortlisted').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Interview',
                    'interview',
                    _applicants.where((a) => a.status.toLowerCase() == 'interview').length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Accepted',
                    'accepted',
                    _applicants.where((a) => a.status.toLowerCase() == 'accepted').length,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _filteredApplicants.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadApplicants,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredApplicants.length,
                              itemBuilder: (context, index) {
                                return _buildApplicantCard(_filteredApplicants[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (_) => _onFilterChanged(value),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF4F46E5).withOpacity(0.1),
      checkmarkColor: const Color(0xFF4F46E5),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE5E7EB),
      ),
    );
  }

  Widget _buildApplicantCard(Applicant applicant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(applicant),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(int.parse(applicant.avatarColor.replaceFirst('#', '0xFF'))),
                    child: Text(
                      applicant.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and university
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          applicant.university,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Match score badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMatchColor(applicant.matchRate).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${applicant.matchRate}%',
                      style: TextStyle(
                        color: _getMatchColor(applicant.matchRate),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(applicant.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      applicant.statusLabel,
                      style: TextStyle(
                        color: _getStatusColor(applicant.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Applied ${_formatDate(applicant.applicationDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              // Skills preview
              if (applicant.skills.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: applicant.skills.take(4).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No applicants ${_selectedFilter == 'all' ? 'yet' : 'in this category'}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'Applications will appear here once students apply'
                : 'Try selecting a different filter',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
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
              'Failed to load applicants',
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
              onPressed: _loadApplicants,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
