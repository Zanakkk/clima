// lib/services/meta_ads_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:http/http.dart' as http;

class MetaAdsService {
  static const String baseUrl = 'https://graph.facebook.com/v18.0';

  static Future<Map<String, dynamic>?> createCampaign({
    required String accessToken,
    required String adAccountId,
    required String campaignName,
    required String objective,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/act_$adAccountId/campaigns'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': campaignName,
          'objective': objective,
          'status': 'PAUSED',
          'special_ad_categories': []
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      print('Campaign creation failed: ${response.body}');
      return null;
    } catch (e) {
      print('Error creating campaign: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createAdSet({
    required String accessToken,
    required String campaignId,
    required String adSetName,
    required Map<String, dynamic> targeting,
    required int dailyBudget,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$campaignId/adsets'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': adSetName,
          'campaign_id': campaignId,
          'daily_budget': dailyBudget * 100, // Convert to cents
          'billing_event': 'IMPRESSIONS',
          'optimization_goal': 'CONVERSIONS',
          'targeting': targeting,
          'status': 'PAUSED',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error creating adset: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createAd({
    required String accessToken,
    required String adAccountId,
    required String adSetId,
    required String adName,
    required Map<String, dynamic> creative,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/act_$adAccountId/ads'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': adName,
          'adset_id': adSetId,
          'creative': creative,
          'status': 'PAUSED',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error creating ad: $e');
      return null;
    }
  }

  // Get Campaign Performance
  static Future<Map<String, dynamic>?> getCampaignInsights({
    required String accessToken,
    required String campaignId,
    String datePreset = 'last_7_days',
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/$campaignId/insights?date_preset=$datePreset&fields=impressions,clicks,ctr,cpc,conversions,cost_per_conversion,spend'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'].isNotEmpty ? data['data'][0] : null;
      }
      return null;
    } catch (e) {
      print('Error getting insights: $e');
      return null;
    }
  }
}
