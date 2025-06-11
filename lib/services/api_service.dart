import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final String _baseUrl = dotenv.env['EXTRACT_URL'] ?? '';

  Future<String?> _getBearerToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    final accessToken = session?.accessToken;
    return accessToken;
  }

  Future<http.Response> get(
      String endpoint, {
        bool isAuthenticate = false,
        Map<String, String>? headers,
      }) async {

    Get.log('GET: $_baseUrl$endpoint');

    final Uri url = Uri.parse('$_baseUrl$endpoint');
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (isAuthenticate) {
      final token = await _getBearerToken();
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    return await http.get(url, headers: requestHeaders);
  }

  Future<http.Response> post(
      String endpoint, {
        Map<String, dynamic>? body,
        bool isAuthenticate = false,
        Map<String, String>? headers,
      }) async {
    final Uri url = Uri.parse('$_baseUrl$endpoint');
    Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
      ...?headers,
    };

    if (isAuthenticate) {
      final token = await _getBearerToken();
      if (token != null) {
        requestHeaders['Authorization'] = 'Bearer $token';
      }
    }

    return await http.post(
      url,
      headers: requestHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
  }
}