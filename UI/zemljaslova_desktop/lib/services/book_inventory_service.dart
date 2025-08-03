import 'package:flutter/foundation.dart';
import '../models/book_transaction.dart';
import '../services/api_service.dart';
import '../utils/authorization.dart';

class BookInventoryService {
  final ApiService _apiService;
  
  BookInventoryService(this._apiService);
  
  Future<int> getCurrentQuantity(int bookId) async {
    try {
      final response = await _apiService.get('BookTransaction/book/$bookId/current-quantity');
      
      if (response != null && response is int) {
        return response;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Failed to get current quantity: $e');
      return 0;
    }
  }
  
  Future<bool> isAvailableForPurchase(int bookId, int quantity) async {
    try {
      final response = await _apiService.get('BookTransaction/book/$bookId/available?quantity=$quantity');
      
      if (response != null && response is bool) {
        return response;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to check availability: $e');
      return false;
    }
  }
  
  Future<bool> addStock({
    required int bookId,
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
      
      final response = await _apiService.post('BookTransaction/book/$bookId/add-stock', requestData);
      
      return response != null && response is bool && response;
    } catch (e) {
      debugPrint('Failed to add stock: $e');
      return false;
    }
  }
  
  Future<bool> sellBooks({
    required int bookId,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
      debugPrint('User not logged in. Cannot sell books.');
      return false;
    }
    
    try {
      final requestData = {
        'quantity': quantity,
        'userId': Authorization.userId,
        'data': data,
      };
      
      final response = await _apiService.post('BookTransaction/book/$bookId/sell', requestData);
      
      return response != null && response is bool && response;
    } catch (e) {
      debugPrint('Failed to sell books: $e');
      return false;
    }
  }
  
  Future<List<BookTransaction>> getTransactionsByBook(int bookId) async {
    try {
      final response = await _apiService.get('BookTransaction/book/$bookId/transactions');
      
      if (response != null && response is List) {
        return response.map((json) => BookTransaction.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get transactions: $e');
      return [];
    }
  }
} 