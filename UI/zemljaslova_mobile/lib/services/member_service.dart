import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/member.dart';
import 'api_service.dart';

class MemberService {
  final ApiService _apiService;

  MemberService({required ApiService apiService}) : _apiService = apiService;

  Future<Member?> createMember({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required DateTime dateOfBirth,
    String? gender,
  }) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'joinedAt': DateTime.now().toIso8601String(),
        'gender': gender,
      };
      
      final response = await _apiService.post('Member/CreateMember', data);
      
      if (response != null) {
        return _mapMemberFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to create member: $e');
      throw Exception('Failed to create member: $e');
    }
  }

  Future<Member?> getMember(int id) async {
    try {
      final response = await _apiService.get('Member/$id');
      
      if (response != null) {
        return _mapMemberFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to get member: $e');
      throw Exception('Failed to get member: $e');
    }
  }

  Future<Member?> getMemberByUserId(int userId) async {
    try {
      final response = await _apiService.get('Member/GetMemberByUserId/$userId');
      
      if (response != null) {
        return _mapMemberFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to get member by user ID: $e');
      throw Exception('Failed to get member by user ID: $e');
    }
  }

  Future<Member?> updateMember({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    String? gender,
  }) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
      };
      
      final response = await _apiService.put('Member/UpdateMember/$id', data);
      
      if (response != null) {
        return _mapMemberFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to update member: $e');
      throw Exception('Failed to update member: $e');
    }
  }

  Member _mapMemberFromBackend(dynamic memberData) {
    // Extract member specific data
    int userId = memberData['userId'] ?? 0;
    
    // Parse dates
    DateTime dateOfBirth = DateTime.now();
    if (memberData['dateOfBirth'] != null) {
      try {
        dateOfBirth = DateTime.parse(memberData['dateOfBirth']);
      } catch (e) {
        debugPrint('Error parsing dateOfBirth: $e');
      }
    }
    
    DateTime joinedAt = DateTime.now();
    if (memberData['joinedAt'] != null) {
      try {
        joinedAt = DateTime.parse(memberData['joinedAt']);
      } catch (e) {
        debugPrint('Error parsing joinedAt: $e');
      }
    }
    
    // Extract user data from nested user object
    String firstName = '';
    String lastName = '';
    String email = '';
    String? gender;
    bool isActive = true;
    
    if (memberData['user'] is Map) {
      Map<String, dynamic> userData = memberData['user'];
      firstName = userData['firstName'] ?? '';
      lastName = userData['lastName'] ?? '';
      email = userData['email'] ?? '';
      gender = userData['gender'];
      isActive = userData['isActive'] ?? true;
    }

    return Member(
      id: memberData['id'] ?? 0,
      userId: userId,
      dateOfBirth: dateOfBirth,
      joinedAt: joinedAt,
      firstName: firstName,
      lastName: lastName,
      email: email,
      gender: gender,
      isActive: isActive,
      profileImageUrl: null, // Not included in backend response
    );
  }
} 