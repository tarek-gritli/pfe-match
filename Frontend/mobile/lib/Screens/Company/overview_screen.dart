import 'package:flutter/material.dart';
import '../../Services/pfe_service.dart';
import '../../Services/enterprise_service.dart';
import '../../models/pfe_listing.dart';
import '../../models/enterprise.dart';
import 'pfe_form_dialog.dart';

class CompanyOverviewScreen extends StatefulWidget {
  const CompanyOverviewScreen({Key? key}) : super(key: key);

  @override
  State<CompanyOverviewScreen> createState() => _CompanyOverviewScreenState();
}

class _CompanyOverviewScreenState extends State<CompanyOverviewScreen> {
  final PFEService _pfeService = PFEService();
  final EnterpriseService _enterpriseService = EnterpriseService();

  bool _loading = true;
  List<PFEListing> _pfes = [];
  Enterprise? _enterprise;
  int activePFEs = 0;
  int totalApplicants = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _pfeService.getAllPFEListings(),
        _enterpriseService.getMyProfile(),
      ]);

      final pfes = results[0] as List<PFEListing>;
      final enterprise = results[1] as Enterprise;

      setState(() {
        _pfes = pfes;
        _enterprise = enterprise;
        activePFEs = pfes.where((p) => p.status == 'open').length;
        totalApplicants = pfes.fold(0, (sum, p) => sum + (p.applicantCount ?? 0));
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

    if (result != null && mounted) {
      try {
        final created = await _pfeService.createPFEListing(result);
        if (mounted) {
          setState(() {
            _pfes.insert(0, created);
            activePFEs = _pfes.where((p) => p.status == 'open').length;
            totalApplicants = _pfes.fold(0, (sum, p) => sum + (p.applicantCount ?? 0));
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PFE created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
                      if (_pfes.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No PFE listings yet. Create one to get started!'),
                        )
                      else
                        ..._pfes.map((p) => _buildPFEItem(p)).toList(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final companyName = _enterprise?.name ?? 'Company';
    final industry = _enterprise?.industry ?? 'Not specified';
    final logoUrl = _enterprise?.logo != null
        ? _enterpriseService.getLogoUrl(_enterprise!.logo)
        : null;

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
                image: logoUrl != null && logoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(logoUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: logoUrl == null || logoUrl.isEmpty
                  ? const Icon(Icons.business, size: 36, color: Colors.black54)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    industry,
                    style: const TextStyle(color: Colors.black54),
                  ),
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
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      );
    }

    return Row(
      children: [
        statTile('Active PFEs', activePFEs.toString()),
        statTile('Total Applicants', totalApplicants.toString()),
        statTile('Total PFEs', _pfes.length.toString()),
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

}

