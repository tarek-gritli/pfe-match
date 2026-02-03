import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/enterprise.dart';
import '../../Services/enterprise_service.dart';
import '../../core/config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_navbar.dart';

class EnterpriseProfileScreen extends StatefulWidget {
  const EnterpriseProfileScreen({super.key});

  @override
  State<EnterpriseProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<EnterpriseProfileScreen> {
  final EnterpriseService _enterpriseService = EnterpriseService();
  Enterprise? _enterprise;
  bool _isLoading = true;
  String? _error;
  List<dynamic> _enterprisePfes = [];
  int _openPfesCount = 0;

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
      final enterprise = await _enterpriseService.getMyProfile();
      //final pfes = await _enterpriseService.getMyPfes();
      final pfes = []; // TODO
      setState(() {
        _enterprise = enterprise;
        _enterprisePfes = pfes;
        _openPfesCount = pfes.where((pfe) => pfe.isOpen == true).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'C';
    return name
        .split(' ')
        .where((n) => n.isNotEmpty)
        .map((n) => n[0])
        .join('')
        .toUpperCase();
  }

  Future<void> _navigateToEdit() async {
    if (_enterprise == null) return;

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.editEnterpriseProfile,
      arguments: _enterprise,
    );

    if (result == true) {
      _loadProfile();
    }
  }

  void _navigateToManagePfes() {
    //Navigator.pushNamed(context, AppRoutes.managePfes);
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

  Future<void> _openMailto(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open mailto: $email')));
      }
    }
  }

  void _onNotificationTap() {
    // TODO: Navigate to notifications
  }

  void _onProfileTap() {
    _loadProfile();
  }

  Future<void> _onLogoutTap() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (mounted) {
      // Use the root navigator to ensure we exit the nested tab navigator
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            AppNavbar(
              userInitials: _getInitials(_enterprise?.name ?? ''),
              notificationCount: 3,
              userType: UserType.enterprise,
              onNotificationTap: _onNotificationTap,
              onProfileTap: _onProfileTap,
              onLogoutTap: _onLogoutTap,
            ),
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

  // ---------------------------------------------------------------------------
  // Error state
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Scrollable body
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Page header
  // ---------------------------------------------------------------------------
  Widget _buildPageHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Company Profile',
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

  // ---------------------------------------------------------------------------
  // Responsive layouts
  // ---------------------------------------------------------------------------
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
              _buildTechnologiesCard(),
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
              _buildPfeListingsCard(),
              const SizedBox(height: 20),
              _buildCompanyDetailsCard(),
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
        _buildPfeListingsCard(),
        const SizedBox(height: 20),
        _buildTechnologiesCard(),
        const SizedBox(height: 20),
        _buildCompanyDetailsCard(),
        const SizedBox(height: 20),
        _buildLinksCard(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Profile card  (mirrors StudentProfileScreen._buildProfileCard)
  // ---------------------------------------------------------------------------
  Widget _buildProfileCard() {
    final name = _enterprise!.name;
    final imageUrl = _enterprise!.logo != null
        ? _enterpriseService.getLogoUrl(_enterprise!.logo)
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
              // Avatar
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
                  image: imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null || imageUrl.isEmpty
                    ? Center(
                        child: Text(
                          _getInitials(name).isNotEmpty
                              ? _getInitials(name)[0]
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
              // Info block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'No name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    // Industry badge
                    if (_enterprise!.industry != null &&
                        _enterprise!.industry!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Text(
                          _enterprise!.industry!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                    // Location
                    if (_enterprise!.location != null &&
                        _enterprise!.location!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _enterprise!.location!,
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
                    // Company size
                    if (_enterprise!.size != null &&
                        _enterprise!.size!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outlined,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _enterprise!.size!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Founded year
                    if (_enterprise!.foundedYear != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Founded ${_enterprise!.foundedYear}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
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
          // Description / bio
          if (_enterprise!.description != null &&
              _enterprise!.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(
              _enterprise!.description!,
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

  // ---------------------------------------------------------------------------
  // Technologies card  (replaces Skills card)
  // ---------------------------------------------------------------------------
  Widget _buildTechnologiesCard() {
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
              Icon(Icons.code_outlined, size: 22, color: Colors.grey[700]),
              const SizedBox(width: 10),
              const Text(
                'Technologies & Stack',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_enterprise!.technologies.isEmpty)
            Text(
              'No technologies listed',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _enterprise!.technologies.map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tech,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PFE Listings card  (replaces Completeness card – right column top)
  // ---------------------------------------------------------------------------
  Widget _buildPfeListingsCard() {
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
              Icon(Icons.description_outlined, size: 22, color: Colors.grey[700]),
              const SizedBox(width: 10),
              const Text(
                'PFE Listings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: _openPfesCount.toString(),
                  label: 'Open',
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  value: _enterprisePfes.length.toString(),
                  label: 'Total',
                  isPrimary: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Manage PFEs button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _navigateToManagePfes,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Manage PFEs'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isPrimary ? const Color(0xFF4F46E5) : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Company Details card  (replaces Resume card – right column bottom)
  // ---------------------------------------------------------------------------
  Widget _buildCompanyDetailsCard() {
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
            'Company Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          if (_enterprise!.industry != null && _enterprise!.industry!.isNotEmpty)
            _buildDetailRow('Industry', _enterprise!.industry!),
          if (_enterprise!.size != null && _enterprise!.size!.isNotEmpty)
            _buildDetailRow('Size', _enterprise!.size!),
          if (_enterprise!.location != null && _enterprise!.location!.isNotEmpty)
            _buildDetailRow('Location', _enterprise!.location!),
          if (_enterprise!.foundedYear != null)
            _buildDetailRow('Founded', _enterprise!.foundedYear.toString()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Links & Contact card  (replaces Links card)
  // ---------------------------------------------------------------------------
  Widget _buildLinksCard() {
    final hasWebsite =
        _enterprise!.website != null && _enterprise!.website!.isNotEmpty;
    final hasLinkedin =
        _enterprise!.linkedinUrl != null && _enterprise!.linkedinUrl!.isNotEmpty;
    final hasEmail =
        _enterprise!.contactEmail != null && _enterprise!.contactEmail!.isNotEmpty;
    final hasLinks = hasWebsite || hasLinkedin || hasEmail;

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
                'Links & Contact',
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
            if (hasWebsite)
              _buildLinkItem(
                icon: Icons.web,
                label: 'Company Website',
                url: _enterprise!.website!,
                onTap: () => _openLink(_enterprise!.website!),
              ),
            if (hasLinkedin)
              _buildLinkItem(
                icon: Icons.business,
                label: 'LinkedIn Page',
                url: _enterprise!.linkedinUrl!,
                onTap: () => _openLink(_enterprise!.linkedinUrl!),
              ),
            if (hasEmail)
              _buildLinkItem(
                icon: Icons.email_outlined,
                label: 'Contact Email',
                url: _enterprise!.contactEmail!,
                onTap: () => _openMailto(_enterprise!.contactEmail!),
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
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
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