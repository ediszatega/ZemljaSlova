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
      
      debugPrint('Making GET request to: $url');
      final response = await http.get(url, headers: headers);
      
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Error in GET request: $e');
      throw Exception('Failed to perform GET request: $e');
    }
  }
  
  dynamic _handleResponse(http.Response response) {
    debugPrint('Response status code: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          return json.decode(response.body);
        } catch (e) {
          debugPrint('Failed to decode JSON response: $e');
          debugPrint('Raw response body: ${response.body}');
          throw Exception('Invalid JSON response from server');
        }
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