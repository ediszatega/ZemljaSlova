import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final String _tokenKey = 'auth_token';
  
  // Current logged in user info
  Map<String, dynamic>? _currentUser;
  
  AuthService(this._apiService);
  
  // Getter for current user
  Map<String, dynamic>? get currentUser => _currentUser;
  
  // Initialize - check if token exists and is valid
  Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    
    if (token != null) {
      _apiService.authToken = token;
      return true;
    }
    
    return false;
  }
  
  Future<bool> login(String username, String password) async {
    try {
      final loginData = {
        'username': username,
        'password': password,
      };
      
      final response = await _apiService.post('login', loginData);
      
      if (response != null && response['token'] != null) {
        final token = response['token'];
        _apiService.authToken = token;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        
        if (response['user'] != null) {
          _currentUser = response['user'];
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> logout() async {
    _apiService.authToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    
    _currentUser = null;
  }
} 