import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/voucher.dart';
import '../models/member.dart';
import 'api_service.dart';

class VoucherService {
  final ApiService _apiService;
  
  VoucherService(this._apiService);
  
  Future<List<Voucher>> fetchVouchers({
    int? memberId,
    bool? isUsed,
    String? code,
    DateTime? expirationDateFrom,
    DateTime? expirationDateTo,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (memberId != null) {
        queryParams['MemberId'] = memberId.toString();
      }
      if (isUsed != null) {
        queryParams['IsUsed'] = isUsed.toString();
      }
      if (code != null && code.isNotEmpty) {
        queryParams['Code'] = code;
      }
      if (expirationDateFrom != null) {
        queryParams['ExpirationDateFrom'] = expirationDateFrom.toIso8601String();
      }
      if (expirationDateTo != null) {
        queryParams['ExpirationDateTo'] = expirationDateTo.toIso8601String();
      }
      
      String endpoint = 'Voucher';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint = '$endpoint?$queryString';
      }
      
      final response = await _apiService.get(endpoint);
      
      if (response != null) {
        final vouchersList = response['resultList'] as List;

        return vouchersList
            .map((voucherJson) => _mapVoucherFromBackend(voucherJson))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to fetch vouchers: $e');
      return [];
    }
  }
  
  Future<Voucher> getVoucherById(int id) async {
    try {
      final response = await _apiService.get('Voucher/$id');
      
      if (response != null) {
        return _mapVoucherFromBackend(response);
      }
      
      throw Exception('Voucher not found');
    } catch (e) {
      debugPrint('Failed to get voucher: $e');
      throw Exception('Failed to get voucher: $e');
    }
  }

  Future<Voucher?> getVoucherByCode(String code) async {
    try {
      final response = await _apiService.get('Voucher/GetVoucherByCode/$code');
      
      if (response != null) {
        return _mapVoucherFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to get voucher by code: $e');
      return null;
    }
  }

  Future<Voucher?> createAdminVoucher({
    required double value,
    required DateTime expirationDate,
    String? code,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'value': value,
        'expirationDate': expirationDate.toIso8601String(),
        'code': code,
      };
      
      final response = await _apiService.post('Voucher/CreateAdminVoucher', data);
      
      if (response != null) {
        return _mapVoucherFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to create admin voucher: $e');
      return null;
    }
  }

  Future<bool> deleteVoucher(int id) async {
    try {
      final response = await _apiService.delete('Voucher/$id');
      return response != null;
    } catch (e) {
      debugPrint('Failed to delete voucher: $e');
      return false;
    }
  }

  Voucher _mapVoucherFromBackend(dynamic voucherData) {
    Member? purchasedByMember;
    
    if (voucherData['purchasedByMember'] != null) {
      final memberData = voucherData['purchasedByMember'];
      final userData = memberData['user'] as Map<String, dynamic>?;
      
      purchasedByMember = Member(
        id: memberData['id'],
        firstName: userData?['firstName'] ?? '',
        lastName: userData?['lastName'] ?? '',
        email: userData?['email'] ?? '',
        dateOfBirth: DateTime.tryParse(memberData['dateOfBirth'] ?? '') ?? DateTime.now(),
        joinedAt: DateTime.tryParse(memberData['joinedAt'] ?? '') ?? DateTime.now(),
        gender: userData?['gender'],
        userId: memberData['userId'],
        isActive: userData?['isActive'] ?? true,
      );
    }

    return Voucher(
      id: voucherData['id'],
      value: (voucherData['value'] as num).toDouble(),
      code: voucherData['code'] ?? '',
      isUsed: voucherData['isUsed'] ?? false,
      expirationDate: DateTime.parse(voucherData['expirationDate']),
      purchasedByMemberId: voucherData['purchasedByMemberId'],
      purchasedAt: voucherData['purchasedAt'] != null 
          ? DateTime.parse(voucherData['purchasedAt'])
          : null,
      purchasedByMember: purchasedByMember,
    );
  }
} 