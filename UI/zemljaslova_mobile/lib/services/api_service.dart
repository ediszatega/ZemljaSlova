import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.11:5285';
      
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
    final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await headers);
    
    if (response.statusCode == 401) {
      await _handleTokenRefresh();
      
      final newHeaders = await headers;
      final retryResponse = await http.get(uri, headers: newHeaders);
      
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
      
      final newHeaders = await headers;
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
      
      final newHeaders = await headers;
      final retryResponse = await http.delete(url, headers: newHeaders);
      
      return _handleResponse(retryResponse);
    }
    
    return _handleResponse(response);
  }

  Future<dynamic> postMultipart(String endpoint, Map<String, dynamic> data, {Uint8List? imageBytes, String? imageFieldName}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final token = authToken ?? await _storage.read(key: 'jwt');
    
    final request = http.MultipartRequest('POST', url);
    
    // Add authorization header
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add regular form fields
    data.forEach((key, value) {
      if (value != null) {
        if (value is double) {
          request.fields[key] = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });
    
    // Add image file if provided
    if (imageBytes != null && imageFieldName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        imageFieldName,
        imageBytes,
        filename: 'image.jpg',
      )); 
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 401) {
      await _handleTokenRefresh();
      
      // Retry with new token
      final retryRequest = http.MultipartRequest('POST', url);
      final newToken = authToken ?? await _storage.read(key: 'jwt');
      
      if (newToken != null && newToken.isNotEmpty) {
        retryRequest.headers['Authorization'] = 'Bearer $newToken';
      }
      
      data.forEach((key, value) {
        if (value != null) {
          if (value is double) {
            retryRequest.fields[key] = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
          } else {
            retryRequest.fields[key] = value.toString();
          }
        }
      });
      
      if (imageBytes != null && imageFieldName != null) {
        retryRequest.files.add(http.MultipartFile.fromBytes(
          imageFieldName,
          imageBytes,
          filename: 'image.jpg',
        ));
      }
      
      final retryStreamedResponse = await retryRequest.send();
      final retryResponse = await http.Response.fromStream(retryStreamedResponse);
      
      return _handleResponse(retryResponse);
    }
    
    return _handleResponse(response);
  }

  Future<dynamic> putMultipart(String endpoint, Map<String, dynamic> data, {Uint8List? imageBytes, String? imageFieldName}) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final token = authToken ?? await _storage.read(key: 'jwt');
    
    final request = http.MultipartRequest('PUT', url);
    
    // Add authorization header
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    // Add regular form fields
    data.forEach((key, value) {
      if (value != null) {
        if (value is double) {
          request.fields[key] = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });
    
    // Add image file if provided
    if (imageBytes != null && imageFieldName != null) {
      request.files.add(http.MultipartFile.fromBytes(
        imageFieldName,
        imageBytes,
        filename: 'image.jpg',
      ));
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 401) {
      await _handleTokenRefresh();
      
      // Retry with new token
      final retryRequest = http.MultipartRequest('PUT', url);
      final newToken = authToken ?? await _storage.read(key: 'jwt');
      
      if (newToken != null && newToken.isNotEmpty) {
        retryRequest.headers['Authorization'] = 'Bearer $newToken';
      }
      
      data.forEach((key, value) {
        if (value != null) {
          if (value is double) {
            retryRequest.fields[key] = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
          } else {
            retryRequest.fields[key] = value.toString();
          }
        }
      });
      
      if (imageBytes != null && imageFieldName != null) {
        retryRequest.files.add(http.MultipartFile.fromBytes(
          imageFieldName,
          imageBytes,
          filename: 'image.jpg',
        ));
      }
      
      final retryStreamedResponse = await retryRequest.send();
      final retryResponse = await http.Response.fromStream(retryStreamedResponse);
      
      return _handleResponse(retryResponse);
    }
    
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          final decoded = json.decode(response.body);
          return decoded;
        } catch (e) {
          throw Exception('Invalid JSON response from server');
        }
      }
      return null;
    } else {
      throw Exception('API Error: [${response.statusCode}] ${response.reasonPhrase}');
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
        },
        body: json.encode({'token': currentToken}),
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
} 