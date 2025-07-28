import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/discount.dart';
import 'api_service.dart';

class DiscountService {
  final ApiService _apiService;
  
  DiscountService(this._apiService);
  
  Future<Map<String, dynamic>> fetchDiscounts({
    Map<String, dynamic>? filters,
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
      
      if (page != null) {
        queryParams['Page'] = page.toString();
      }
      if (pageSize != null) {
        queryParams['PageSize'] = pageSize.toString();
      }
      if (name != null && name.isNotEmpty) {
        queryParams['Name'] = name;
      }
      
      String endpoint = 'Discount';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint = '$endpoint?$queryString';
      }
      
      final response = await _apiService.get(endpoint);
      
      if (response != null) {
        final discountsList = response['resultList'] as List;
        final totalCount = response['count'] as int;

        final discounts = discountsList
            .map((discountJson) => _mapDiscountFromBackend(discountJson))
            .toList();
            
        return {
          'discounts': discounts,
          'totalCount': totalCount,
        };
      }
      
      return {
        'discounts': <Discount>[],
        'totalCount': 0,
      };
    } catch (e) {
      debugPrint('Failed to fetch discounts: $e');
      return {
        'discounts': <Discount>[],
        'totalCount': 0,
      };
    }
  }
  
  Future<Discount> getDiscountById(int id) async {
    try {
      final response = await _apiService.get('Discount/$id');
      
      if (response != null) {
        return _mapDiscountFromBackend(response);
      }
      
      throw Exception('Discount not found');
    } catch (e) {
      debugPrint('Failed to get discount: $e');
      throw Exception('Failed to get discount: $e');
    }
  }

  Future<Discount?> getDiscountByCode(String code) async {
    try {
      final response = await _apiService.get('Discount/get_discount_by_code/$code');
      
      if (response != null) {
        return _mapDiscountFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to get discount by code: $e');
      return null;
    }
  }

  Future<Discount?> createDiscount({
    required double discountPercentage,
    required DateTime startDate,
    required DateTime endDate,
    String? code,
    required String name,
    String? description,
    required int scope,
    int? maxUsage,
    List<int>? bookIds,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'discountPercentage': discountPercentage,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'code': code,
        'name': name,
        'description': description,
        'scope': scope,
        'maxUsage': maxUsage,
        'bookIds': bookIds,
      };
      
      final response = await _apiService.post('Discount', data);
      
      if (response != null) {
        return _mapDiscountFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to create discount: $e');
      return null;
    }
  }

  Future<Discount?> updateDiscount({
    required int id,
    double? discountPercentage,
    DateTime? startDate,
    DateTime? endDate,
    String? code,
    String? name,
    String? description,
    int? scope,
    int? maxUsage,
    bool? isActive,
    List<int>? bookIds,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      
      // Only include non-null values for partial updates
      if (discountPercentage != null) data['discountPercentage'] = discountPercentage;
      if (startDate != null) data['startDate'] = startDate.toIso8601String();
      if (endDate != null) data['endDate'] = endDate.toIso8601String();
      if (code != null) data['code'] = code;
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (scope != null) data['scope'] = scope;
      if (maxUsage != null) data['maxUsage'] = maxUsage;
      if (isActive != null) data['isActive'] = isActive;
      if (bookIds != null) data['bookIds'] = bookIds;
    
      final response = await _apiService.put('Discount/$id', data);
      
      if (response != null) {
        return _mapDiscountFromBackend(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Failed to update discount: $e');
      return null;
    }
  }

  Future<bool> deleteDiscount(int id) async {
    try {
      final response = await _apiService.delete('Discount/$id');
      return response != null;
    } catch (e) {
      debugPrint('Failed to delete discount: $e');
      return false;
    }
  }

  Future<int> cleanupExpiredDiscounts() async {
    try {
      final response = await _apiService.post('Discount/cleanup_expired_discounts', {});
      
      if (response != null && response is String) {
        // Extract number from response like "Successfully removed expired discounts from 5 books."
        final match = RegExp(r'(\d+)').firstMatch(response);
        if (match != null) {
          return int.parse(match.group(1)!);
        }
      }
      
      return 0;
    } catch (e) {
      debugPrint('Failed to cleanup expired discounts: $e');
      return 0;
    }
  }

  Future<List<Discount>> getExpiredDiscounts() async {
    try {
      final response = await _apiService.get('Discount/get_expired_discounts');
      
      if (response != null) {
        final discountsList = response as List;
        return discountsList
            .map((discountJson) => _mapDiscountFromBackend(discountJson))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get expired discounts: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBooksWithDiscount(int discountId) async {
    try {
      final response = await _apiService.get('Discount/get_books_with_discount/$discountId');
      
      if (response != null) {
        final booksList = response as List;
        return booksList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get books with discount: $e');
      return [];
    }
  }

  Discount _mapDiscountFromBackend(dynamic discountData) {
    return Discount(
      id: discountData['id'],
      discountPercentage: (discountData['discountPercentage'] as num).toDouble(),
      startDate: DateTime.parse(discountData['startDate']),
      endDate: DateTime.parse(discountData['endDate']),
      code: discountData['code'],
      name: discountData['name'] ?? '',
      description: discountData['description'],
      scope: discountData['scope'] ?? 1,
      usageCount: discountData['usageCount'] ?? 0,
      maxUsage: discountData['maxUsage'],
      isActive: discountData['isActive'] ?? true,
    );
  }
} 