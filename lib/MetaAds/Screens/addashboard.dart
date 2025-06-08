// lib/screens/adsdashboard_screen.dart
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';

import '../Models/model.dart';
import '../Services/AllServices.dart';

class AdsDashboardScreen extends StatefulWidget {
  final String clinicId;

  const AdsDashboardScreen({
    super.key,
    required this.clinicId,
  });

  @override
  State<AdsDashboardScreen> createState() => _AdsDashboardScreenState();
}

class _AdsDashboardScreenState extends State<AdsDashboardScreen> {
  final CampaignService _campaignService = CampaignService();
  final ClinicService _clinicService = ClinicService();

  ClinicModel? clinic;
  List<CampaignModel> campaigns = [];
  bool isLoading = true;
  String? error;

  // Dashboard stats
  int totalCampaigns = 0;
  int activeCampaigns = 0;
  int totalImpressions = 0;
  int totalClicks = 0;
  double totalSpent = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Load clinic data
      final clinicData = await _clinicService.getClinic(widget.clinicId);
      if (clinicData == null) {
        throw Exception('Clinic not found');
      }

      // Load campaigns
      final campaignsData =
          await _campaignService.getClinicCampaigns(widget.clinicId);

      // Calculate stats
      _calculateStats(campaignsData);

      setState(() {
        clinic = clinicData;
        campaigns = campaignsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _calculateStats(List<CampaignModel> campaigns) {
    totalCampaigns = campaigns.length;
    activeCampaigns = campaigns.where((c) => c.isActive).length;

    totalImpressions = 0;
    totalClicks = 0;
    totalSpent = 0;

    for (final campaign in campaigns) {
      if (campaign.performance != null) {
        totalImpressions += campaign.performance!.impressions;
        totalClicks += campaign.performance!.clicks;
        // Estimate spent based on clicks and CPC
        totalSpent +=
            (campaign.performance!.clicks * campaign.performance!.cpc);
      }
    }
  }

  Future<void> _toggleCampaignStatus(CampaignModel campaign) async {
    try {
      if (campaign.isActive) {
        await _campaignService.pauseCampaign(campaign.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Campaign ${campaign.name} dijeda')),
        );
      } else {
        await _campaignService.resumeCampaign(campaign.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Campaign ${campaign.name} diaktifkan')),
        );
      }
      await _loadDashboardData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteCampaign(CampaignModel campaign) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Campaign'),
        content: Text('Yakin ingin menghapus campaign "${campaign.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _campaignService.deleteCampaign(campaign.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Campaign ${campaign.name} dihapus')),
        );
        await _loadDashboardData(); // Refresh data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ads Dashboard - ${clinic!.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorWidget()
              : _buildDashboardContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create campaign screen
          // Navigator.push(context, MaterialPageRoute(builder: (context) => CreateCampaignScreen()));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create Campaign - Coming Soon')),
          );
        },
        tooltip: 'Buat Campaign Baru',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildMetaIntegrationStatus(),
            const SizedBox(height: 24),
            _buildCampaignsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Campaigns',
                totalCampaigns.toString(),
                Icons.campaign,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active',
                activeCampaigns.toString(),
                Icons.play_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Impressions',
                totalImpressions.toString(),
                Icons.visibility,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Clicks',
                totalClicks.toString(),
                Icons.mouse,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'Total Spent',
          'Rp ${totalSpent.toInt().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
          Icons.attach_money,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaIntegrationStatus() {
    if (clinic == null) return const SizedBox.shrink();

    final isConnected = clinic!.metaIntegration.isConnected;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConnected ? Icons.check_circle : Icons.error,
                  color: isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Meta Ads Integration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isConnected
                  ? 'Connected - Ready to create campaigns'
                  : 'Not connected - Connect your Meta Ads account to start advertising',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            if (!isConnected) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Meta integration screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Meta Integration - Coming Soon')),
                  );
                },
                child: const Text('Connect Meta Ads'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Campaigns',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () {
                // Navigate to campaigns screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('View All Campaigns - Coming Soon')),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        campaigns.isEmpty
            ? _buildEmptyCampaigns()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: campaigns.length,
                itemBuilder: (context, index) {
                  return _buildCampaignCard(campaigns[index]);
                },
              ),
      ],
    );
  }

  Widget _buildEmptyCampaigns() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No campaigns yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first campaign to start advertising',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to create campaign
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Create Campaign - Coming Soon')),
                );
              },
              child: const Text('Create Campaign'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignCard(CampaignModel campaign) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        campaign.objective,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(campaign.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Budget: ${campaign.budget.formattedDailyBudget}/day',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  'Created: ${_formatDate(campaign.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (campaign.performance != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Impressions: ${campaign.performance!.impressions}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Clicks: ${campaign.performance!.clicks}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'CTR: ${campaign.performance!.formattedCtr}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _toggleCampaignStatus(campaign),
                  icon: Icon(
                    campaign.isActive ? Icons.pause : Icons.play_arrow,
                    size: 16,
                  ),
                  label: Text(campaign.isActive ? 'Pause' : 'Resume'),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Navigate to edit campaign
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Edit Campaign - Coming Soon')),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () => _deleteCampaign(campaign),
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'paused':
        color = Colors.orange;
        label = 'Paused';
        break;
      case 'completed':
        color = Colors.blue;
        label = 'Completed';
        break;
      case 'draft':
        color = Colors.grey;
        label = 'Draft';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
