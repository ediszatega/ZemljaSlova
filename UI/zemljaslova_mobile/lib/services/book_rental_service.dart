import 'package:flutter/foundation.dart';
import '../models/book_transaction.dart';
import '../services/api_service.dart';

class BookRentalService {
  final ApiService _apiService;
  
  BookRentalService(this._apiService);
  
  Future<List<BookTransaction>> getActiveRentals(int bookId) async {
    try {
      final response = await _apiService.get('BookTransaction/book/$bookId/transactions');
      
      if (response != null && response is List) {
        return response.map<BookTransaction>((json) => BookTransaction.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get active rentals: $e');
      return [];
    }
  }
  
  Future<bool> isAvailableForRental(int bookId, int quantity) async {
    try {
      final response = await _apiService.get('BookTransaction/book/$bookId/available-for-rental?quantity=$quantity');
      
      if (response != null && response is bool) {
        return response;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<int> getCurrentlyRented(int bookId) async {
    try {
      final response = await _apiService.get('BookTransaction/book/$bookId/currently-rented');
      
      if (response != null && response is int) {
        return response;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Failed to get currently rented quantity: $e');
      return 0;
    }
  }
  
  Future<int> getPhysicalStock(int bookId) async {
    try {
      final response = await _apiService.get('BookTransaction/book/$bookId/physical-stock');
      
      if (response != null && response is int) {
        return response;
      }
      
      return 0;
    } catch (e) {
      debugPrint('Failed to get physical stock: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>?> reserveBook({required int memberId, required int bookId}) async {
    try {
      final payload = {
        'memberId': memberId,
        'bookId': bookId,
      };
      final response = await _apiService.post('BookReservation/reserve', payload);
      if (response != null && response is Map<String, dynamic>) {
        return response;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to reserve book: $e');
      return null;
    }
  }

  Future<int?> getReservationPosition(int reservationId) async {
    try {
      final response = await _apiService.get('BookReservation/$reservationId/position');
      if (response != null && response is int) {
        return response;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get reservation position: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getBookQueue(int bookId) async {
    try {
      final response = await _apiService.get('BookReservation/book/$bookId/queue');
      
      if (response != null && response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      debugPrint('Failed to get book queue: $e');
      return [];
    }
  }

  Future<bool> cancelReservation(int reservationId, int memberId) async {
    try {
      final response = await _apiService.delete('BookReservation/$reservationId/cancel/$memberId');
      
      if (response != null && response is bool) {
        return response;
      }
      
      return false;
    } catch (e) {
      debugPrint('Failed to cancel reservation: $e');
      return false;
    }
  }
}
