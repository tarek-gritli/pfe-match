import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/enterprise/enterprise_drawer.dart';
import '../../core/config/routes.dart';

class EnterpriseHelpSupportScreen extends StatelessWidget {
  const EnterpriseHelpSupportScreen({Key? key}) : super(key: key);

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@pfematch.com',
      query: 'subject=Enterprise Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const EnterpriseDrawer(currentRoute: AppRoutes.enterpriseHelpSupport),
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
          'Help & Support',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.support_agent,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enterprise Support',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We\'re here to help you find the best talent',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contact Us Section
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            _buildContactCard(
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@pfematch.com',
              color: const Color(0xFF0891B2),
              onTap: _launchEmail,
            ),
            const SizedBox(height: 12),

            _buildContactCard(
              icon: Icons.phone,
              title: 'Enterprise Hotline',
              subtitle: '+216 XX XXX XXX',
              color: const Color(0xFF10B981),
              onTap: () {},
            ),
            const SizedBox(height: 12),

            _buildContactCard(
              icon: Icons.business_center,
              title: 'Account Manager',
              subtitle: 'Dedicated support for your organization',
              color: const Color(0xFF7C3AED),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account manager contact coming soon!')),
                );
              },
            ),

            const SizedBox(height: 24),

            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            _buildFAQItem(
              question: 'How do I create a PFE listing?',
              answer: 'Click the "+" button on the Overview screen to create a new PFE listing. Fill in the required details including title, description, requirements, and duration.',
            ),
            _buildFAQItem(
              question: 'How can I review applicants?',
              answer: 'Navigate to the Applicants tab to see all students who applied across all your PFE listings. You can filter by status, search by name, and view detailed profiles.',
            ),
            _buildFAQItem(
              question: 'What is the match score?',
              answer: 'The match score indicates how well a student\'s profile aligns with your PFE requirements. Scores of 70%+ indicate excellent matches.',
            ),
            _buildFAQItem(
              question: 'How do I manage application statuses?',
              answer: 'Click on any applicant to view their detailed profile. From there, you can update their status (Pending, Reviewed, Shortlisted, Interview, Accepted, or Rejected).',
            ),
            _buildFAQItem(
              question: 'Can I edit or close a PFE listing?',
              answer: 'Yes, you can edit PFE listings at any time and change their status to "closed" when you\'ve found the right candidate.',
            ),

            const SizedBox(height: 24),

            // Resources Section
            const Text(
              'Enterprise Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),

            _buildQuickLinkCard(
              icon: Icons.school,
              title: 'Best Practices Guide',
              subtitle: 'Tips for writing effective PFE listings',
              onTap: () => _launchUrl('https://pfematch.com/enterprise/guide'),
            ),
            const SizedBox(height: 8),

            _buildQuickLinkCard(
              icon: Icons.analytics,
              title: 'Analytics Dashboard',
              subtitle: 'Track your recruitment performance',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Analytics coming soon!')),
                );
              },
            ),
            const SizedBox(height: 8),

            _buildQuickLinkCard(
              icon: Icons.article,
              title: 'Documentation',
              subtitle: 'Complete platform documentation',
              onTap: () => _launchUrl('https://pfematch.com/docs'),
            ),
            const SizedBox(height: 8),

            _buildQuickLinkCard(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
              onTap: () => _launchUrl('https://pfematch.com/privacy'),
            ),

            const SizedBox(height: 32),

            // App Version
            Center(
              child: Column(
                children: [
                  Text(
                    'PFE Match Enterprise',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinkCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF0891B2), size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}
