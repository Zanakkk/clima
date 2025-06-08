// lib/services/http_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../Models/model.dart';

class HttpService {
  static const String baseUrl = 'https://api.climaads.com/v1';
  static const Duration timeoutDuration = Duration(seconds: 30);

  String? _accessToken;

  void setAccessToken(String token) {
    _accessToken = token;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
          )
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Request failed');
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final HttpService _httpService = HttpService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Get Firebase token and set to HTTP service
      final token = await credential.user?.getIdToken();
      if (token != null) {
        _httpService.setAccessToken(token);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signUpWithEmailPassword(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Get Firebase token and set to HTTP service
      final token = await credential.user?.getIdToken();
      if (token != null) {
        _httpService.setAccessToken(token);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Get Firebase token and set to HTTP service
      final token = await userCredential.user?.getIdToken();
      if (token != null) {
        _httpService.setAccessToken(token);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'invalid-email':
        return 'Format email tidak valid';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Generic CRUD operations
  Future<void> create(
      String collection, String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(id).set(data);
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  Future<Map<String, dynamic>?> read(String collection, String id) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to read document: $e');
    }
  }

  Future<void> update(
      String collection, String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(id).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> delete(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  // Query operations
  Future<List<Map<String, dynamic>>> getCollection(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      Query query = _firestore.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to get collection: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> streamCollection(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) {
    try {
      Query query = _firestore.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList());
    } catch (e) {
      throw Exception('Failed to stream collection: $e');
    }
  }

  // File upload
  Future<String> uploadFile(String path, File file) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Batch operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final type = operation['type'];
        final collection = operation['collection'];
        final id = operation['id'];
        final data = operation['data'];

        final docRef = _firestore.collection(collection).doc(id);

        switch (type) {
          case 'set':
            batch.set(docRef, data);
            break;
          case 'update':
            batch.update(docRef, data);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to execute batch write: $e');
    }
  }
}

class MetaAdsService {
  final HttpService _httpService = HttpService();

  // Meta Integration
  Future<String> getMetaAuthUrl(String clinicId) async {
    try {
      final response =
          await _httpService.get('/meta/auth-url?clinic_id=$clinicId');
      return response['auth_url'];
    } catch (e) {
      throw Exception('Failed to get Meta auth URL: $e');
    }
  }

  Future<MetaIntegrationModel> connectMetaAccount(
      String clinicId, String code) async {
    try {
      final response = await _httpService.post('/meta/connect', {
        'clinic_id': clinicId,
        'code': code,
      });
      return MetaIntegrationModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to connect Meta account: $e');
    }
  }

  Future<void> disconnectMetaAccount(String clinicId) async {
    try {
      await _httpService.delete('/meta/connect/$clinicId');
    } catch (e) {
      throw Exception('Failed to disconnect Meta account: $e');
    }
  }

  // Campaign Management
  Future<CampaignModel> createCampaign(CampaignModel campaign) async {
    try {
      final response = await _httpService.post('/campaigns', campaign.toJson());
      return CampaignModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to create campaign: $e');
    }
  }

  Future<CampaignModel> updateCampaign(
      String campaignId, CampaignModel campaign) async {
    try {
      final response =
          await _httpService.put('/campaigns/$campaignId', campaign.toJson());
      return CampaignModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to update campaign: $e');
    }
  }

  Future<void> pauseCampaign(String campaignId) async {
    try {
      await _httpService.post('/campaigns/$campaignId/pause', {});
    } catch (e) {
      throw Exception('Failed to pause campaign: $e');
    }
  }

  Future<void> resumeCampaign(String campaignId) async {
    try {
      await _httpService.post('/campaigns/$campaignId/resume', {});
    } catch (e) {
      throw Exception('Failed to resume campaign: $e');
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _httpService.delete('/campaigns/$campaignId');
    } catch (e) {
      throw Exception('Failed to delete campaign: $e');
    }
  }

  // Performance & Analytics
  Future<PerformanceModel> getCampaignPerformance(
    String campaignId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String endpoint = '/campaigns/$campaignId/performance';
      final params = <String>[];

      if (startDate != null) {
        params.add('start_date=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        params.add('end_date=${endDate.toIso8601String()}');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final response = await _httpService.get(endpoint);
      return PerformanceModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to get campaign performance: $e');
    }
  }

  Future<List<PerformanceModel>> getClinicPerformance(
    String clinicId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String endpoint = '/clinics/$clinicId/performance';
      final params = <String>[];

      if (startDate != null) {
        params.add('start_date=${startDate.toIso8601String()}');
      }
      if (endDate != null) {
        params.add('end_date=${endDate.toIso8601String()}');
      }

      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }

      final response = await _httpService.get(endpoint);
      return (response['data'] as List)
          .map((item) => PerformanceModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to get clinic performance: $e');
    }
  }

  // Audience & Targeting
  Future<List<String>> getInterestSuggestions(String query) async {
    try {
      final response = await _httpService.get('/meta/interests?q=$query');
      return List<String>.from(response['data']);
    } catch (e) {
      throw Exception('Failed to get interest suggestions: $e');
    }
  }

  Future<Map<String, dynamic>> getAudienceSize(
      Map<String, dynamic> targeting) async {
    try {
      final response =
          await _httpService.post('/meta/audience-size', targeting);
      return response['data'];
    } catch (e) {
      throw Exception('Failed to get audience size: $e');
    }
  }

  // Budget Optimization
  Future<Map<String, dynamic>> getBudgetRecommendation(
    String objective,
    Map<String, dynamic> targeting,
  ) async {
    try {
      final response = await _httpService.post('/meta/budget-recommendation', {
        'objective': objective,
        'targeting': targeting,
      });
      return response['data'];
    } catch (e) {
      throw Exception('Failed to get budget recommendation: $e');
    }
  }

  // Creative Testing
  Future<List<Map<String, dynamic>>> getCreativeInsights(
      String campaignId) async {
    try {
      final response =
          await _httpService.get('/campaigns/$campaignId/creative-insights');
      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      throw Exception('Failed to get creative insights: $e');
    }
  }
}

class ClinicService {
  final FirebaseService _firebaseService = FirebaseService();
  final HttpService _httpService = HttpService();

  Future<ClinicModel> createClinic(ClinicModel clinic) async {
    try {
      // Save to Firebase
      await _firebaseService.create('clinics', clinic.id, clinic.toJson());

      // Sync to backend
      final response = await _httpService.post('/clinics', clinic.toJson());
      return ClinicModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to create clinic: $e');
    }
  }

  Future<ClinicModel?> getClinic(String clinicId) async {
    try {
      final data = await _firebaseService.read('clinics', clinicId);
      return data != null ? ClinicModel.fromJson(data) : null;
    } catch (e) {
      throw Exception('Failed to get clinic: $e');
    }
  }

  Future<ClinicModel> updateClinic(String clinicId, ClinicModel clinic) async {
    try {
      // Update in Firebase
      await _firebaseService.update('clinics', clinicId, clinic.toJson());

      // Sync to backend
      final response =
          await _httpService.put('/clinics/$clinicId', clinic.toJson());
      return ClinicModel.fromJson(response['data']);
    } catch (e) {
      throw Exception('Failed to update clinic: $e');
    }
  }

  Future<List<ClinicModel>> getUserClinics(String userId) async {
    try {
      final data = await _firebaseService.getCollection(
        'clinics',
        queryBuilder: (query) => query.where('owner_id', isEqualTo: userId),
      );

      return data.map((item) => ClinicModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get user clinics: $e');
    }
  }

  Stream<List<ClinicModel>> streamUserClinics(String userId) {
    try {
      return _firebaseService
          .streamCollection(
            'clinics',
            queryBuilder: (query) => query.where('owner_id', isEqualTo: userId),
          )
          .map((data) =>
              data.map((item) => ClinicModel.fromJson(item)).toList());
    } catch (e) {
      throw Exception('Failed to stream user clinics: $e');
    }
  }

  Future<void> deleteClinic(String clinicId) async {
    try {
      // Delete from Firebase
      await _firebaseService.delete('clinics', clinicId);

      // Delete from backend
      await _httpService.delete('/clinics/$clinicId');
    } catch (e) {
      throw Exception('Failed to delete clinic: $e');
    }
  }
}

class CampaignService {
  final FirebaseService _firebaseService = FirebaseService();
  final MetaAdsService _metaAdsService = MetaAdsService();

  Future<CampaignModel> createCampaign(CampaignModel campaign) async {
    try {
      // Create in Meta Ads via backend
      final createdCampaign = await _metaAdsService.createCampaign(campaign);

      // Save to Firebase
      await _firebaseService.create(
          'campaigns', createdCampaign.id, createdCampaign.toJson());

      return createdCampaign;
    } catch (e) {
      throw Exception('Failed to create campaign: $e');
    }
  }

  Future<CampaignModel?> getCampaign(String campaignId) async {
    try {
      final data = await _firebaseService.read('campaigns', campaignId);
      return data != null ? CampaignModel.fromJson(data) : null;
    } catch (e) {
      throw Exception('Failed to get campaign: $e');
    }
  }

  Future<CampaignModel> updateCampaign(
      String campaignId, CampaignModel campaign) async {
    try {
      // Update in Meta Ads via backend
      final updatedCampaign =
          await _metaAdsService.updateCampaign(campaignId, campaign);

      // Update in Firebase
      await _firebaseService.update(
          'campaigns', campaignId, updatedCampaign.toJson());

      return updatedCampaign;
    } catch (e) {
      throw Exception('Failed to update campaign: $e');
    }
  }

  Future<List<CampaignModel>> getClinicCampaigns(String clinicId) async {
    try {
      final data = await _firebaseService.getCollection(
        'campaigns',
        queryBuilder: (query) => query
            .where('clinic_id', isEqualTo: clinicId)
            .orderBy('created_at', descending: true),
      );

      return data.map((item) => CampaignModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to get clinic campaigns: $e');
    }
  }

  Stream<List<CampaignModel>> streamClinicCampaigns(String clinicId) {
    try {
      return _firebaseService
          .streamCollection(
            'campaigns',
            queryBuilder: (query) => query
                .where('clinic_id', isEqualTo: clinicId)
                .orderBy('created_at', descending: true),
          )
          .map((data) =>
              data.map((item) => CampaignModel.fromJson(item)).toList());
    } catch (e) {
      throw Exception('Failed to stream clinic campaigns: $e');
    }
  }

  Future<void> pauseCampaign(String campaignId) async {
    try {
      await _metaAdsService.pauseCampaign(campaignId);

      // Update status in Firebase
      await _firebaseService.update('campaigns', campaignId, {
        'status': 'paused',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to pause campaign: $e');
    }
  }

  Future<void> resumeCampaign(String campaignId) async {
    try {
      await _metaAdsService.resumeCampaign(campaignId);

      // Update status in Firebase
      await _firebaseService.update('campaigns', campaignId, {
        'status': 'active',
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to resume campaign: $e');
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      // Delete from Meta Ads
      await _metaAdsService.deleteCampaign(campaignId);

      // Delete from Firebase
      await _firebaseService.delete('campaigns', campaignId);
    } catch (e) {
      throw Exception('Failed to delete campaign: $e');
    }
  }
}
