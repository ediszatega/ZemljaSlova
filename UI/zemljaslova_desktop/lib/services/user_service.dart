import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../utils/authorization.dart';

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

  Future<bool> adminChangePassword(
    int userId,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    try {
      final data = {
        'userId': userId,
        'newPassword': newPassword,
        'newPasswordConfirmation': newPasswordConfirmation,
      };
      
      return await _apiService.post('User/admin_change_password', data);
    } catch (e) {
      throw Exception('Greška prilikom promjene lozinke.');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      if (Authorization.userId == null) {
        return null;
      }

      // For desktop app, we only handle employees
      if (!Authorization.isEmployee) {
        throw Exception('Korisnik nije zaposlenik.');
      }

      final response = await _apiService.get('Employee/GetEmployeeByUserId/${Authorization.userId}');
      
      return _mapEmployeeToProfileData(response);
    } catch (e) {
      throw Exception('Greška prilikom učitavanja profila korisnika.');
    }
  }

  Map<String, dynamic> _mapEmployeeToProfileData(dynamic employeeData) {
    String firstName = '';
    String lastName = '';
    String email = '';
    String? gender;
    String accessLevel = '';
    int employeeId = 0;
    
    // Extract employee data
    employeeId = employeeData['id'] ?? 0;
    accessLevel = employeeData['accessLevel'] ?? '';
    
    // Extract user data
    if (employeeData['user'] is Map) {
      Map<String, dynamic> userData = employeeData['user'];
      firstName = userData['firstName'] ?? '';
      lastName = userData['lastName'] ?? '';
      email = userData['email'] ?? '';
      gender = userData['gender'];
    }
    
    // Determine position based on access level
    String position;
    switch (accessLevel.toLowerCase()) {
      case 'admin':
        position = 'Administrator';
        break;
      case 'employee':
        position = 'Zaposlenik';
        break;
      default:
        position = 'Zaposlenik';
    }
    
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender ?? 'Nije navedeno',
      'position': position,
      'accessLevel': accessLevel,
      'employeeId': employeeId,
    };
  }
} 