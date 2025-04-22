import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5285';

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
      
      debugPrint('Making GET request to: $url');
      final response = await http.get(url, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error in GET request: $e');
      throw Exception('Failed to perform GET request: $e');
    }
  }
  
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error in POST request: $e');
      throw Exception('Failed to perform POST request: $e');
    }
  }
  
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error in PUT request: $e');
      throw Exception('Failed to perform PUT request: $e');
    }
  }
  
  Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      
      final response = await http.delete(url, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error in DELETE request: $e');
      throw Exception('Failed to perform DELETE request: $e');
    }
  }
  
  dynamic _handleResponse(http.Response response) {
    debugPrint('Response status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return null;
    } else {
      debugPrint('API Error: [${response.statusCode}] ${response.body}');
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