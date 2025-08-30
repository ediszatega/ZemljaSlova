import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/member.dart';
import 'api_service.dart';

class MemberService {
  final ApiService _apiService;
  
  MemberService(this._apiService);
  
  Future<Map<String, dynamic>> fetchMembers({
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
      final response = await _apiService.get('Member?$queryString');
      
      if (response != null) {
        final membersList = response['resultList'] as List;
        final totalCount = response['count'] as int;
        
        final members = membersList
            .map((memberJson) => _mapMemberFromBackend(memberJson))
            .toList();
            
        return {
          'members': members,
          'totalCount': totalCount,
        };
      }
      
      return {
        'members': <Member>[],
        'totalCount': 0,
      };
    } catch (e) {
      debugPrint('Failed to fetch members: $e');
      return {
        'members': <Member>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Member> getMemberById(int id) async {
    try {
      final response = await _apiService.get('Member/$id');      
      return _mapMemberFromBackend(response);
    } catch (e) {
      throw Exception('Član nije pronađen.');
    }
  }
  
  Future<Member?> createMember(
    String firstName,
    String lastName,
    String email,
    String password,
    DateTime dateOfBirth,
    String? gender,
  ) async {
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
      
      return _mapMemberFromBackend(response);
      
    } catch (e) {
      throw Exception('Greška prilikom kreiranja člana.');
    }
  }
  
  Future<Member?> updateMember(
    int id,
    String firstName,
    String lastName,
    String email,
    DateTime dateOfBirth,
    String? gender,
  ) async {
    try {
      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
      };
      
      final response = await _apiService.put('Member/UpdateMember/$id', data);
      
      return _mapMemberFromBackend(response);
      
    } catch (e) {
      throw Exception('Greška prilikom ažuriranja člana.');
    }
  }
  
  Future<void> deleteMember(int id) async {
    try {
      await _apiService.delete('Member/$id');
    } catch (e) {
      rethrow;
    }
  }
  
  Member _mapMemberFromBackend(dynamic memberData) {
    String? profileImageUrl;
    if (memberData['profileImage'] != null) {
      if (memberData['profileImage'] is List) {
        final bytes = List<int>.from(memberData['profileImage']);
        profileImageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      } else if (memberData['profileImage'] is String) {
        profileImageUrl = memberData['profileImage'];
      }
    }
    
    // Extract member specific data
    int userId = memberData['userId'] ?? 0;
    
    // Parse dates
    DateTime dateOfBirth = DateTime.now();
    if (memberData['dateOfBirth'] != null) {
      try {
        dateOfBirth = DateTime.parse(memberData['dateOfBirth']);
      } catch (e) {
        throw Exception('Greška prilikom parsiranja datuma rođenja.');
      }
    }
    
    DateTime joinedAt = DateTime.now();
    if (memberData['joinedAt'] != null) {
      try {
        joinedAt = DateTime.parse(memberData['joinedAt']);
      } catch (e) {
        throw Exception('Greška prilikom parsiranja datuma prijave.');
      }
    }
    
    // Extract user data
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
      profileImageUrl: profileImageUrl,
    );
  }
} 