import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your machine's local IP (found via ipconfig) so real devices can connect
  // Dynamic baseUrl detection
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    // Use the machine's local IP (found via ipconfig) so both emulators and real devices can connect
    // Your current local IP: 192.168.0.4
    return 'http://192.168.0.4:8000';
  }

  static Uri _url(String path) => Uri.parse('$baseUrl/$path');

  static Future<List<dynamic>> _getList(String path) async {
    try {
      final url = _url(path);
      debugPrint('Fetching API: $url');
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      } else {
        debugPrint('API Error [$path]: Status ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      debugPrint('API Connection Error [$path] at $baseUrl: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchNews({int? categoryId, String? search}) async {
    String path = 'api/v1/news/';
    List<String> params = [];
    if (categoryId != null && categoryId != 0) params.add('category=$categoryId');
    if (search != null && search.isNotEmpty) params.add('search=${Uri.encodeComponent(search)}');
    
    if (params.isNotEmpty) {
      path += '?${params.join('&')}';
    }
    
    final data = await _getList(path);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchBloodDonors({String? group}) async {
    final path = group != null && group.isNotEmpty
        ? 'api/v1/blood-donors/?group=${Uri.encodeComponent(group)}'
        : 'api/v1/blood-donors/';
    final data = await _getList(path);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchDoctors({String? specialty}) async {
    final path = specialty != null && specialty.isNotEmpty
        ? 'api/v1/doctors/?specialty=${Uri.encodeComponent(specialty)}'
        : 'api/v1/doctors/';
    final data = await _getList(path);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchJobs() async {
    final data = await _getList('api/v1/jobs/');
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchEmergencyContacts({String? category}) async {
    final path = category != null ? 'api/v1/emergency/?category=${Uri.encodeComponent(category)}' : 'api/v1/emergency/';
    final data = await _getList(path);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchBusSchedules() async {
    final data = await _getList('api/v1/bus-schedules/');
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchTouristSpots() async {
    final data = await _getList('api/v1/tourist-spots/');
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchEducation() async {
    final data = await _getList('api/v1/education/');
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchGovtServices() async {
    final data = await _getList('api/v1/govt-services/');
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchExpertServices({String? category}) async {
    final path = category != null ? 'api/v1/expert-services/?category=${Uri.encodeComponent(category)}' : 'api/v1/expert-services/';
    final data = await _getList(path);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchHomeServices() async {
    final data = await _getList('api/v1/home-services/');
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchHospitals() async {
    final data = await _getList('api/v1/hospitals/');
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchAds({String? placement}) async {
    final path = placement != null ? 'api/v1/ads/?placement=$placement' : 'api/v1/ads/';
    final data = await _getList(path);
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<Map<String, dynamic>?> fetchSettings() async {
    try {
      final res = await http.get(_url('api/v1/settings/')).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('API Error fetchSettings: $e');
    }
    return null;
  }

  static Future<void> trackAdView(int adId) async {
    try {
      await http.post(_url('api/v1/ads/$adId/view/')).timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Failed to track ad view: $e');
    }
  }

  static Future<void> trackAdClick(int adId) async {
    try {
      await http.post(_url('api/v1/ads/$adId/click/')).timeout(const Duration(seconds: 5));
    } catch (e) {
      print('Failed to track ad click: $e');
    }
  }

  static Future<bool> submitComplaint(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        _url('api/v1/complaints/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
