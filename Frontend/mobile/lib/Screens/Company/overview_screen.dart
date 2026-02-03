// filepath: /Users/fedynouri/Desktop/pfe-match/Frontend/mobile/lib/Screens/Company/overview_screen.dart

import 'package:flutter/material.dart';
import 'package:mobile/Services/pfe_service.dart';
import 'package:mobile/Services/applicant_service.dart';
import 'package:mobile/models/pfe_listing.dart';
import 'package:mobile/models/applicant.dart';
import 'pfe_form_dialog.dart';

class CompanyOverviewScreen extends StatefulWidget {
  const CompanyOverviewScreen({Key? key}) : super(key: key);

  @override
  State<CompanyOverviewScreen> createState() => _CompanyOverviewScreenState();
}

class _CompanyOverviewScreenState extends State<CompanyOverviewScreen> {
  final PFEService _pfeService = PFEService();
  final ApplicantService _applicantService = ApplicantService();

  bool _loading = true;
  List<PFEListing> _pfes = [];
  List<Applicant> _recentApplicants = [];
  int activePFEs = 0;
  int totalApplicants = 0;
  int topApplicants = 0;
  int avgMatchRate = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final pfes = await _pfeService.getPFEListings();
      final stats = await _pfeService.getStatistics();
      final applicants = await _applicantService.getAllApplicants();

      // sort recent applicants by date
      applicants.sort((a, b) {
        final da = a.applicationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.applicationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });

      setState(() {
        _pfes = pfes;
        _recentApplicants = applicants.take(5).toList();
        activePFEs = (stats['activePFEs'] as int?) ?? 0;
        totalApplicants = (stats['totalApplicants'] as int?) ?? 0;
        topApplicants = (stats['topApplicants'] as int?) ?? 0;
        avgMatchRate = (stats['avgMatchRate'] as int?) ?? 0;
      });
    } catch (e) {
      // ignore errors for now
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _openCreatePFE() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const PFEFormDialog(),
    );

    if (result != null) {
      final created = await _pfeService.createPFE(result);
      setState(() {
        _pfes.insert(0, created);
        activePFEs++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Overview'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePFE,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 16),
                      _buildStatsRow(),
                      const SizedBox(height: 16),
                      const Text('PFE Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._pfes.map((p) => _buildPFEItem(p)).toList(),
                      const SizedBox(height: 16),
                      const Text('Recent Applicants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      _buildRecentApplicants(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business, size: 36, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('TechVision AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Artificial Intelligence', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    Widget statTile(String label, String value) {
      return Expanded(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      );
    }

    return Row(
      children: [
        statTile('Active PFEs', activePFEs.toString()),
        statTile('Total Applicants', totalApplicants.toString()),
        statTile('Top Applicants', topApplicants.toString()),
        statTile('Avg Match', '$avgMatchRate%'),
      ],
    );
  }

  Widget _buildPFEItem(PFEListing p) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () {
          // navigate to applicants filtered by PFE id - placeholder
        },
        title: Text(p.title),
        subtitle: Text('${p.category} • ${p.duration}'),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(p.status, style: TextStyle(color: p.status == 'open' ? Colors.green : Colors.red)),
            const SizedBox(height: 6),
            Text('${p.applicantCount} applicants', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentApplicants() {
    if (_recentApplicants.isEmpty) {
      return const Text('No recent applicants');
    }

    return Column(
      children: _recentApplicants.map((a) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _hexToColor(a.avatarColor),
            child: Text(a.initials),
          ),
          title: Text(a.name),
          subtitle: Text(a.appliedTo),
          onTap: () {},
        );
      }).toList(),
    );
  }

  Color _hexToColor(String hex) {
    try {
      var cleaned = hex.replaceAll('#', '');
      if (cleaned.length == 6) cleaned = 'FF$cleaned';
      return Color(int.parse(cleaned, radix: 16));
    } catch (e) {
      return Colors.blueGrey;
    }
  }
}

