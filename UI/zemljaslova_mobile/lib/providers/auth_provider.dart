import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth/login_response.dart';
import '../services/api_service.dart';
import '../utils/authorization.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  final bool _isAdmin;
  String get _endpoint => _isAdmin ? "User/employee_login" : "User/member_login";
  final _storage = const FlutterSecureStorage();
  final ApiService _apiService;

  AuthProvider({required ApiService apiService, bool isAdmin = false}) 
      : _apiService = apiService, _isAdmin = isAdmin;

  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;

  Future<LoginResponse> login() async {
    try {
      final body = {
        "email": Authorization.email,
        "password": Authorization.password
      };

      final response = await _apiService.post(_endpoint, body);

      if (response != null) {
        var data = LoginResponse.fromJson(response);
        if (data.isSuccess) {
          await _storage.write(key: "jwt", value: data.token);
          _apiService.authToken = data.token;
          _isLoggedIn = true;
          Authorization.userId = data.userId;
          Authorization.role = data.role;
          Authorization.token = data.token;
          notifyListeners();
        }
        return data;
      } else {
        throw Exception("Login failed");
      }
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: "jwt");
    _apiService.authToken = null;
    _isLoggedIn = false;
    Authorization.clear();
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    String? token = await _storage.read(key: "jwt");
    _isLoggedIn = token != null && token.isNotEmpty;
    if (_isLoggedIn) {
      _apiService.authToken = token;
      Authorization.token = token;
    }
    return _isLoggedIn;
  }
}