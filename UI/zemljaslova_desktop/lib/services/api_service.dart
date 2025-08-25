import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5285';
      
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
  
  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await this.headers;
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 401) {
      await _handleTokenRefresh();
      
      final newHeaders = await this.headers;
      final retryResponse = await http.get(url, headers: newHeaders);
      
      return _handleResponse(retryResponse);
    }
    
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = await this.headers;
    
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(data),
    );
    
    if (response.statusCode == 401) {
      await _handleTokenRefresh();
      
      final newHeaders = await this.headers;
      final retryResponse = await http.post(
        url,
        headers: newHeaders,
        body: json.encode(data),
      );
      
      return _handleResponse(retryResponse);
    }
    
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    
    final response = await http.put(
      url,
      headers: await headers,
      body: json.encode(data),
    );
    
    if (response.statusCode == 401) {
      await _handleTokenRefresh();
      
      final newHeaders = await this.headers;
      final retryResponse = await http.put(
        url,
        headers: newHeaders,
        body: json.encode(data),
      );
      
      return _handleResponse(retryResponse);
    }
    
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    
    final response = await http.delete(url, headers: await headers);
    
    if (response.statusCode == 401) {
      await _handleTokenRefresh();
      
      final newHeaders = await this.headers;
      final retryResponse = await http.delete(url, headers: newHeaders);
      
      return _handleResponse(retryResponse);
    }
    
    return _handleResponse(response);
  }
  
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return null;
    } else {
      String errorMessage = 'API Error: [${response.statusCode}] ${response.reasonPhrase}';
      
      if (response.body.isNotEmpty) {
        final errorData = json.decode(response.body);
        
        // Extract userError from UserException response
        if (errorData is Map<String, dynamic> && 
            errorData.containsKey('errors') && 
            errorData['errors'] is Map<String, dynamic>) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          
          if (errors.containsKey('userError')) {
            final userErrors = errors['userError'] as List;
            if (userErrors.isNotEmpty) {
              errorMessage = userErrors.first.toString();
            }
          }
        }
      }
      
      throw Exception(errorMessage);
    }
  }

  Future<void> _handleTokenRefresh() async {
    try {
      final currentToken = authToken ?? await _storage.read(key: 'jwt');
      if (currentToken == null || currentToken.isEmpty) {
        return; // No token to refresh
      }

      final response = await http.post(
        Uri.parse('$baseUrl/User/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $currentToken',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final newToken = responseData['token'] as String?;
        
        if (newToken != null) {
          await _storage.write(key: 'jwt', value: newToken);
          authToken = newToken;
        }
      }
    } catch (e) {
      await _storage.delete(key: 'jwt');
      authToken = null;
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