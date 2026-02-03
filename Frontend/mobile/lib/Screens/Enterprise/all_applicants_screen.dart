import 'package:flutter/material.dart';
import '../../Services/pfe_service.dart';
import '../../models/applicant.dart';
import '../../widgets/enterprise/enterprise_drawer.dart';
import '../../core/config/routes.dart';
import 'applicant_detail_screen.dart';

class AllApplicantsScreen extends StatefulWidget {
  const AllApplicantsScreen({Key? key}) : super(key: key);

  @override
  State<AllApplicantsScreen> createState() => _AllApplicantsScreenState();
}

class _AllApplicantsScreenState extends State<AllApplicantsScreen> {
  final PFEService _pfeService = PFEService();

  bool _loading = true;
  List<Applicant> _applicants = [];
  List<Applicant> _filteredApplicants = [];
  String? _error;
  String _selectedFilter = 'all';
  String _searchQuery = '';

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
      final applicants = await _pfeService.getAllApplicants();
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
    var filtered = _applicants;

    // Filter by status
    if (_selectedFilter != 'all') {
      filtered = filtered
          .where((a) => a.status.toLowerCase() == _selectedFilter)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((a) {
        final query = _searchQuery.toLowerCase();
        return a.name.toLowerCase().contains(query) ||
            a.university.toLowerCase().contains(query) ||
            a.appliedTo.toLowerCase().contains(query) ||
            a.email.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredApplicants = filtered;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterApplicants();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
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
      drawer: const EnterpriseDrawer(currentRoute: AppRoutes.enterpriseApplicants),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF1F2937)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'All Applicants',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, university, or position...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

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

          // Stats summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _applicants.length.toString(),
                    Icons.people,
                    const Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Filtered',
                    _filteredApplicants.length.toString(),
                    Icons.filter_list,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Avg Match',
                    _applicants.isEmpty
                        ? '0%'
                        : '${(_applicants.fold(0, (sum, a) => sum + a.matchRate) / _applicants.length).round()}%',
                    Icons.stars,
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
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
              // Applied to
              Row(
                children: [
                  const Icon(Icons.work, size: 14, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Applied to: ${applicant.appliedTo}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4B5563),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Status and date
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
            _searchQuery.isNotEmpty
                ? 'No results found'
                : 'No applicants ${_selectedFilter == 'all' ? 'yet' : 'in this category'}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search'
                : _selectedFilter == 'all'
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
