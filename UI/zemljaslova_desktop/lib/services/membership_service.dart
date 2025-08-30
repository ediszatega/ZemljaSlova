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
      return {
        'memberships': <Membership>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Membership> getMembershipById(int id) async {
    try {
      final response = await _apiService.get('Membership/$id');
      return _mapMembershipFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja članstva.');
    }
  }

  Future<Membership?> getActiveMembership(int memberId) async {
    try {
      final response = await _apiService.get('Membership/get_active_membership/$memberId');
      return _mapMembershipFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja aktivnog članstva.');
    }
  }

  Future<List<Membership>> getMemberMemberships(int memberId) async {
    try {
      final response = await _apiService.get('Membership/get_member_memberships/$memberId');

      final membershipsList = response as List;
      return membershipsList
          .map((membershipJson) => _mapMembershipFromBackend(membershipJson))
          .toList();
    } catch (e) {
      throw Exception('Greška prilikom dobijanja članstava člana.');
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
      
      return _mapMembershipFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom kreiranja članstva.');
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
      
      return _mapMembershipFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom kreiranja članstva.');
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
      throw Exception('Greška prilikom ažuriranja članstva.');
    }
  }

  Future<bool> deleteMembership(int id) async {
    try {
      final response = await _apiService.delete('Membership/$id');
      return response != null;
    } catch (e) {
      throw Exception('Greška prilikom brisanja članstva.');
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