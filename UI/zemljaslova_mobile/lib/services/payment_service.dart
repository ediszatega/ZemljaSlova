import 'dart:convert';
import '../models/payment_intent.dart';
import '../models/shipping_address.dart';
import '../models/cart_item.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  /// Extract numeric ID from cart item ID string
  /// Examples: "voucher_25_1755366554536596" -> 25, "book_10" -> 10, "123" -> 123
  int _extractId(String id) {
    // If already a number, parse it directly
    if (RegExp(r'^\d+$').hasMatch(id)) {
      return int.parse(id);
    }
    
    // Extract the first number from patterns like
    final match = RegExp(r'_(\d+)').firstMatch(id);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    
    // Fallback to extract any number from the string
    final numberMatch = RegExp(r'\d+').firstMatch(id);
    if (numberMatch != null) {
      return int.parse(numberMatch.group(0)!);
    }
    
    throw FormatException('Could not extract ID from: $id');
  }

  Future<PaymentIntentResponse> createPaymentIntent(double amount) async {
    try {
      final response = await _apiService.post('Order/create-payment-intent', {
        'amount': amount,
        'currency': 'bam',
      });

      return PaymentIntentResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  Future<Map<String, dynamic>> processOrder({
    required List<CartItem> items,
    required ShippingAddress shippingAddress,
    required String paymentIntentId,
    required String paymentMethodId,
    int? appliedVoucherId,
    double? discountAmount,
  }) async {
    try {
      // Convert cart items to order items
      final orderItems = items.map((item) => {
        'bookId': item.type == CartItemType.book ? _extractId(item.id) : null,
        'ticketTypeId': item.type == CartItemType.ticket ? _extractId(item.id) : null,
        'membershipId': item.type == CartItemType.membership ? _extractId(item.id) : null,
        'voucherId': item.type == CartItemType.voucher ? _extractId(item.id) : null,
        'quantity': item.quantity,
        'discountId': null, // No discount for now
      }).toList();

      final totalAmount = items.fold<double>(
        0.0, 
        (sum, item) => sum + (item.price * item.quantity)
      );

      int? memberId;
      try {
        final memberResponse = await _apiService.get('Member/current');
        memberId = memberResponse['id'];
      } catch (e) {
        throw Exception('Failed to get user information');
      }

      // Create order request
      final orderRequest = {
        'memberId': memberId,
        'discountId': null,
        'amount': totalAmount,
        'appliedVoucherId': appliedVoucherId,
        'discountAmount': discountAmount,
        'paymentIntentId': paymentIntentId,
        'paymentStatus': 'pending',
        'paymentMethodId': paymentMethodId,
        'shippingAddress': shippingAddress.addressLine1,
        'shippingCity': shippingAddress.city,
        'shippingPostalCode': shippingAddress.postalCode,
        'shippingCountry': shippingAddress.country,
        'shippingPhoneNumber': shippingAddress.phoneNumber,
        'shippingEmail': shippingAddress.email,
      };

      final request = {
        'order': orderRequest,
        'orderItems': orderItems,
      };

      final response = await _apiService.post('Order/process-order', request);
      return response;
    } catch (e) {
      throw Exception('Failed to process order: $e');
    }
  }

  Future<Map<String, dynamic>> processMembershipPayment({
    required int memberId,
    required String paymentIntentId,
    required String paymentMethodId,
  }) async {
    try {
      // Create order request for membership
      final orderRequest = {
        'memberId': memberId,
        'discountId': null,
        'amount': 15.00,
        'paymentIntentId': paymentIntentId,
        'paymentStatus': 'pending',
        'paymentMethodId': paymentMethodId,
        'shippingAddress': null,
        'shippingCity': null,
        'shippingPostalCode': null,
        'shippingCountry': null,
        'shippingPhoneNumber': null,
        'shippingEmail': null,
      };

      // Create order item for membership
      final orderItems = [{
        'bookId': null,
        'ticketTypeId': null,
        'membershipId': null, // Will be created in the backend
        'voucherId': null,
        'quantity': 1,
        'discountId': null,
      }];

      final request = {
        'order': orderRequest,
        'orderItems': orderItems,
      };

      final response = await _apiService.post('Order/process-order', request);
      return response;
    } catch (e) {
      throw Exception('Failed to process membership payment: $e');
    }
  }
}
