// lib/screens/campaign_screen.dart
// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';

import '../Services/AllServices.dart';
import '../models/model.dart';

class CampaignScreen extends StatefulWidget {
  final String clinicId;

  const CampaignScreen({
    super.key,
    required this.clinicId,
  });

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CampaignService _campaignService = CampaignService();
  List<CampaignModel> _campaigns = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCampaigns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCampaigns() async {
    try {
      setState(() => _isLoading = true);
      final campaigns =
          await _campaignService.getClinicCampaigns(widget.clinicId);
      setState(() {
        _campaigns = campaigns.cast<CampaignModel>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Gagal memuat kampanye: $e');
    }
  }

  List<CampaignModel> get _filteredCampaigns {
    if (_selectedFilter == 'all') return _campaigns;
    return _campaigns
        .where((campaign) => campaign.status == _selectedFilter)
        .toList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Kampanye Iklan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCampaigns,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Semua'),
            Tab(text: 'Aktif'),
            Tab(text: 'Draft'),
            Tab(text: 'Dijeda'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCampaignList('all'),
                _buildCampaignList('active'),
                _buildCampaignList('draft'),
                _buildCampaignList('paused'),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateCampaign(),
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Kampanye',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCampaignList(String status) {
    final campaigns = status == 'all'
        ? _campaigns
        : _campaigns.where((c) => c.status == status).toList();

    if (campaigns.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadCampaigns,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          return _buildCampaignCard(campaigns[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String message = 'Belum ada kampanye';
    IconData icon = Icons.campaign_outlined;

    switch (status) {
      case 'active':
        message = 'Belum ada kampanye aktif';
        icon = Icons.play_circle_outline;
        break;
      case 'draft':
        message = 'Belum ada draft kampanye';
        icon = Icons.edit_outlined;
        break;
      case 'paused':
        message = 'Belum ada kampanye yang dijeda';
        icon = Icons.pause_circle_outline;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat kampanye pertama Anda untuk memulai',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateCampaign(),
            icon: const Icon(Icons.add),
            label: const Text('Buat Kampanye'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(CampaignModel campaign) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToCampaignDetail(campaign),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      campaign.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(campaign.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Objektif: ${_getObjectiveText(campaign.objective)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Budget Harian',
                      campaign.budget.formattedDailyBudget,
                      Icons.payments_outlined,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Dibuat',
                      _formatDate(campaign.createdAt),
                      Icons.calendar_today_outlined,
                    ),
                  ),
                ],
              ),
              if (campaign.performance != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildPerformanceItem(
                        'Tayangan',
                        campaign.performance!.impressions.toString(),
                        Icons.visibility_outlined,
                      ),
                    ),
                    Expanded(
                      child: _buildPerformanceItem(
                        'Klik',
                        campaign.performance!.clicks.toString(),
                        Icons.mouse_outlined,
                      ),
                    ),
                    Expanded(
                      child: _buildPerformanceItem(
                        'CTR',
                        campaign.performance!.formattedCtr,
                        Icons.analytics_outlined,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (campaign.isDraft) ...[
                    TextButton.icon(
                      onPressed: () => _editCampaign(campaign),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (campaign.isActive) ...[
                    TextButton.icon(
                      onPressed: () => _pauseCampaign(campaign),
                      icon: const Icon(Icons.pause, size: 18),
                      label: const Text('Jeda'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (campaign.isPaused) ...[
                    TextButton.icon(
                      onPressed: () => _resumeCampaign(campaign),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Lanjut'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, campaign),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: ListTile(
                          leading: Icon(Icons.copy),
                          title: Text('Duplikat'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Hapus',
                              style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'active':
        color = Colors.green;
        text = 'Aktif';
        break;
      case 'paused':
        color = Colors.orange;
        text = 'Dijeda';
        break;
      case 'draft':
        color = Colors.grey;
        text = 'Draft';
        break;
      case 'completed':
        color = Colors.blue;
        text = 'Selesai';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
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

  String _getObjectiveText(String objective) {
    switch (objective) {
      case 'CONVERSIONS':
        return 'Konversi';
      case 'TRAFFIC':
        return 'Traffic';
      case 'AWARENESS':
        return 'Awareness';
      default:
        return objective;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Kampanye'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption('all', 'Semua Kampanye'),
            _buildFilterOption('active', 'Aktif'),
            _buildFilterOption('draft', 'Draft'),
            _buildFilterOption('paused', 'Dijeda'),
            _buildFilterOption('completed', 'Selesai'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String value, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: _selectedFilter,
      onChanged: (newValue) {
        setState(() {
          _selectedFilter = newValue!;
        });
        Navigator.pop(context);
      },
    );
  }

  Future<void> _pauseCampaign(CampaignModel campaign) async {
    try {
      await _campaignService.pauseCampaign(campaign.id);
      _showSuccessSnackBar('Kampanye berhasil dijeda');
      _loadCampaigns();
    } catch (e) {
      _showErrorSnackBar('Gagal menjeda kampanye: $e');
    }
  }

  Future<void> _resumeCampaign(CampaignModel campaign) async {
    try {
      await _campaignService.resumeCampaign(campaign.id);
      _showSuccessSnackBar('Kampanye berhasil dilanjutkan');
      _loadCampaigns();
    } catch (e) {
      _showErrorSnackBar('Gagal melanjutkan kampanye: $e');
    }
  }

  Future<void> _deleteCampaign(CampaignModel campaign) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kampanye'),
        content: Text(
            'Apakah Anda yakin ingin menghapus kampanye "${campaign.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _campaignService.deleteCampaign(campaign.id);
        _showSuccessSnackBar('Kampanye berhasil dihapus');
        _loadCampaigns();
      } catch (e) {
        _showErrorSnackBar('Gagal menghapus kampanye: $e');
      }
    }
  }

  void _handleMenuAction(String action, CampaignModel campaign) {
    switch (action) {
      case 'duplicate':
        _duplicateCampaign(campaign);
        break;
      case 'delete':
        _deleteCampaign(campaign);
        break;
    }
  }

  void _duplicateCampaign(CampaignModel campaign) {
    // Implement campaign duplication logic
    _showSuccessSnackBar('Fitur duplikasi akan segera tersedia');
  }

  void _editCampaign(CampaignModel campaign) {
    // Navigate to edit campaign screen
    Navigator.pushNamed(
      context,
      '/campaign/edit',
      arguments: campaign,
    ).then((_) => _loadCampaigns());
  }

  void _navigateToCreateCampaign() {
    Navigator.pushNamed(
      context,
      '/campaign/create',
      arguments: widget.clinicId,
    ).then((_) => _loadCampaigns());
  }

  void _navigateToCampaignDetail(CampaignModel campaign) {
    Navigator.pushNamed(
      context,
      '/campaign/detail',
      arguments: campaign,
    ).then((_) => _loadCampaigns());
  }
}
