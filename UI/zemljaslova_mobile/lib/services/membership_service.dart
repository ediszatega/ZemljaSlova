import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/membership.dart';
import '../models/member.dart';
import 'api_service.dart';

class MembershipService {
  final ApiService _apiService;

  MembershipService({required ApiService apiService}) : _apiService = apiService;

  Future<Membership?> getActiveMembership(int memberId) async {
    try {
      final response = await _apiService.get('Membership/get_active_membership/$memberId');
      
      if (response != null) {
        return _mapMembershipFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to get active membership: $e');
      return null;
    }
  }

  Future<List<Membership>> getMemberMemberships(int memberId) async {
    try {
      final response = await _apiService.get('Membership/get_member_memberships/$memberId');
      
      if (response != null) {
        final List<dynamic> membershipsList = response;
        return membershipsList
            .map((membershipJson) => _mapMembershipFromBackend(membershipJson))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get member memberships: $e');
      return [];
    }
  }

  Future<Membership?> createMembershipByMember(int memberId) async {
    try {
      final data = {
        'memberId': memberId,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      };
      
      final response = await _apiService.post('Membership/create_membership_by_member', data);
      
      if (response != null) {
        return _mapMembershipFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to create membership: $e');
      throw Exception('Failed to create membership: $e');
    }
  }

  Membership _mapMembershipFromBackend(dynamic membershipData) {
    Member? member;
    
    if (membershipData['member'] != null) {
      final memberDataMap = membershipData['member'];
      final userData = memberDataMap['user'] as Map<String, dynamic>?;
      
      member = Member(
        id: memberDataMap['id'],
        firstName: userData?['firstName'] ?? '',
        lastName: userData?['lastName'] ?? '',
        email: userData?['email'] ?? '',
        dateOfBirth: DateTime.tryParse(memberDataMap['dateOfBirth'] ?? '') ?? DateTime.now(),
        joinedAt: DateTime.tryParse(memberDataMap['joinedAt'] ?? '') ?? DateTime.now(),
        gender: userData?['gender'],
        userId: memberDataMap['userId'],
        isActive: userData?['isActive'] ?? true,
      );
    }

    return Membership(
      id: membershipData['id'],
      startDate: DateTime.parse(membershipData['startDate']),
      endDate: DateTime.parse(membershipData['endDate']),
      memberId: membershipData['memberId'],
      member: member,
    );
  }
}
