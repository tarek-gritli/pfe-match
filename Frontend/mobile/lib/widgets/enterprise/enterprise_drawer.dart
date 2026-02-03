import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/config/routes.dart';
import '../../Screens/Enterprise_main_screen.dart';
import '../../Screens/Enterprise/help_support_screen.dart';
import '../../Services/enterprise_service.dart';
import '../../models/enterprise.dart';

class EnterpriseDrawer extends StatefulWidget {
  final String currentRoute;

  const EnterpriseDrawer({super.key, required this.currentRoute});

  @override
  State<EnterpriseDrawer> createState() => _EnterpriseDrawerState();
}

class _EnterpriseDrawerState extends State<EnterpriseDrawer> {
  final EnterpriseService _enterpriseService = EnterpriseService();
  Enterprise? _enterprise;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final enterprise = await _enterpriseService.getMyProfile();
      if (mounted) {
        setState(() {
          _enterprise = enterprise;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userEmail = authProvider.user?['email'] ?? '';
    final logoUrl = _enterprise?.logo != null
        ? _enterpriseService.getLogoUrl(_enterprise!.logo)
        : null;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : logoUrl != null && logoUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  logoUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.business,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _enterprise?.name ?? userEmail,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enterprise',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard,
                    title: 'Overview',
                    route: AppRoutes.enterpriseOverview,
                    currentRoute: widget.currentRoute,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      EnterpriseTabNavigator.of(context)?.onNavigateToTab(0);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.people,
                    title: 'All Applicants',
                    route: AppRoutes.enterpriseApplicants,
                    currentRoute: widget.currentRoute,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      EnterpriseTabNavigator.of(context)?.onNavigateToTab(1);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.account_circle,
                    title: 'My Profile',
                    route: AppRoutes.enterpriseProfile,
                    currentRoute: widget.currentRoute,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      EnterpriseTabNavigator.of(context)?.onNavigateToTab(2);
                    },
                  ),
                  const Divider(height: 32, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: Color(0xFF6B7280)),
                    title: const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to notifications - will be handled by the overview screen
                      EnterpriseTabNavigator.of(context)?.onNavigateToTab(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Color(0xFF6B7280)),
                    title: const Text(
                      'Help & Support',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EnterpriseHelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Logout Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFEF4444)),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context); // Close drawer
                  await authProvider.logout();

                  if (context.mounted) {
                    // Use the root navigator to ensure we exit the nested tab navigator
                    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0891B2).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF0891B2) : const Color(0xFF6B7280),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: isActive ? const Color(0xFF0891B2) : const Color(0xFF374151),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
