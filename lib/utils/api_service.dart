import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your machine's local IP (found via ipconfig) so real devices can connect
  static const String _base = 'http://192.168.0.4:8000'; 
  
  static Uri _url(String path) => Uri.parse('$_base/$path');

  static Future<List<dynamic>> _getList(String path) async {
    try {
      final res = await http.get(_url(path)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as List<dynamic>;
      } else {
        print('API Error [$path]: Status ${res.statusCode}');
      }
    } catch (e) {
      print('API Connection Error [$path]: $e');
    }
    return [];
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
    final path = category != null ? 'api/v1/emergency/?category=$category' : 'api/v1/emergency/';
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

  static Future<List<Map<String, dynamic>>> fetchAds() async {
    final data = await _getList('api/v1/ads/');
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
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
