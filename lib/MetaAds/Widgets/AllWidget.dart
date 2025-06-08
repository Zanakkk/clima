// lib/widgets/campaign_card.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../Models/model.dart';

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onPause;
  final VoidCallback? onDelete;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
    this.onEdit,
    this.onPause,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _buildStatusChip(),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'pause',
                        child: Row(
                          children: [
                            Icon(campaign.isActive
                                ? Icons.pause
                                : Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(campaign.isActive ? 'Pause' : 'Resume'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'pause':
                          onPause?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Objective: ${campaign.objective}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    'Budget Harian',
                    campaign.budget.formattedDailyBudget,
                    Icons.money,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    'Total Budget',
                    campaign.budget.formattedTotalBudget,
                    Icons.account_balance_wallet,
                  ),
                ],
              ),
              if (campaign.performance != null) ...[
                const Divider(height: 24),
                _buildPerformanceRow(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    switch (campaign.status) {
      case 'active':
        color = Colors.green;
        break;
      case 'paused':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        campaign.statusDisplayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow() {
    final perf = campaign.performance!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildPerformanceItem('Impressions', perf.impressions.toString()),
        _buildPerformanceItem('Clicks', perf.clicks.toString()),
        _buildPerformanceItem('CTR', perf.formattedCtr),
        _buildPerformanceItem('Conversions', perf.conversions.toString()),
      ],
    );
  }

  Widget _buildPerformanceItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class TargetingBuilder extends StatefulWidget {
  final TargetingModel? initialTargeting;
  final Function(TargetingModel) onTargetingChanged;

  const TargetingBuilder({
    super.key,
    this.initialTargeting,
    required this.onTargetingChanged,
  });

  @override
  State<TargetingBuilder> createState() => _TargetingBuilderState();
}

class _TargetingBuilderState extends State<TargetingBuilder> {
  late TargetingModel _targeting;
  final _radiusController = TextEditingController();
  final _interestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _targeting = widget.initialTargeting ??
        TargetingModel(
          location: LocationModel(lat: -6.2088, lng: 106.8456, radius: 10),
          demographics: DemographicsModel(
            ageMin: 25,
            ageMax: 55,
            genders: ['all'],
            languages: ['id'],
          ),
          interests: [],
          behaviors: [],
          customAudiences: [],
        );
    _radiusController.text = _targeting.location.radius.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Targeting Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildDemographicsSection(),
            const SizedBox(height: 16),
            _buildInterestsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _radiusController,
          decoration: const InputDecoration(
            labelText: 'Radius (km)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final radius = int.tryParse(value) ?? 10;
            _updateTargeting(_targeting.copyWith(
              location: _targeting.location.copyWith(radius: radius),
            ));
          },
        ),
      ],
    );
  }

  Widget _buildDemographicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demographics',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Min Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _targeting.demographics.ageMin.toString(),
                ),
                onChanged: (value) {
                  final ageMin = int.tryParse(value) ?? 18;
                  _updateTargeting(_targeting.copyWith(
                    demographics:
                        _targeting.demographics.copyWith(ageMin: ageMin),
                  ));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Max Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                controller: TextEditingController(
                  text: _targeting.demographics.ageMax.toString(),
                ),
                onChanged: (value) {
                  final ageMax = int.tryParse(value) ?? 65;
                  _updateTargeting(_targeting.copyWith(
                    demographics:
                        _targeting.demographics.copyWith(ageMax: ageMax),
                  ));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: ['all', 'male', 'female'].map((gender) {
            final isSelected = _targeting.demographics.genders.contains(gender);
            return FilterChip(
              label: Text(_getGenderLabel(gender)),
              selected: isSelected,
              onSelected: (selected) {
                List<String> newGenders =
                    List.from(_targeting.demographics.genders);
                if (selected) {
                  if (gender == 'all') {
                    newGenders = ['all'];
                  } else {
                    newGenders.remove('all');
                    newGenders.add(gender);
                  }
                } else {
                  newGenders.remove(gender);
                  if (newGenders.isEmpty) {
                    newGenders = ['all'];
                  }
                }
                _updateTargeting(_targeting.copyWith(
                  demographics:
                      _targeting.demographics.copyWith(genders: newGenders),
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _interestsController,
          decoration: InputDecoration(
            labelText: 'Add Interest',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addInterest,
            ),
          ),
          onSubmitted: (_) => _addInterest(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _targeting.interests.map((interest) {
            return Chip(
              label: Text(interest),
              onDeleted: () => _removeInterest(interest),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getGenderLabel(String gender) {
    switch (gender) {
      case 'all':
        return 'Semua';
      case 'male':
        return 'Pria';
      case 'female':
        return 'Wanita';
      default:
        return gender;
    }
  }

  void _addInterest() {
    final interest = _interestsController.text.trim();
    if (interest.isNotEmpty && !_targeting.interests.contains(interest)) {
      final newInterests = List<String>.from(_targeting.interests)
        ..add(interest);
      _updateTargeting(_targeting.copyWith(interests: newInterests));
      _interestsController.clear();
    }
  }

  void _removeInterest(String interest) {
    final newInterests = List<String>.from(_targeting.interests)
      ..remove(interest);
    _updateTargeting(_targeting.copyWith(interests: newInterests));
  }

  void _updateTargeting(TargetingModel newTargeting) {
    setState(() {
      _targeting = newTargeting;
    });
    widget.onTargetingChanged(newTargeting);
  }
}

class AdPreview extends StatelessWidget {
  final AdCreativeModel adCreative;
  final bool showEditButton;
  final VoidCallback? onEdit;

  const AdPreview({
    super.key,
    required this.adCreative,
    this.showEditButton = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showEditButton)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ad Preview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.blue,
                        child: Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Clinic Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Sponsored',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Ad Image
                if (adCreative.imageUrl.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[200],
                    child: adCreative.imageUrl.startsWith('http')
                        ? Image.network(
                            adCreative.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          )
                        : _buildPlaceholderImage(),
                  )
                else
                  _buildPlaceholderImage(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline
                      if (adCreative.headline.isNotEmpty)
                        Text(
                          adCreative.headline,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Description
                      if (adCreative.description.isNotEmpty)
                        Text(
                          adCreative.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),

                      const SizedBox(height: 12),

                      // CTA Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(adCreative.ctaText),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Image Preview',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsChart extends StatelessWidget {
  final List<PerformanceModel> performanceData;
  final String title;
  final String metric;

  const AnalyticsChart({
    super.key,
    required this.performanceData,
    required this.title,
    this.metric = 'impressions',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child:
                  performanceData.isEmpty ? _buildEmptyState() : _buildChart(),
            ),
            const SizedBox(height: 16),
            _buildMetricsRow(),
          ],
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
            Icons.analytics_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No data available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    // Simple bar chart representation
    final maxValue = _getMaxValue();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: performanceData.map((data) {
        final value = _getMetricValue(data);
        final height = maxValue > 0 ? (value / maxValue) * 160 : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMetricsRow() {
    if (performanceData.isEmpty) return const SizedBox.shrink();

    final totalData = performanceData.first; // For demo, using first item

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetricItem('Impressions', totalData.impressions.toString()),
        _buildMetricItem('Clicks', totalData.clicks.toString()),
        _buildMetricItem('CTR', totalData.formattedCtr),
        _buildMetricItem('CPC', totalData.formattedCpc),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  double _getMaxValue() {
    if (performanceData.isEmpty) return 0;

    switch (metric) {
      case 'clicks':
        return performanceData
            .map((e) => e.clicks.toDouble())
            .reduce((a, b) => a > b ? a : b);
      case 'conversions':
        return performanceData
            .map((e) => e.conversions.toDouble())
            .reduce((a, b) => a > b ? a : b);
      default:
        return performanceData
            .map((e) => e.impressions.toDouble())
            .reduce((a, b) => a > b ? a : b);
    }
  }

  double _getMetricValue(PerformanceModel data) {
    switch (metric) {
      case 'clicks':
        return data.clicks.toDouble();
      case 'conversions':
        return data.conversions.toDouble();
      default:
        return data.impressions.toDouble();
    }
  }
}

class SpecialtySelector extends StatefulWidget {
  final List<String> selectedSpecialties;
  final Function(List<String>) onSelectionChanged;

  const SpecialtySelector({
    super.key,
    required this.selectedSpecialties,
    required this.onSelectionChanged,
  });

  @override
  State<SpecialtySelector> createState() => _SpecialtySelectorState();
}

class _SpecialtySelectorState extends State<SpecialtySelector> {
  final List<String> _availableSpecialties = [
    'Umum',
    'Gigi',
    'Mata',
    'Kulit',
    'Jantung',
    'Anak',
    'Kandungan',
    'Orthopedi',
    'Saraf',
    'Paru',
    'Dalam',
    'Bedah',
    'THT',
    'Psikiatri',
    'Radiologi',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Spesialisasi Klinik',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSpecialties.map((specialty) {
                final isSelected =
                    widget.selectedSpecialties.contains(specialty);
                return FilterChip(
                  label: Text(specialty),
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> newSpecialties =
                        List.from(widget.selectedSpecialties);
                    if (selected) {
                      newSpecialties.add(specialty);
                    } else {
                      newSpecialties.remove(specialty);
                    }
                    widget.onSelectionChanged(newSpecialties);
                  },
                  selectedColor: Colors.blue.withOpacity(0.2),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceTemplateCard extends StatelessWidget {
  final AdTemplateModel template;
  final VoidCallback? onTap;
  final bool isSelected;

  const ServiceTemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border:
                isSelected ? Border.all(color: Colors.blue, width: 2) : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        template.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    template.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  template.template.getRandomDescription(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          template.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${template.usageCount} used',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
