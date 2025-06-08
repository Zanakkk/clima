// lib/data/models/location_model.dart
class LocationModel {
  final double lat;
  final double lng;
  final int radius; // km

  LocationModel({
    required this.lat,
    required this.lng,
    required this.radius,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      radius: json['radius'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'radius': radius,
    };
  }

  LocationModel copyWith({
    double? lat,
    double? lng,
    int? radius,
  }) {
    return LocationModel(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radius: radius ?? this.radius,
    );
  }

  @override
  String toString() => 'LocationModel(lat: $lat, lng: $lng, radius: $radius)';
}

// lib/data/models/meta_integration_model.dart
class MetaIntegrationModel {
  final String adAccountId;
  final String pixelId;
  final String pageId;
  final String accessToken; // Encrypted
  final String status; // connected/disconnected

  MetaIntegrationModel({
    required this.adAccountId,
    required this.pixelId,
    required this.pageId,
    required this.accessToken,
    required this.status,
  });

  factory MetaIntegrationModel.fromJson(Map<String, dynamic> json) {
    return MetaIntegrationModel(
      adAccountId: json['ad_account_id'] ?? '',
      pixelId: json['pixel_id'] ?? '',
      pageId: json['page_id'] ?? '',
      accessToken: json['access_token'] ?? '',
      status: json['status'] ?? 'disconnected',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ad_account_id': adAccountId,
      'pixel_id': pixelId,
      'page_id': pageId,
      'access_token': accessToken,
      'status': status,
    };
  }

  bool get isConnected => status == 'connected';

  MetaIntegrationModel copyWith({
    String? adAccountId,
    String? pixelId,
    String? pageId,
    String? accessToken,
    String? status,
  }) {
    return MetaIntegrationModel(
      adAccountId: adAccountId ?? this.adAccountId,
      pixelId: pixelId ?? this.pixelId,
      pageId: pageId ?? this.pageId,
      accessToken: accessToken ?? this.accessToken,
      status: status ?? this.status,
    );
  }
}

// lib/data/models/demographics_model.dart
class DemographicsModel {
  final int ageMin;
  final int ageMax;
  final List<String> genders; // all, male, female
  final List<String> languages;

  DemographicsModel({
    required this.ageMin,
    required this.ageMax,
    required this.genders,
    required this.languages,
  });

  factory DemographicsModel.fromJson(Map<String, dynamic> json) {
    return DemographicsModel(
      ageMin: json['age_min'] ?? 25,
      ageMax: json['age_max'] ?? 55,
      genders: List<String>.from(json['genders'] ?? ['all']),
      languages: List<String>.from(json['languages'] ?? ['id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age_min': ageMin,
      'age_max': ageMax,
      'genders': genders,
      'languages': languages,
    };
  }

  DemographicsModel copyWith({
    int? ageMin,
    int? ageMax,
    List<String>? genders,
    List<String>? languages,
  }) {
    return DemographicsModel(
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      genders: genders ?? this.genders,
      languages: languages ?? this.languages,
    );
  }
}

// lib/data/models/default_targeting_model.dart
class DefaultTargetingModel {
  final DemographicsModel demographics;
  final List<String> interests;
  final List<String> behaviors;

  DefaultTargetingModel({
    required this.demographics,
    required this.interests,
    required this.behaviors,
  });

  factory DefaultTargetingModel.fromJson(Map<String, dynamic> json) {
    return DefaultTargetingModel(
      demographics: DemographicsModel.fromJson(json['demographics'] ?? {}),
      interests: List<String>.from(json['interests'] ?? []),
      behaviors: List<String>.from(json['behaviors'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'demographics': demographics.toJson(),
      'interests': interests,
      'behaviors': behaviors,
    };
  }

  DefaultTargetingModel copyWith({
    DemographicsModel? demographics,
    List<String>? interests,
    List<String>? behaviors,
  }) {
    return DefaultTargetingModel(
      demographics: demographics ?? this.demographics,
      interests: interests ?? this.interests,
      behaviors: behaviors ?? this.behaviors,
    );
  }
}

// lib/data/models/subscription_model.dart
class SubscriptionModel {
  final String plan; // basic, pro, enterprise
  final String status; // active, expired, cancelled
  final DateTime expiresAt;
  final Map<String, int> limits; // campaigns, ad_accounts, etc.

  SubscriptionModel({
    required this.plan,
    required this.status,
    required this.expiresAt,
    required this.limits,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      plan: json['plan'] ?? 'basic',
      status: json['status'] ?? 'active',
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now(),
      limits: Map<String, int>.from(json['limits'] ??
          {
            'campaigns': 5,
            'ad_accounts': 1,
          }),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan,
      'status': status,
      'expires_at': expiresAt.toIso8601String(),
      'limits': limits,
    };
  }

  bool get isActive => status == 'active' && expiresAt.isAfter(DateTime.now());

  bool canCreateCampaign(int currentCampaigns) {
    return isActive && currentCampaigns < (limits['campaigns'] ?? 0);
  }

  bool canAddAdAccount(int currentAdAccounts) {
    return isActive && currentAdAccounts < (limits['ad_accounts'] ?? 0);
  }

  int get campaignLimit => limits['campaigns'] ?? 0;

  int get adAccountLimit => limits['ad_accounts'] ?? 0;

  SubscriptionModel copyWith({
    String? plan,
    String? status,
    DateTime? expiresAt,
    Map<String, int>? limits,
  }) {
    return SubscriptionModel(
      plan: plan ?? this.plan,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      limits: limits ?? this.limits,
    );
  }
}

// lib/data/models/clinic_model.dart
class ClinicModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final LocationModel location;
  final MetaIntegrationModel metaIntegration;
  final DefaultTargetingModel defaultTargeting;
  final SubscriptionModel subscription;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClinicModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.location,
    required this.metaIntegration,
    required this.defaultTargeting,
    required this.subscription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      location: LocationModel.fromJson(json['location'] ?? {}),
      metaIntegration:
          MetaIntegrationModel.fromJson(json['meta_integration'] ?? {}),
      defaultTargeting:
          DefaultTargetingModel.fromJson(json['default_targeting'] ?? {}),
      subscription: SubscriptionModel.fromJson(json['subscription'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'location': location.toJson(),
      'meta_integration': metaIntegration.toJson(),
      'default_targeting': defaultTargeting.toJson(),
      'subscription': subscription.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ClinicModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    LocationModel? location,
    MetaIntegrationModel? metaIntegration,
    DefaultTargetingModel? defaultTargeting,
    SubscriptionModel? subscription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClinicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      location: location ?? this.location,
      metaIntegration: metaIntegration ?? this.metaIntegration,
      defaultTargeting: defaultTargeting ?? this.defaultTargeting,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'ClinicModel(id: $id, name: $name, email: $email)';
}

// lib/data/models/targeting_model.dart
class TargetingModel {
  final LocationModel location;
  final DemographicsModel demographics;
  final List<String> interests;
  final List<String> behaviors;
  final List<String> customAudiences;

  TargetingModel({
    required this.location,
    required this.demographics,
    required this.interests,
    required this.behaviors,
    required this.customAudiences,
  });

  factory TargetingModel.fromJson(Map<String, dynamic> json) {
    return TargetingModel(
      location: LocationModel.fromJson(json['location'] ?? {}),
      demographics: DemographicsModel.fromJson(json['demographics'] ?? {}),
      interests: List<String>.from(json['interests'] ?? []),
      behaviors: List<String>.from(json['behaviors'] ?? []),
      customAudiences: List<String>.from(json['custom_audiences'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'demographics': demographics.toJson(),
      'interests': interests,
      'behaviors': behaviors,
      'custom_audiences': customAudiences,
    };
  }

  TargetingModel copyWith({
    LocationModel? location,
    DemographicsModel? demographics,
    List<String>? interests,
    List<String>? behaviors,
    List<String>? customAudiences,
  }) {
    return TargetingModel(
      location: location ?? this.location,
      demographics: demographics ?? this.demographics,
      interests: interests ?? this.interests,
      behaviors: behaviors ?? this.behaviors,
      customAudiences: customAudiences ?? this.customAudiences,
    );
  }
}

// lib/data/models/ad_creative_model.dart
class AdCreativeModel {
  final String headline;
  final String description;
  final String imageUrl;
  final String ctaText;
  final String landingUrl;

  AdCreativeModel({
    required this.headline,
    required this.description,
    required this.imageUrl,
    required this.ctaText,
    required this.landingUrl,
  });

  factory AdCreativeModel.fromJson(Map<String, dynamic> json) {
    return AdCreativeModel(
      headline: json['headline'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      ctaText: json['cta_text'] ?? 'Learn More',
      landingUrl: json['landing_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'description': description,
      'image_url': imageUrl,
      'cta_text': ctaText,
      'landing_url': landingUrl,
    };
  }

  AdCreativeModel copyWith({
    String? headline,
    String? description,
    String? imageUrl,
    String? ctaText,
    String? landingUrl,
  }) {
    return AdCreativeModel(
      headline: headline ?? this.headline,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ctaText: ctaText ?? this.ctaText,
      landingUrl: landingUrl ?? this.landingUrl,
    );
  }
}

// lib/data/models/budget_model.dart
class BudgetModel {
  final int dailyBudget; // IDR
  final int totalBudget; // IDR
  final String currency;

  BudgetModel({
    required this.dailyBudget,
    required this.totalBudget,
    required this.currency,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      dailyBudget: json['daily_budget'] ?? 0,
      totalBudget: json['total_budget'] ?? 0,
      currency: json['currency'] ?? 'IDR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_budget': dailyBudget,
      'total_budget': totalBudget,
      'currency': currency,
    };
  }

  String get formattedDailyBudget =>
      'Rp ${dailyBudget.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';

  String get formattedTotalBudget =>
      'Rp ${totalBudget.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';

  BudgetModel copyWith({
    int? dailyBudget,
    int? totalBudget,
    String? currency,
  }) {
    return BudgetModel(
      dailyBudget: dailyBudget ?? this.dailyBudget,
      totalBudget: totalBudget ?? this.totalBudget,
      currency: currency ?? this.currency,
    );
  }
}

// lib/data/models/meta_ids_model.dart
class MetaIdsModel {
  final String campaignId;
  final String adsetId;
  final String adId;

  MetaIdsModel({
    required this.campaignId,
    required this.adsetId,
    required this.adId,
  });

  factory MetaIdsModel.fromJson(Map<String, dynamic> json) {
    return MetaIdsModel(
      campaignId: json['campaign_id'] ?? '',
      adsetId: json['adset_id'] ?? '',
      adId: json['ad_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'adset_id': adsetId,
      'ad_id': adId,
    };
  }

  MetaIdsModel copyWith({
    String? campaignId,
    String? adsetId,
    String? adId,
  }) {
    return MetaIdsModel(
      campaignId: campaignId ?? this.campaignId,
      adsetId: adsetId ?? this.adsetId,
      adId: adId ?? this.adId,
    );
  }
}

// lib/data/models/performance_model.dart
class PerformanceModel {
  final int impressions;
  final int clicks;
  final double ctr; // Click-through rate
  final int cpc; // Cost per click in IDR
  final int conversions;
  final int costPerConversion; // IDR

  PerformanceModel({
    required this.impressions,
    required this.clicks,
    required this.ctr,
    required this.cpc,
    required this.conversions,
    required this.costPerConversion,
  });

  factory PerformanceModel.fromJson(Map<String, dynamic> json) {
    return PerformanceModel(
      impressions: json['impressions'] ?? 0,
      clicks: json['clicks'] ?? 0,
      ctr: (json['ctr'] ?? 0.0).toDouble(),
      cpc: json['cpc'] ?? 0,
      conversions: json['conversions'] ?? 0,
      costPerConversion: json['cost_per_conversion'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'impressions': impressions,
      'clicks': clicks,
      'ctr': ctr,
      'cpc': cpc,
      'conversions': conversions,
      'cost_per_conversion': costPerConversion,
    };
  }

  String get formattedCtr => '${ctr.toStringAsFixed(2)}%';

  String get formattedCpc =>
      'Rp ${cpc.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';

  String get formattedCostPerConversion =>
      'Rp ${costPerConversion.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';

  PerformanceModel copyWith({
    int? impressions,
    int? clicks,
    double? ctr,
    int? cpc,
    int? conversions,
    int? costPerConversion,
  }) {
    return PerformanceModel(
      impressions: impressions ?? this.impressions,
      clicks: clicks ?? this.clicks,
      ctr: ctr ?? this.ctr,
      cpc: cpc ?? this.cpc,
      conversions: conversions ?? this.conversions,
      costPerConversion: costPerConversion ?? this.costPerConversion,
    );
  }
}

// lib/data/models/campaign_model.dart
class CampaignModel {
  final String id;
  final String clinicId;
  final String name;
  final String objective; // CONVERSIONS, TRAFFIC, AWARENESS
  final TargetingModel targeting;
  final AdCreativeModel adCreative;
  final BudgetModel budget;
  final MetaIdsModel? metaIds;
  final String status; // draft, active, paused, completed
  final PerformanceModel? performance;
  final DateTime createdAt;

  CampaignModel({
    required this.id,
    required this.clinicId,
    required this.name,
    required this.objective,
    required this.targeting,
    required this.adCreative,
    required this.budget,
    this.metaIds,
    required this.status,
    this.performance,
    required this.createdAt,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] ?? '',
      clinicId: json['clinic_id'] ?? '',
      name: json['name'] ?? '',
      objective: json['objective'] ?? 'CONVERSIONS',
      targeting: TargetingModel.fromJson(json['targeting'] ?? {}),
      adCreative: AdCreativeModel.fromJson(json['ad_creative'] ?? {}),
      budget: BudgetModel.fromJson(json['budget'] ?? {}),
      metaIds: json['meta_ids'] != null
          ? MetaIdsModel.fromJson(json['meta_ids'])
          : null,
      status: json['status'] ?? 'draft',
      performance: json['performance'] != null
          ? PerformanceModel.fromJson(json['performance'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_id': clinicId,
      'name': name,
      'objective': objective,
      'targeting': targeting.toJson(),
      'ad_creative': adCreative.toJson(),
      'budget': budget.toJson(),
      'meta_ids': metaIds?.toJson(),
      'status': status,
      'performance': performance?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';

  bool get isDraft => status == 'draft';

  bool get isPaused => status == 'paused';

  bool get isCompleted => status == 'completed';

  String get statusDisplayName {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'paused':
        return 'Dijeda';
      case 'completed':
        return 'Selesai';
      case 'draft':
        return 'Draft';
      default:
        return 'Unknown';
    }
  }

  CampaignModel copyWith({
    String? id,
    String? clinicId,
    String? name,
    String? objective,
    TargetingModel? targeting,
    AdCreativeModel? adCreative,
    BudgetModel? budget,
    MetaIdsModel? metaIds,
    String? status,
    PerformanceModel? performance,
    DateTime? createdAt,
  }) {
    return CampaignModel(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      name: name ?? this.name,
      objective: objective ?? this.objective,
      targeting: targeting ?? this.targeting,
      adCreative: adCreative ?? this.adCreative,
      budget: budget ?? this.budget,
      metaIds: metaIds ?? this.metaIds,
      status: status ?? this.status,
      performance: performance ?? this.performance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'CampaignModel(id: $id, name: $name, status: $status)';
}

// lib/data/models/ad_template_model.dart
class AdTemplateModel {
  final String id;
  final String name;
  final String category;
  final AdTemplateContentModel template;
  final int usageCount;
  final double rating;

  AdTemplateModel({
    required this.id,
    required this.name,
    required this.category,
    required this.template,
    required this.usageCount,
    required this.rating,
  });

  factory AdTemplateModel.fromJson(Map<String, dynamic> json) {
    return AdTemplateModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      template: AdTemplateContentModel.fromJson(json['template'] ?? {}),
      usageCount: json['usage_count'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'template': template.toJson(),
      'usage_count': usageCount,
      'rating': rating,
    };
  }

  AdTemplateModel copyWith({
    String? id,
    String? name,
    String? category,
    AdTemplateContentModel? template,
    int? usageCount,
    double? rating,
  }) {
    return AdTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      template: template ?? this.template,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
    );
  }
}

// lib/data/models/ad_template_content_model.dart
class AdTemplateContentModel {
  final List<String> headlines;
  final List<String> descriptions;
  final List<String> images;

  AdTemplateContentModel({
    required this.headlines,
    required this.descriptions,
    required this.images,
  });

  factory AdTemplateContentModel.fromJson(Map<String, dynamic> json) {
    return AdTemplateContentModel(
      headlines: List<String>.from(json['headlines'] ?? []),
      descriptions: List<String>.from(json['descriptions'] ?? []),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headlines': headlines,
      'descriptions': descriptions,
      'images': images,
    };
  }

  String getRandomHeadline() {
    if (headlines.isEmpty) return '';
    return headlines[
        (DateTime.now().millisecondsSinceEpoch % headlines.length)];
  }

  String getRandomDescription() {
    if (descriptions.isEmpty) return '';
    return descriptions[
        (DateTime.now().millisecondsSinceEpoch % descriptions.length)];
  }

  String getRandomImage() {
    if (images.isEmpty) return '';
    return images[(DateTime.now().millisecondsSinceEpoch % images.length)];
  }

  AdTemplateContentModel copyWith({
    List<String>? headlines,
    List<String>? descriptions,
    List<String>? images,
  }) {
    return AdTemplateContentModel(
      headlines: headlines ?? this.headlines,
      descriptions: descriptions ?? this.descriptions,
      images: images ?? this.images,
    );
  }
}
