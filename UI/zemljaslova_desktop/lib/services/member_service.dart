import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/member.dart';
import 'api_service.dart';

class MemberService {
  final ApiService _apiService;
  
  MemberService(this._apiService);
  
  Future<List<Member>> fetchMembers({bool isUserIncluded = true}) async {
    try {
      final response = await _apiService.get('Member?IsUserIncluded=$isUserIncluded');
      
      debugPrint('API response: $response');
      
      if (response != null) {
        final membersList = response['resultList'] as List;
        
        return membersList
            .map((memberJson) => _mapMemberFromBackend(memberJson))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to fetch members: $e');
      return [];
    }
  }
  
  Future<Member> getMemberById(int id) async {
    try {
      final response = await _apiService.get('Member/$id?IsUserIncluded=true');
      
      if (response != null) {
        return _mapMemberFromBackend(response);
      }
      
      throw Exception('Member not found');
    } catch (e) {
      debugPrint('Failed to get member: $e');
      throw Exception('Failed to get member: $e');
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
      // Assuming user is active unless specifically marked inactive
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