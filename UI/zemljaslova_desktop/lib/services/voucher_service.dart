import 'package:flutter/foundation.dart';
import '../models/voucher.dart';
import '../models/member.dart';
import 'api_service.dart';

class VoucherService {
  final ApiService _apiService;
  
  VoucherService(this._apiService);
  
  Future<Map<String, dynamic>> fetchVouchers({
    int? memberId,
    bool? isUsed,
    String? code,
    DateTime? expirationDateFrom,
    DateTime? expirationDateTo,
    int? page,
    int? pageSize,
    String? name,
    Map<String, dynamic>? filters,
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
      if (page != null) {
        queryParams['Page'] = page.toString();
      }
      if (pageSize != null) {
        queryParams['PageSize'] = pageSize.toString();
      }
      if (name != null && name.isNotEmpty) {
        queryParams['Name'] = name;
      }
      
      if (filters != null) {
        for (final entry in filters.entries) {
          if (entry.value != null) {
            queryParams[entry.key] = entry.value.toString();
          }
        }
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
        final totalCount = response['count'] as int;

        final vouchers = vouchersList
            .map((voucherJson) => _mapVoucherFromBackend(voucherJson))
            .toList();
            
        return {
          'vouchers': vouchers,
          'totalCount': totalCount,
        };
      }
      
      return {
        'vouchers': <Voucher>[],
        'totalCount': 0,
      };
    } catch (e) {
      debugPrint('Failed to fetch vouchers: $e');
      return {
        'vouchers': <Voucher>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Voucher> getVoucherById(int id) async {
    try {
      final response = await _apiService.get('Voucher/$id');

      return _mapVoucherFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja vouchera.');
    }
  }

  Future<Voucher?> getVoucherByCode(String code) async {
    try {
      final response = await _apiService.get('Voucher/GetVoucherByCode/$code');
      
      return _mapVoucherFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom dobijanja vouchera po kodu.');
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
      
      return _mapVoucherFromBackend(response);
    } catch (e) {
      throw Exception('Greška prilikom kreiranja vouchera.');
    }
  }

  Future<bool> deleteVoucher(int id) async {
    try {
      final response = await _apiService.delete('Voucher/$id');
      return response;
    } catch (e) {
      throw Exception('Greška prilikom brisanja vouchera.');
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