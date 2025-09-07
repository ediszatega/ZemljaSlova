import 'package:flutter/foundation.dart';
import '../models/voucher.dart';
import 'api_service.dart';

class VoucherService {
  final ApiService _apiService;
  
  VoucherService(this._apiService);
  
  Future<Voucher?> getVoucherByCode(String code) async {
    try {
      final response = await _apiService.get('Voucher/GetVoucherByCode/$code');
      
      return Voucher.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<bool> validateVoucherCode(String code) async {
    try {
      final voucher = await getVoucherByCode(code);
      
      if (voucher == null) {
        return false;
      }
      
      // Check if voucher is valid (not used and not expired)
      final now = DateTime.now();
      return !voucher.isUsed && voucher.expirationDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  Future<bool> markVoucherAsUsed(int voucherId) async {
    try {
      await _apiService.put('Voucher/$voucherId/mark-used', {});
      return true;
    } catch (e) {
      return false;
    }
  }
}
