// lib/screens/targeting_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Models/model.dart';
import '../Services/AllServices.dart';

class TargetingScreen extends StatefulWidget {
  final TargetingModel? initialTargeting;
  final String? campaignId;
  final Function(TargetingModel)? onTargetingChanged;

  const TargetingScreen({
    super.key,
    this.initialTargeting,
    this.campaignId,
    this.onTargetingChanged,
  });

  @override
  State<TargetingScreen> createState() => _TargetingScreenState();
}

class _TargetingScreenState extends State<TargetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final MetaAdsService _metaAdsService = MetaAdsService();

  // Controllers
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _radiusController = TextEditingController();
  final _ageMinController = TextEditingController();
  final _ageMaxController = TextEditingController();
  final _interestController = TextEditingController();
  final _behaviorController = TextEditingController();
  final _customAudienceController = TextEditingController();

  // State variables
  List<String> _selectedGenders = [];
  List<String> _selectedLanguages = [];
  List<String> _interests = [];
  List<String> _behaviors = [];
  List<String> _customAudiences = [];
  List<String> _interestSuggestions = [];
  Map<String, dynamic>? _audienceSize;
  bool _isLoadingAudienceSize = false;
  bool _isLoadingInterests = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.initialTargeting != null) {
      final targeting = widget.initialTargeting!;

      // Location
      _latController.text = targeting.location.lat.toString();
      _lngController.text = targeting.location.lng.toString();
      _radiusController.text = targeting.location.radius.toString();

      // Demographics
      _ageMinController.text = targeting.demographics.ageMin.toString();
      _ageMaxController.text = targeting.demographics.ageMax.toString();
      _selectedGenders = List.from(targeting.demographics.genders);
      _selectedLanguages = List.from(targeting.demographics.languages);

      // Interests and behaviors
      _interests = List.from(targeting.interests);
      _behaviors = List.from(targeting.behaviors);
      _customAudiences = List.from(targeting.customAudiences);
    } else {
      // Default values
      _radiusController.text = '5';
      _ageMinController.text = '25';
      _ageMaxController.text = '55';
      _selectedGenders = ['all'];
      _selectedLanguages = ['id'];
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    _radiusController.dispose();
    _ageMinController.dispose();
    _ageMaxController.dispose();
    _interestController.dispose();
    _behaviorController.dispose();
    _customAudienceController.dispose();
    super.dispose();
  }

  TargetingModel _buildTargetingModel() {
    return TargetingModel(
      location: LocationModel(
        lat: double.tryParse(_latController.text) ?? 0.0,
        lng: double.tryParse(_lngController.text) ?? 0.0,
        radius: int.tryParse(_radiusController.text) ?? 5,
      ),
      demographics: DemographicsModel(
        ageMin: int.tryParse(_ageMinController.text) ?? 25,
        ageMax: int.tryParse(_ageMaxController.text) ?? 55,
        genders: _selectedGenders,
        languages: _selectedLanguages,
      ),
      interests: _interests,
      behaviors: _behaviors,
      customAudiences: _customAudiences,
    );
  }

  Future<void> _getAudienceSize() async {
    if (_isLoadingAudienceSize) return;

    setState(() {
      _isLoadingAudienceSize = true;
    });

    try {
      final targeting = _buildTargetingModel();
      final audienceSize =
          await _metaAdsService.getAudienceSize(targeting.toJson());

      setState(() {
        _audienceSize = audienceSize;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get audience size: $e')),
      );
    } finally {
      setState(() {
        _isLoadingAudienceSize = false;
      });
    }
  }

  Future<void> _searchInterests(String query) async {
    if (query.trim().isEmpty || _isLoadingInterests) return;

    setState(() {
      _isLoadingInterests = true;
    });

    try {
      final suggestions = await _metaAdsService.getInterestSuggestions(query);
      setState(() {
        _interestSuggestions = suggestions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get interest suggestions: $e')),
      );
    } finally {
      setState(() {
        _isLoadingInterests = false;
      });
    }
  }

  void _addInterest(String interest) {
    if (!_interests.contains(interest)) {
      setState(() {
        _interests.add(interest);
        _interestController.clear();
        _interestSuggestions.clear();
      });
      _onTargetingChanged();
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
    _onTargetingChanged();
  }

  void _addBehavior() {
    final behavior = _behaviorController.text.trim();
    if (behavior.isNotEmpty && !_behaviors.contains(behavior)) {
      setState(() {
        _behaviors.add(behavior);
        _behaviorController.clear();
      });
      _onTargetingChanged();
    }
  }

  void _removeBehavior(String behavior) {
    setState(() {
      _behaviors.remove(behavior);
    });
    _onTargetingChanged();
  }

  void _addCustomAudience() {
    final audience = _customAudienceController.text.trim();
    if (audience.isNotEmpty && !_customAudiences.contains(audience)) {
      setState(() {
        _customAudiences.add(audience);
        _customAudienceController.clear();
      });
      _onTargetingChanged();
    }
  }

  void _removeCustomAudience(String audience) {
    setState(() {
      _customAudiences.remove(audience);
    });
    _onTargetingChanged();
  }

  void _onTargetingChanged() {
    if (widget.onTargetingChanged != null) {
      widget.onTargetingChanged!(_buildTargetingModel());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Targeting Settings'),
        actions: [
          TextButton(
            onPressed: _getAudienceSize,
            child: _isLoadingAudienceSize
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Check Audience Size'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audience Size Card
              if (_audienceSize != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimated Audience Size',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_audienceSize!['min_size']} - ${_audienceSize!['max_size']} people',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Location Section
              const Text(
                'Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latController,
                              decoration: const InputDecoration(
                                labelText: 'Latitude',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.-]')),
                              ],
                              onChanged: (_) => _onTargetingChanged(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lngController,
                              decoration: const InputDecoration(
                                labelText: 'Longitude',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.-]')),
                              ],
                              onChanged: (_) => _onTargetingChanged(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _radiusController,
                        decoration: const InputDecoration(
                          labelText: 'Radius (km)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (_) => _onTargetingChanged(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Demographics Section
              const Text(
                'Demographics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Age Range
                      const Text('Age Range'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageMinController,
                              decoration: const InputDecoration(
                                labelText: 'Min Age',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (_) => _onTargetingChanged(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _ageMaxController,
                              decoration: const InputDecoration(
                                labelText: 'Max Age',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (_) => _onTargetingChanged(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Gender
                      const Text('Gender'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['all', 'male', 'female'].map((gender) {
                          return FilterChip(
                            label: Text(gender.toUpperCase()),
                            selected: _selectedGenders.contains(gender),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedGenders.add(gender);
                                } else {
                                  _selectedGenders.remove(gender);
                                }
                              });
                              _onTargetingChanged();
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Language
                      const Text('Languages'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['id', 'en', 'ms', 'zh'].map((language) {
                          return FilterChip(
                            label: Text(language.toUpperCase()),
                            selected: _selectedLanguages.contains(language),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedLanguages.add(language);
                                } else {
                                  _selectedLanguages.remove(language);
                                }
                              });
                              _onTargetingChanged();
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Interests Section
              const Text(
                'Interests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _interestController,
                        decoration: InputDecoration(
                          labelText: 'Search Interests',
                          border: const OutlineInputBorder(),
                          suffixIcon: _isLoadingInterests
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.search),
                                  onPressed: () => _searchInterests(
                                      _interestController.text),
                                ),
                        ),
                        onChanged: (value) {
                          if (value.length > 2) {
                            _searchInterests(value);
                          }
                        },
                      ),

                      // Interest Suggestions
                      if (_interestSuggestions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _interestSuggestions.length,
                            itemBuilder: (context, index) {
                              final interest = _interestSuggestions[index];
                              return ListTile(
                                title: Text(interest),
                                onTap: () => _addInterest(interest),
                                dense: true,
                              );
                            },
                          ),
                        ),
                      ],

                      // Selected Interests
                      if (_interests.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Selected Interests:'),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _interests.map((interest) {
                            return Chip(
                              label: Text(interest),
                              onDeleted: () => _removeInterest(interest),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Behaviors Section
              const Text(
                'Behaviors',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _behaviorController,
                              decoration: const InputDecoration(
                                labelText: 'Add Behavior',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addBehavior,
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      if (_behaviors.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Selected Behaviors:'),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _behaviors.map((behavior) {
                            return Chip(
                              label: Text(behavior),
                              onDeleted: () => _removeBehavior(behavior),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Custom Audiences Section
              const Text(
                'Custom Audiences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _customAudienceController,
                              decoration: const InputDecoration(
                                labelText: 'Add Custom Audience',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addCustomAudience,
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      if (_customAudiences.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Selected Custom Audiences:'),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _customAudiences.map((audience) {
                            return Chip(
                              label: Text(audience),
                              onDeleted: () => _removeCustomAudience(audience),
                              deleteIcon: const Icon(Icons.close, size: 16),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final targeting = _buildTargetingModel();
                    Navigator.of(context).pop(targeting);
                  }
                },
                child: const Text('Save Targeting'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
