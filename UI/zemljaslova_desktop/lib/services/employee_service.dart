import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/employee.dart';
import 'api_service.dart';

class EmployeeService {
  final ApiService _apiService;
  
  EmployeeService(this._apiService);
  
  Future<Map<String, dynamic>> fetchEmployees({
    bool isUserIncluded = true,
    int? page,
    int? pageSize,
    String? name,
    String? sortBy,
    String? sortOrder,
    Map<String, dynamic>? filters,
  }) async {
    try {
      List<String> queryParams = ['IsUserIncluded=$isUserIncluded'];
      
      if (page != null) {
        queryParams.add('Page=$page');
      }
      
      if (pageSize != null) {
        queryParams.add('PageSize=$pageSize');
      }
      
      if (name != null && name.isNotEmpty) {
        queryParams.add('Name=${Uri.encodeComponent(name)}');
      }
      
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams.add('SortBy=${Uri.encodeComponent(sortBy)}');
      }
      
      if (sortOrder != null && sortOrder.isNotEmpty) {
        queryParams.add('SortOrder=${Uri.encodeComponent(sortOrder)}');
      }
      
      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value != null) {
            queryParams.add('${entry.key}=${Uri.encodeComponent(entry.value.toString())}');
          }
        }
      }
      
      final queryString = queryParams.join('&');
      final response = await _apiService.get('Employee?$queryString');
      
      if (response != null) {
        final employeesList = response['resultList'] as List;
        final totalCount = response['count'] as int;
        
        final employees = employeesList
            .map((employeeJson) => _mapEmployeeFromBackend(employeeJson))
            .toList();
            
        return {
          'employees': employees,
          'totalCount': totalCount,
        };
      }
      
      return {
        'employees': <Employee>[],
        'totalCount': 0,
      };
    } catch (e) {
      debugPrint('Failed to fetch employees: $e');
      return {
        'employees': <Employee>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Employee> getEmployeeById(int id) async {
    try {
      final response = await _apiService.get('Employee/$id');
      
      if (response != null) {
        return _mapEmployeeFromBackend(response);
      }
      
      throw Exception('Employee not found');
    } catch (e) {
      debugPrint('Failed to get employee: $e');
      throw Exception('Failed to get employee: $e');
    }
  }
  
  Future<Employee?> createEmployee(
    String firstName,
    String lastName,
    String email,
    String password,
    String accessLevel,
    String? gender,
  ) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'accessLevel': accessLevel,
        'gender': gender,
      };
      
      final response = await _apiService.post('Employee/CreateEmployee', data);
      
      if (response != null) {
        return _mapEmployeeFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to create employee: $e');
      throw Exception('Failed to create employee: $e');
    }
  }
  
  Future<Employee?> updateEmployee(
    int id,
    String firstName,
    String lastName,
    String email,
    String accessLevel,
    String? gender,
  ) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'gender': gender,
        'accessLevel': accessLevel
      };
      
      final response = await _apiService.put('Employee/UpdateEmployee/$id', data);
      
      if (response != null) {
        return _mapEmployeeFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to update employee: $e');
      throw Exception('Failed to update employee: $e');
    }
  }
  
  Future<bool> deleteEmployee(int id) async {
    try {
      await _apiService.delete('Employee/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }
  
  Employee _mapEmployeeFromBackend(dynamic employeeData) {
    String? profileImageUrl;
    if (employeeData['profileImage'] != null) {
      if (employeeData['profileImage'] is List) {
        final bytes = List<int>.from(employeeData['profileImage']);
        profileImageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else if (employeeData['profileImage'] is String) {
        profileImageUrl = employeeData['profileImage'];
      }
    }
    
    // Extract employee specific data
    int userId = employeeData['userId'] ?? 0;
    String accessLevel = employeeData['accessLevel'] ?? '';
    
    // Extract user data
    String firstName = '';
    String lastName = '';
    String email = '';
    String? gender;
    bool isActive = true;
    
    if (employeeData['user'] is Map) {
      Map<String, dynamic> userData = employeeData['user'];
      firstName = userData['firstName'] ?? '';
      lastName = userData['lastName'] ?? '';
      email = userData['email'] ?? '';
      gender = userData['gender'];
      // Assuming user is active unless specifically marked inactive
      isActive = userData['isActive'] ?? true;
    }

    return Employee(
      id: employeeData['id'] ?? 0,
      userId: userId,
      accessLevel: accessLevel,
      firstName: firstName,
      lastName: lastName,
      email: email,
      gender: gender,
      isActive: isActive,
      profileImageUrl: profileImageUrl,
    );
  }
} 