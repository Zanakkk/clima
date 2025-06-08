// lib/providers/auth_provider.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/model.dart';
import '../Services/AllServices.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _user;
  String? _error;

  AuthState get state => _state;

  User? get user => _user;

  String? get error => _error;

  bool get isAuthenticated => _user != null;

  bool get isLoading => _state == AuthState.loading;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _state =
          user != null ? AuthState.authenticated : AuthState.unauthenticated;
      notifyListeners();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _setState(AuthState.loading);
      await _authService.signInWithEmailPassword(email, password);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      _setState(AuthState.loading);
      await _authService.signUpWithEmailPassword(email, password);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _setState(AuthState.loading);
      await _authService.signInWithGoogle();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      _setState(AuthState.loading);
      await _authService.signOut();
      _clearError();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _setState(AuthState.loading);
      await _authService.resetPassword(email);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = AuthState.error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}

enum ClinicState { initial, loading, loaded, error }

class ClinicProvider extends ChangeNotifier {
  final ClinicService _clinicService = ClinicService();

  ClinicState _state = ClinicState.initial;
  List<ClinicModel> _clinics = [];
  ClinicModel? _selectedClinic;
  String? _error;
  StreamSubscription? _clinicsSubscription;

  ClinicState get state => _state;

  List<ClinicModel> get clinics => _clinics;

  ClinicModel? get selectedClinic => _selectedClinic;

  String? get error => _error;

  bool get isLoading => _state == ClinicState.loading;

  bool get hasError => _state == ClinicState.error;

  @override
  void dispose() {
    _clinicsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadUserClinics(String userId) async {
    try {
      _setState(ClinicState.loading);

      // Cancel previous subscription
      _clinicsSubscription?.cancel();

      // Start listening to real-time updates
      _clinicsSubscription = _clinicService.streamUserClinics(userId).listen(
        (clinics) {
          _clinics = clinics;
          _setState(ClinicState.loaded);
        },
        onError: (error) {
          _setError(error.toString());
        },
      );
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> createClinic(ClinicModel clinic) async {
    try {
      _setState(ClinicState.loading);
      final createdClinic = await _clinicService.createClinic(clinic);

      // Update local list
      _clinics.add(createdClinic);
      _setState(ClinicState.loaded);

      // Auto-select the newly created clinic
      selectClinic(createdClinic);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateClinic(String clinicId, ClinicModel clinic) async {
    try {
      _setState(ClinicState.loading);
      final updatedClinic = await _clinicService.updateClinic(clinicId, clinic);

      // Update local list
      final index = _clinics.indexWhere((c) => c.id == clinicId);
      if (index != -1) {
        _clinics[index] = updatedClinic;
      }

      // Update selected clinic if it's the one being updated
      if (_selectedClinic?.id == clinicId) {
        _selectedClinic = updatedClinic;
      }

      _setState(ClinicState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteClinic(String clinicId) async {
    try {
      _setState(ClinicState.loading);
      await _clinicService.deleteClinic(clinicId);

      // Remove from local list
      _clinics.removeWhere((c) => c.id == clinicId);

      // Clear selected clinic if it's the one being deleted
      if (_selectedClinic?.id == clinicId) {
        _selectedClinic = null;
      }

      _setState(ClinicState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  void selectClinic(ClinicModel clinic) {
    _selectedClinic = clinic;
    notifyListeners();
  }

  void clearSelectedClinic() {
    _selectedClinic = null;
    notifyListeners();
  }

  ClinicModel? getClinicById(String clinicId) {
    try {
      return _clinics.firstWhere((clinic) => clinic.id == clinicId);
    } catch (e) {
      return null;
    }
  }

  bool canCreateCampaign() {
    return _selectedClinic?.subscription.canCreateCampaign(
            _clinics.length // This should be actual campaign count
            ) ??
        false;
  }

  void _setState(ClinicState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = ClinicState.error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

enum CampaignState { initial, loading, loaded, error }

class CampaignProvider extends ChangeNotifier {
  final CampaignService _campaignService = CampaignService();
  final MetaAdsService _metaAdsService = MetaAdsService();

  CampaignState _state = CampaignState.initial;
  List<CampaignModel> _campaigns = [];
  CampaignModel? _selectedCampaign;
  String? _error;
  StreamSubscription? _campaignsSubscription;

  // Performance data
  final Map<String, PerformanceModel> _campaignPerformances = {};

  // Targeting helpers
  List<String> _interestSuggestions = [];
  Map<String, dynamic>? _audienceSize;
  Map<String, dynamic>? _budgetRecommendation;

  CampaignState get state => _state;

  List<CampaignModel> get campaigns => _campaigns;

  CampaignModel? get selectedCampaign => _selectedCampaign;

  String? get error => _error;

  bool get isLoading => _state == CampaignState.loading;

  bool get hasError => _state == CampaignState.error;

  Map<String, PerformanceModel> get campaignPerformances =>
      _campaignPerformances;

  List<String> get interestSuggestions => _interestSuggestions;

  Map<String, dynamic>? get audienceSize => _audienceSize;

  Map<String, dynamic>? get budgetRecommendation => _budgetRecommendation;

  // Campaign lists by status
  List<CampaignModel> get activeCampaigns =>
      _campaigns.where((c) => c.isActive).toList();

  List<CampaignModel> get draftCampaigns =>
      _campaigns.where((c) => c.isDraft).toList();

  List<CampaignModel> get pausedCampaigns =>
      _campaigns.where((c) => c.isPaused).toList();

  @override
  void dispose() {
    _campaignsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadClinicCampaigns(String clinicId) async {
    try {
      _setState(CampaignState.loading);

      // Cancel previous subscription
      _campaignsSubscription?.cancel();

      // Start listening to real-time updates
      _campaignsSubscription =
          _campaignService.streamClinicCampaigns(clinicId).listen(
        (campaigns) {
          _campaigns = campaigns;
          _setState(CampaignState.loaded);

          // Load performance data for active campaigns
          _loadCampaignPerformances();
        },
        onError: (error) {
          _setError(error.toString());
        },
      );
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> createCampaign(CampaignModel campaign) async {
    try {
      _setState(CampaignState.loading);
      final createdCampaign = await _campaignService.createCampaign(campaign);

      // Update local list
      _campaigns.insert(0, createdCampaign);
      _setState(CampaignState.loaded);

      // Auto-select the newly created campaign
      selectCampaign(createdCampaign);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateCampaign(String campaignId, CampaignModel campaign) async {
    try {
      _setState(CampaignState.loading);
      final updatedCampaign =
          await _campaignService.updateCampaign(campaignId, campaign);

      // Update local list
      final index = _campaigns.indexWhere((c) => c.id == campaignId);
      if (index != -1) {
        _campaigns[index] = updatedCampaign;
      }

      // Update selected campaign if it's the one being updated
      if (_selectedCampaign?.id == campaignId) {
        _selectedCampaign = updatedCampaign;
      }

      _setState(CampaignState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> pauseCampaign(String campaignId) async {
    try {
      await _campaignService.pauseCampaign(campaignId);

      // Update local status
      _updateCampaignStatus(campaignId, 'paused');
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> resumeCampaign(String campaignId) async {
    try {
      await _campaignService.resumeCampaign(campaignId);

      // Update local status
      _updateCampaignStatus(campaignId, 'active');
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      _setState(CampaignState.loading);
      await _campaignService.deleteCampaign(campaignId);

      // Remove from local list
      _campaigns.removeWhere((c) => c.id == campaignId);
      _campaignPerformances.remove(campaignId);

      // Clear selected campaign if it's the one being deleted
      if (_selectedCampaign?.id == campaignId) {
        _selectedCampaign = null;
      }

      _setState(CampaignState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadCampaignPerformance(
    String campaignId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final performance = await _metaAdsService.getCampaignPerformance(
        campaignId,
        startDate: startDate,
        endDate: endDate,
      );

      _campaignPerformances[campaignId] = performance;
      notifyListeners();
    } catch (e) {
      // Don't set error state for individual performance loads
      debugPrint('Failed to load performance for campaign $campaignId: $e');
    }
  }

  Future<void> _loadCampaignPerformances() async {
    for (final campaign in _campaigns.where((c) => c.isActive)) {
      await loadCampaignPerformance(campaign.id);
    }
  }

  Future<void> searchInterests(String query) async {
    try {
      _interestSuggestions =
          await _metaAdsService.getInterestSuggestions(query);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to search interests: $e');
    }
  }

  Future<void> calculateAudienceSize(Map<String, dynamic> targeting) async {
    try {
      _audienceSize = await _metaAdsService.getAudienceSize(targeting);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to calculate audience size: $e');
    }
  }

  Future<void> getBudgetRecommendation(
      String objective, Map<String, dynamic> targeting) async {
    try {
      _budgetRecommendation =
          await _metaAdsService.getBudgetRecommendation(objective, targeting);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to get budget recommendation: $e');
    }
  }

  void selectCampaign(CampaignModel campaign) {
    _selectedCampaign = campaign;
    notifyListeners();
  }

  void clearSelectedCampaign() {
    _selectedCampaign = null;
    notifyListeners();
  }

  CampaignModel? getCampaignById(String campaignId) {
    try {
      return _campaigns.firstWhere((campaign) => campaign.id == campaignId);
    } catch (e) {
      return null;
    }
  }

  PerformanceModel? getCampaignPerformance(String campaignId) {
    return _campaignPerformances[campaignId];
  }

  void _updateCampaignStatus(String campaignId, String status) {
    final index = _campaigns.indexWhere((c) => c.id == campaignId);
    if (index != -1) {
      _campaigns[index] = _campaigns[index].copyWith(status: status);

      if (_selectedCampaign?.id == campaignId) {
        _selectedCampaign = _campaigns[index];
      }

      notifyListeners();
    }
  }

  void _setState(CampaignState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = CampaignState.error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearTargetingHelpers() {
    _interestSuggestions.clear();
    _audienceSize = null;
    _budgetRecommendation = null;
    notifyListeners();
  }
}

enum AnalyticsState { initial, loading, loaded, error }

enum DateRange {
  today,
  yesterday,
  last7Days,
  last30Days,
  thisMonth,
  lastMonth,
  custom
}

class AnalyticsProvider extends ChangeNotifier {
  final MetaAdsService _metaAdsService = MetaAdsService();

  AnalyticsState _state = AnalyticsState.initial;
  String? _error;

  // Performance data
  List<PerformanceModel> _clinicPerformances = [];
  final Map<String, List<PerformanceModel>> _campaignPerformanceHistory = {};
  final Map<String, List<Map<String, dynamic>>> _creativeInsights = {};

  // Date range
  DateRange _selectedDateRange = DateRange.last7Days;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // Filters
  String? _selectedClinicId;
  final List<String> _selectedCampaignIds = [];

  AnalyticsState get state => _state;

  String? get error => _error;

  bool get isLoading => _state == AnalyticsState.loading;

  bool get hasError => _state == AnalyticsState.error;

  List<PerformanceModel> get clinicPerformances => _clinicPerformances;

  Map<String, List<PerformanceModel>> get campaignPerformanceHistory =>
      _campaignPerformanceHistory;

  Map<String, List<Map<String, dynamic>>> get creativeInsights =>
      _creativeInsights;

  DateRange get selectedDateRange => _selectedDateRange;

  DateTime? get customStartDate => _customStartDate;

  DateTime? get customEndDate => _customEndDate;

  String? get selectedClinicId => _selectedClinicId;

  List<String> get selectedCampaignIds => _selectedCampaignIds;

  // Computed properties
  DateTime get startDate {
    switch (_selectedDateRange) {
      case DateRange.today:
        return DateTime.now().subtract(const Duration(days: 0));
      case DateRange.yesterday:
        return DateTime.now().subtract(const Duration(days: 1));
      case DateRange.last7Days:
        return DateTime.now().subtract(const Duration(days: 7));
      case DateRange.last30Days:
        return DateTime.now().subtract(const Duration(days: 30));
      case DateRange.thisMonth:
        final now = DateTime.now();
        return DateTime(now.year, now.month, 1);
      case DateRange.lastMonth:
        final now = DateTime.now();
        return DateTime(now.year, now.month - 1, 1);
      case DateRange.custom:
        return _customStartDate ??
            DateTime.now().subtract(const Duration(days: 7));
    }
  }

  DateTime get endDate {
    switch (_selectedDateRange) {
      case DateRange.today:
      case DateRange.yesterday:
        return DateTime.now();
      case DateRange.last7Days:
      case DateRange.last30Days:
        return DateTime.now();
      case DateRange.thisMonth:
        return DateTime.now();
      case DateRange.lastMonth:
        final now = DateTime.now();
        return DateTime(now.year, now.month, 0); // Last day of previous month
      case DateRange.custom:
        return _customEndDate ?? DateTime.now();
    }
  }

  // Aggregated metrics
  int get totalImpressions =>
      _clinicPerformances.fold(0, (sum, p) => sum + p.impressions);

  int get totalClicks =>
      _clinicPerformances.fold(0, (sum, p) => sum + p.clicks);

  int get totalConversions =>
      _clinicPerformances.fold(0, (sum, p) => sum + p.conversions);

  double get averageCtr => _clinicPerformances.isEmpty
      ? 0.0
      : _clinicPerformances.map((p) => p.ctr).reduce((a, b) => a + b) /
          _clinicPerformances.length;

  double get averageCpc => _clinicPerformances.isEmpty
      ? 0.0
      : _clinicPerformances
              .map((p) => p.cpc.toDouble())
              .reduce((a, b) => a + b) /
          _clinicPerformances.length;

  Future<void> loadClinicPerformance(String clinicId) async {
    try {
      _setState(AnalyticsState.loading);
      _selectedClinicId = clinicId;

      _clinicPerformances = await _metaAdsService.getClinicPerformance(
        clinicId,
        startDate: startDate,
        endDate: endDate,
      );

      _setState(AnalyticsState.loaded);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadCampaignPerformanceHistory(String campaignId) async {
    try {
      // Load daily performance for the selected date range
      final performances = <PerformanceModel>[];
      final days = endDate.difference(startDate).inDays;

      for (int i = 0; i <= days; i++) {
        final date = startDate.add(Duration(days: i));
        final nextDate = date.add(const Duration(days: 1));

        try {
          final performance = await _metaAdsService.getCampaignPerformance(
            campaignId,
            startDate: date,
            endDate: nextDate,
          );
          performances.add(performance);
        } catch (e) {
          // Skip days with no data
          continue;
        }
      }

      _campaignPerformanceHistory[campaignId] = performances;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load campaign performance history: $e');
    }
  }

  Future<void> loadCreativeInsights(String campaignId) async {
    try {
      final insights = await _metaAdsService.getCreativeInsights(campaignId);
      _creativeInsights[campaignId] = insights;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load creative insights: $e');
    }
  }

  Future<void> refreshData() async {
    if (_selectedClinicId != null) {
      await loadClinicPerformance(_selectedClinicId!);
    }

    // Refresh campaign histories
    final campaignIds = List<String>.from(_campaignPerformanceHistory.keys);
    for (final campaignId in campaignIds) {
      await loadCampaignPerformanceHistory(campaignId);
    }

    // Refresh creative insights
    final creativesCampaignIds = List<String>.from(_creativeInsights.keys);
    for (final campaignId in creativesCampaignIds) {
      await loadCreativeInsights(campaignId);
    }
  }

  void setDateRange(DateRange dateRange) {
    _selectedDateRange = dateRange;
    notifyListeners();

    // Refresh data with new date range
    if (_selectedClinicId != null) {
      loadClinicPerformance(_selectedClinicId!);
    }
  }

  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    _selectedDateRange = DateRange.custom;
    _customStartDate = startDate;
    _customEndDate = endDate;
    notifyListeners();

    // Refresh data with new date range
    if (_selectedClinicId != null) {
      loadClinicPerformance(_selectedClinicId!);
    }
  }

  void addCampaignFilter(String campaignId) {
    if (!_selectedCampaignIds.contains(campaignId)) {
      _selectedCampaignIds.add(campaignId);
      notifyListeners();
    }
  }

  void removeCampaignFilter(String campaignId) {
    _selectedCampaignIds.remove(campaignId);
    notifyListeners();
  }

  void clearCampaignFilters() {
    _selectedCampaignIds.clear();
    notifyListeners();
  }

  List<PerformanceModel> getFilteredPerformances() {
    if (_selectedCampaignIds.isEmpty) {
      return _clinicPerformances;
    }

    // This would need to be implemented based on your data structure
    // For now, return all performances
    return _clinicPerformances;
  }

  String getDateRangeText() {
    switch (_selectedDateRange) {
      case DateRange.today:
        return 'Hari Ini';
      case DateRange.yesterday:
        return 'Kemarin';
      case DateRange.last7Days:
        return '7 Hari Terakhir';
      case DateRange.last30Days:
        return '30 Hari Terakhir';
      case DateRange.thisMonth:
        return 'Bulan Ini';
      case DateRange.lastMonth:
        return 'Bulan Lalu';
      case DateRange.custom:
        return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _setState(AnalyticsState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _state = AnalyticsState.error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _state = AnalyticsState.initial;
    _error = null;
    _clinicPerformances.clear();
    _campaignPerformanceHistory.clear();
    _creativeInsights.clear();
    _selectedClinicId = null;
    _selectedCampaignIds.clear();
    _selectedDateRange = DateRange.last7Days;
    _customStartDate = null;
    _customEndDate = null;
    notifyListeners();
  }
}
