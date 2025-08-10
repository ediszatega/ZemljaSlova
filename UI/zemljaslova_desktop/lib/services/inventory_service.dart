import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../utils/authorization.dart';
import '../widgets/inventory_screen.dart';

class InventoryService<T extends InventoryTransaction> {
  final ApiService _apiService;
  final String _baseEndpoint;
  final T Function(Map<String, dynamic>) _fromJson;
  
  InventoryService(
    this._apiService,
    this._baseEndpoint,
    this._fromJson,
  );
  
  Future<int> getCurrentQuantity(int id) async {
    try {
      final response = await _apiService.get('$_baseEndpoint/$id/current-quantity');
      
      if (response != null && response is int) {
        return response;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Failed to get current quantity: $e');
      return 0;
    }
  }

  Future<int> getPhysicalStock(int id) async {
    try {
      final response = await _apiService.get('$_baseEndpoint/$id/physical-stock');
      
      if (response != null && response is int) {
        return response;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Failed to get physical stock: $e');
      return 0;
    }
  }

  Future<int> getCurrentlyRented(int id) async {
    try {
      final response = await _apiService.get('$_baseEndpoint/$id/currently-rented');
      
      if (response != null && response is int) {
        return response;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Failed to get currently rented quantity: $e');
      return 0;
    }
  }
  
  Future<bool> isAvailableForPurchase(int id, int quantity) async {
    try {
      final response = await _apiService.get('$_baseEndpoint/$id/available?quantity=$quantity');
      
      if (response != null && response is bool) {
        return response;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to check availability: $e');
      return false;
    }
  }

  Future<bool> isAvailableForRental(int id, int quantity) async {
    try {
      final response = await _apiService.get('$_baseEndpoint/$id/available-for-rental?quantity=$quantity');
      
      if (response != null && response is bool) {
        return response;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to check rental availability: $e');
      return false;
    }
  }
  
  Future<bool> addStock({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
      debugPrint('User not logged in. Cannot add stock.');
      return false;
    }
    
    try {
      final requestData = {
        'quantity': quantity,
        'userId': Authorization.userId,
        'data': data,
      };
      
      final response = await _apiService.post('$_baseEndpoint/$id/add-stock', requestData);
      
      return response != null && response is bool && response;
    } catch (e) {
      debugPrint('Failed to add stock: $e');
      return false;
    }
  }
  
  Future<bool> sellItems({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
      debugPrint('User not logged in. Cannot sell items.');
      return false;
    }
    
    try {
      final requestData = {
        'quantity': quantity,
        'userId': Authorization.userId,
        'data': data,
      };
      
      final response = await _apiService.post('$_baseEndpoint/$id/sell', requestData);
      
      return response != null && response is bool && response;
    } catch (e) {
      debugPrint('Failed to sell items: $e');
      return false;
    }
  }

  Future<bool> removeItems({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
      debugPrint('User not logged in. Cannot remove items.');
      return false;
    }
    
    try {
      final requestData = {
        'quantity': quantity,
        'userId': Authorization.userId,
        'data': data,
      };
      
      final response = await _apiService.post('$_baseEndpoint/$id/remove', requestData);
      
      return response != null && response is bool && response;
    } catch (e) {
      debugPrint('Failed to remove items: $e');
      return false;
    }
  }

  Future<bool> rentItems({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
      debugPrint('User not logged in. Cannot rent items.');
      return false;
    }
    
    try {
      final requestData = {
        'quantity': quantity,
        'userId': Authorization.userId,
        'data': data,
      };
      
      final endpoint = '$_baseEndpoint/$id/rent';
      debugPrint('Calling rental endpoint: $endpoint');
      debugPrint('Request data: $requestData');
      
      final response = await _apiService.post(endpoint, requestData);
      
      debugPrint('Rental response: $response');
      return response != null && response is bool && response;
    } catch (e) {
      debugPrint('Failed to rent items: $e');
      return false;
    }
  }

  Future<bool> returnItems({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
      debugPrint('User not logged in. Cannot return items.');
      return false;
    }
    
    try {
      final requestData = {
        'quantity': quantity,
        'userId': Authorization.userId,
        'data': data,
      };
      
      final response = await _apiService.post('$_baseEndpoint/$id/return', requestData);
      
      return response != null && response is bool && response;
    } catch (e) {
      debugPrint('Failed to return items: $e');
      return false;
    }
  }
  
  Future<List<T>> getTransactionsById(int id) async {
    try {
      final response = await _apiService.get('$_baseEndpoint/$id/transactions');
      
      if (response != null && response is List) {
        return response.map((json) => _fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get transactions: $e');
      return [];
    }
  }

  Future<List<T>> getActiveRentals() async {
    try {
      final response = await _apiService.get('${_baseEndpoint.split('/').first}/active-rentals');
      
      if (response != null && response is List) {
        return response.map((json) => _fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get active rentals: $e');
      return [];
    }
  }
} 