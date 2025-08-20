import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.178.36:5285';
      
  String? authToken;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    HttpOverrides.global = MyHttpOverrides();
    _loadToken();
  }

  Future<void> _loadToken() async {
    authToken = await _storage.read(key: 'jwt');
  }

  Future<Map<String, String>> get headers async {
    final token = authToken ?? await _storage.read(key: 'jwt');
    var headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await headers);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform GET request: $e');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await this.headers;
      
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.put(
        url,
        headers: await headers,
        body: json.encode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform PUT request: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.delete(url, headers: await headers);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform DELETE request: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          return json.decode(response.body);
        } catch (e) {
          throw Exception('Invalid JSON response from server');
        }
      }
      return null;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception('API Error: [${response.statusCode}] ${response.reasonPhrase}');
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
} 