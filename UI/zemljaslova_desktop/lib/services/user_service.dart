import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/employee.dart';
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
      
      final response = await _apiService.post('User/change_password', data);
      
      if (response != null) {
        debugPrint('Password changed successfully');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to change password: $e');
      return false;
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
      
      final response = await _apiService.post('User/admin_change_password', data);
      
      if (response != null) {
        debugPrint('Password changed successfully by admin');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to change password as admin: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      if (Authorization.userId == null) {
        debugPrint('User ID is null');
        return null;
      }

      // For desktop app, we only handle employees
      if (!Authorization.isEmployee) {
        debugPrint('User is not an employee. Desktop app only supports employees.');
        debugPrint('Role check failed. Role: ${Authorization.role}');
        return null;
      }

      // Use the new endpoint to get employee by userId
      final response = await _apiService.get('Employee/by-user/${Authorization.userId}');
      
      if (response != null) {
        return _mapEmployeeToProfileData(response);
      }
      
      debugPrint('No employee found for user ID: ${Authorization.userId}');
      return null;
    } catch (e) {
      debugPrint('Failed to get current user profile: $e');
      return null;
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