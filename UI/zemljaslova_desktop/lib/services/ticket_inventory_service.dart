import 'package:flutter/foundation.dart';
import '../models/ticket_type_transaction.dart';
import '../services/api_service.dart';
import '../utils/authorization.dart';

class TicketInventoryService {
  final ApiService _apiService;
  
  TicketInventoryService(this._apiService);
  
  Future<int> getCurrentQuantity(int ticketTypeId) async {
    try {
      final response = await _apiService.get('TicketTypeTransaction/ticket-type/$ticketTypeId/current-quantity');
      
      if (response != null && response is int) {
        return response;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Failed to get current quantity: $e');
      return 0;
    }
  }
  
  Future<bool> isAvailableForPurchase(int ticketTypeId, int quantity) async {
    try {
      final response = await _apiService.get('TicketTypeTransaction/ticket-type/$ticketTypeId/available?quantity=$quantity');
      
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
    required int ticketTypeId,
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
      
      final response = await _apiService.post('TicketTypeTransaction/ticket-type/$ticketTypeId/add-stock', requestData);
      
      return response != null && response is bool && response;
    } catch (e) {
      debugPrint('Failed to add stock: $e');
      return false;
    }
  }
  
  Future<bool> sellTickets({
    required int ticketTypeId,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
      debugPrint('User not logged in. Cannot sell tickets.');
      return false;
    }
    
    try {
      final requestData = {
        'quantity': quantity,
        'userId': Authorization.userId,
        'data': data,
      };
      
      final response = await _apiService.post('TicketTypeTransaction/ticket-type/$ticketTypeId/sell', requestData);
      
      return response != null && response is bool && response;
    } catch (e) {
      debugPrint('Failed to sell tickets: $e');
      return false;
    }
  }
  
  Future<List<TicketTypeTransaction>> getTransactionsByTicketType(int ticketTypeId) async {
    try {
      final response = await _apiService.get('TicketTypeTransaction/ticket-type/$ticketTypeId/transactions');
      
      if (response != null && response is List) {
        return response.map((json) => TicketTypeTransaction.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get transactions: $e');
      return [];
    }
  }
  
  Future<bool> purchaseTickets({
    required int ticketTypeId,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
      debugPrint('User not logged in. Cannot purchase tickets.');
      return false;
    }
    
    try {
      final requestData = {
        'ticketTypeId': ticketTypeId,
        'quantity': quantity,
        'userId': Authorization.userId,
        'data': data,
      };
      
      final response = await _apiService.post('Event/PurchaseTickets', requestData);
      
      return response != null && response is Map && response['success'] == true;
    } catch (e) {
      debugPrint('Failed to purchase tickets: $e');
      return false;
    }
  }
} 