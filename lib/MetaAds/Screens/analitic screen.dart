// lib/screens/analytics_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Models/model.dart';
import '../Services/AllServices.dart';

class AnalyticsScreen extends StatefulWidget {
  final String clinicId;

  const AnalyticsScreen({
    super.key,
    required this.clinicId,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final MetaAdsService _metaAdsService = MetaAdsService();
  final CampaignService _campaignService = CampaignService();

  List<CampaignModel> _campaigns = [];
  List<PerformanceModel> _clinicPerformance = [];
  PerformanceModel? _selectedCampaignPerformance;
  String? _selectedCampaignId;

  bool _isLoading = true;
  bool _isLoadingCampaign = false;
  String? _error;

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load campaigns
      final campaigns =
          await _campaignService.getClinicCampaigns(widget.clinicId);

      // Load clinic performance
      final clinicPerformance = await _metaAdsService.getClinicPerformance(
        widget.clinicId,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _campaigns = campaigns;
        _clinicPerformance = clinicPerformance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCampaignPerformance(String campaignId) async {
    setState(() {
      _isLoadingCampaign = true;
      _selectedCampaignId = campaignId;
    });

    try {
      final performance = await _metaAdsService.getCampaignPerformance(
        campaignId,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _selectedCampaignPerformance = performance;
        _isLoadingCampaign = false;
      });
    } catch (e) {
      setState(() {
        _selectedCampaignPerformance = null;
        _isLoadingCampaign = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading campaign performance: $e')),
      );
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
      if (_selectedCampaignId != null) {
        _loadCampaignPerformance(_selectedCampaignId!);
      }
    }
  }

  Widget _buildOverviewCard() {
    if (_clinicPerformance.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No performance data available')),
        ),
      );
    }

    // Calculate totals
    int totalImpressions = 0;
    int totalClicks = 0;
    int totalConversions = 0;
    double totalSpend = 0;

    for (final performance in _clinicPerformance) {
      totalImpressions += performance.impressions;
      totalClicks += performance.clicks;
      totalConversions += performance.conversions;
      totalSpend += performance.cpc * performance.clicks;
    }

    final avgCtr =
        totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0.0;
    final avgCpc = totalClicks > 0 ? totalSpend / totalClicks : 0.0;
    final costPerConversion =
        totalConversions > 0 ? totalSpend / totalConversions : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clinic Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Impressions',
                    NumberFormat('#,###').format(totalImpressions),
                    Icons.visibility,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Clicks',
                    NumberFormat('#,###').format(totalClicks),
                    Icons.mouse,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'CTR',
                    '${avgCtr.toStringAsFixed(2)}%',
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Avg CPC',
                    'Rp ${NumberFormat('#,###').format(avgCpc.round())}',
                    Icons.monetization_on,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Conversions',
                    NumberFormat('#,###').format(totalConversions),
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Cost/Conv',
                    'Rp ${NumberFormat('#,###').format(costPerConversion.round())}',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCampaignsList() {
    if (_campaigns.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No campaigns found')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaigns',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _campaigns.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final campaign = _campaigns[index];
                final isSelected = _selectedCampaignId == campaign.id;

                return ListTile(
                  selected: isSelected,
                  title: Text(campaign.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${campaign.statusDisplayName}'),
                      Text('Objective: ${campaign.objective}'),
                      Text(
                          'Budget: ${campaign.budget.formattedDailyBudget}/day'),
                    ],
                  ),
                  trailing: campaign.performance != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${campaign.performance!.impressions} imp',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${campaign.performance!.clicks} clicks',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              campaign.performance!.formattedCtr,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        )
                      : const Text('No data'),
                  onTap: () => _loadCampaignPerformance(campaign.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignPerformance() {
    if (_selectedCampaignId == null) return const SizedBox.shrink();

    if (_isLoadingCampaign) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_selectedCampaignPerformance == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Campaign Performance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Center(child: Text('No performance data available')),
            ],
          ),
        ),
      );
    }

    final performance = _selectedCampaignPerformance!;
    final selectedCampaign = _campaigns.firstWhere(
      (c) => c.id == _selectedCampaignId,
      orElse: () => _campaigns.first,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign: ${selectedCampaign.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Impressions',
                    NumberFormat('#,###').format(performance.impressions),
                    Icons.visibility,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Clicks',
                    NumberFormat('#,###').format(performance.clicks),
                    Icons.mouse,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'CTR',
                    performance.formattedCtr,
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'CPC',
                    performance.formattedCpc,
                    Icons.monetization_on,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Conversions',
                    NumberFormat('#,###').format(performance.conversions),
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Cost/Conv',
                    performance.formattedCostPerConversion,
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Date Range Display
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Period: ${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: _selectDateRange,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Overview Card
                        _buildOverviewCard(),
                        const SizedBox(height: 16),

                        // Campaigns List
                        _buildCampaignsList(),
                        const SizedBox(height: 16),

                        // Campaign Performance
                        _buildCampaignPerformance(),
                      ],
                    ),
                  ),
                ),
    );
  }
}
