
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
      return false;
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
      return null;
    }
  }
  
  Future<bool> addStock({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
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
      return false;
    }
  }
  
  Future<bool> sellItems({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
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
      return false;
    }
  }

  Future<bool> removeItems({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
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
      return false;
    }
  }

  Future<bool> rentItems({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
      return false;
    }
    
    try {
      final requestData = {
        'quantity': quantity,
        'userId': Authorization.userId,
        'data': data,
      };
      
      final endpoint = '$_baseEndpoint/$id/rent';
      
      final response = await _apiService.post(endpoint, requestData);
      
      return response != null && response is bool && response;
    } catch (e) {
      return false;
    }
  }

  Future<bool> returnItems({
    required int id,
    required int quantity,
    String? data,
  }) async {
    if (Authorization.userId == null) {
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
      return [];
    }
  }
} 