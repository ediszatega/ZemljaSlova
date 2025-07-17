import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = kDebugMode 
      ? 'http://192.168.178.36:5285'  // Use your computer's IP address for physical device testing
      : 'http://localhost:5285';

  ApiService() {
    HttpOverrides.global = MyHttpOverrides();
  }
  
  Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
    };
  }
  
  Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.get(url, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform GET request: $e');
    }
  }
  
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.post(
        url, 
        headers: headers,
        body: json.encode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }
  
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final response = await http.delete(url, headers: headers);
      
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
    } else {
      throw Exception('API Error: [${response.statusCode}] ${response.reasonPhrase}');
    }
  }
}

// Custom HttpOverrides to bypass certificate validation
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
} 