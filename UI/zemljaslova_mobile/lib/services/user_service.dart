import 'package:flutter/foundation.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService;
  
  UserService(this._apiService);
  
  Future<bool> changePassword(
    int userId,
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    try {
      final data = {
        'userId': userId,
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'newPasswordConfirmation': newPasswordConfirmation,
      };
      
      return await _apiService.post('User/change_password', data);
      
    } catch (e) {
      throw Exception('Greška prilikom promjene lozinke.');
    }
  }
} 