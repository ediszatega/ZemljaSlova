import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/membership.dart';
import '../models/member.dart';
import 'api_service.dart';

class MembershipService {
  final ApiService _apiService;
  
  MembershipService(this._apiService);
  
  Future<Map<String, dynamic>> fetchMemberships({
    Map<String, dynamic>? filters,
    bool includeMember = true,
    int? page,
    int? pageSize,
    String? name,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            if (value is DateTime) {
              queryParams[key] = value.toIso8601String();
            } else {
              queryParams[key] = value.toString();
            }
          }
        });
      }
      if (includeMember) {
        queryParams['IncludeMember'] = 'true';
      }
      if (page != null) {
        queryParams['Page'] = page.toString();
      }
      if (pageSize != null) {
        queryParams['PageSize'] = pageSize.toString();
      }
      if (name != null && name.isNotEmpty) {
        queryParams['Name'] = name;
      }
      
      String endpoint = 'Membership';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint = '$endpoint?$queryString';
      }
      
      final response = await _apiService.get(endpoint);
      
      if (response != null) {
        final membershipsList = response['resultList'] as List;
        final totalCount = response['count'] as int;

        final memberships = membershipsList
            .map((membershipJson) => _mapMembershipFromBackend(membershipJson))
            .toList();
            
        return {
          'memberships': memberships,
          'totalCount': totalCount,
        };
      }
      
      return {
        'memberships': <Membership>[],
        'totalCount': 0,
      };
    } catch (e) {
      debugPrint('Failed to fetch memberships: $e');
      return {
        'memberships': <Membership>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Membership> getMembershipById(int id) async {
    try {
      final response = await _apiService.get('Membership/$id');
      
      if (response != null) {
        return _mapMembershipFromBackend(response);
      }
      
      throw Exception('Membership not found');
    } catch (e) {
      debugPrint('Failed to get membership: $e');
      throw Exception('Failed to get membership: $e');
    }
  }

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
        final membershipsList = response as List;
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

  Future<Membership?> createMembershipByAdmin({
    required int memberId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'memberId': memberId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
      
      final response = await _apiService.post('Membership/create_membership_by_admin', data);
      
      if (response != null) {
        return _mapMembershipFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to create admin membership: $e');
      return null;
    }
  }

  Future<Membership?> createMembershipByMember({
    required int memberId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'memberId': memberId,
      };
      
      final response = await _apiService.post('Membership/create_membership_by_member', data);
      
      if (response != null) {
        return _mapMembershipFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to create member membership: $e');
      return null;
    }
  }

  Future<bool> updateMembership(int id, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
      
      final response = await _apiService.put('Membership/$id', data);
      return response != null;
    } catch (e) {
      debugPrint('Failed to update membership: $e');
      return false;
    }
  }

  Future<bool> deleteMembership(int id) async {
    try {
      final response = await _apiService.delete('Membership/$id');
      return response != null;
    } catch (e) {
      return false;
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