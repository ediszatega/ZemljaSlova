import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../models/voucher.dart';
import '../models/ticket_type.dart';
import '../models/event.dart';
import '../models/membership.dart';
import '../models/book_transaction.dart';
import 'api_service.dart';

class TransactionService {
  final ApiService _apiService;

  TransactionService({required ApiService apiService}) : _apiService = apiService;

  Future<Map<String, dynamic>> getMemberTransactions({
    required int page,
    required int pageSize,
    String? transactionType,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (transactionType != null && transactionType.isNotEmpty) {
        queryParams['transactionType'] = transactionType;
      }

      final response = await _apiService.get('Order/member-transactions', queryParams: queryParams);
      
      if (response != null) {
        return response;
      }
      
      throw Exception('Failed to load transactions');
    } catch (e) {
      throw Exception('Failed to get member transactions: $e');
    }
  }

  Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    try {
      final response = await _apiService.get('Order/order-items/$orderId');
      
      if (response != null && response is List) {
        return response.map((itemJson) => _mapOrderItemFromBackend(itemJson)).toList();
      }
      
      throw Exception('Failed to load order items');
    } catch (e) {
      throw Exception('Failed to get order items: $e');
    }
  }

  Future<List<BookTransaction>> getMemberRentalTransactions(int memberId) async {
    try {
      final response = await _apiService.get('BookTransaction/member/$memberId/rental-transactions');
      
      if (response != null && response is List) {
        final transactions = response.map((json) => BookTransaction.fromJson(json)).toList();
        debugPrint('[TransactionService] Parsed ${transactions.length} rental transactions');
        return transactions;
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to get member rental transactions: $e');
    }
  }

  List<Order> mapOrdersFromResponse(dynamic response) {
    final resultList = (response['resultList'] as List)
        .map((orderJson) => _mapOrderFromBackend(orderJson))
        .toList();
    return resultList;
  }

  int getTotalCount(dynamic response) {
    return response['count'] ?? 0;
  }

  Order _mapOrderFromBackend(dynamic orderData) {
    final orderItems = (orderData['orderItems'] as List?)
        ?.map((itemJson) => _mapOrderItemFromBackend(itemJson))
        .toList() ?? [];

    return Order(
      id: orderData['id'],
      memberId: orderData['memberId'],
      discountId: orderData['discountId'],
      purchasedAt: DateTime.parse(orderData['purchasedAt']),
      amount: (orderData['amount'] as num).toDouble(),
      voucherId: orderData['voucherId'],
      paymentIntentId: orderData['paymentIntentId'],
      paymentStatus: orderData['paymentStatus'],
      shippingAddress: orderData['shippingAddress'],
      shippingCity: orderData['shippingCity'],
      shippingPostalCode: orderData['shippingPostalCode'],
      shippingCountry: orderData['shippingCountry'],
      shippingPhoneNumber: orderData['shippingPhoneNumber'],
      shippingEmail: orderData['shippingEmail'],
      orderItems: orderItems,
    );
  }

  OrderItem _mapOrderItemFromBackend(dynamic itemData) {
    return OrderItem(
      id: itemData['id'],
      bookId: itemData['bookId'],
      ticketTypeId: itemData['ticketTypeId'],
      membershipId: itemData['membershipId'],
      quantity: itemData['quantity'],
      discountId: itemData['discountId'],
      orderId: itemData['orderId'],
      voucherId: itemData['voucherId'],
      book: itemData['book'] != null ? _mapBookFromBackend(itemData['book']) : null,
      voucher: itemData['voucher'] != null ? _mapVoucherFromBackend(itemData['voucher']) : null,
      ticketType: itemData['ticketType'] != null ? _mapTicketTypeFromBackend(itemData['ticketType']) : null,
      membership: itemData['membership'] != null ? _mapMembershipFromBackend(itemData['membership']) : null,
      pointsEarned: itemData['pointsEarned'],
    );
  }

  Book _mapBookFromBackend(dynamic bookData) {
    return Book(
      id: bookData['id'],
      title: bookData['title'] ?? '',
      price: (bookData['price'] as num?)?.toDouble() ?? 0.0,
      coverImageUrl: bookData['coverImageUrl'],
      isAvailable: bookData['isAvailable'] ?? true,
      quantityInStock: bookData['quantityInStock'] ?? 0,
      quantitySold: bookData['quantitySold'] ?? 0,
      description: bookData['description'] ?? '',
      dateOfPublish: bookData['dateOfPublish'],
      edition: bookData['edition'],
      publisher: bookData['publisher'],
      bookPurpose: bookData['bookPurpose'] != null ? BookPurpose.values.firstWhere(
        (e) => e.toString().split('.').last == bookData['bookPurpose'],
        orElse: () => BookPurpose.sell,
      ) : BookPurpose.sell,
      numberOfPages: bookData['numberOfPages'] ?? 0,
      weight: bookData['weight']?.toDouble(),
      dimensions: bookData['dimensions'],
      genre: bookData['genre'],
      binding: bookData['binding'],
      language: bookData['language'],
      authorIds: (bookData['authorIds'] as List<dynamic>?)?.cast<int>() ?? [],
      authors: bookData['authors'] != null ? (bookData['authors'] as List).map((a) => _mapAuthorFromBackend(a)).toList() : null,
    );
  }

  Author _mapAuthorFromBackend(dynamic authorData) {
    return Author(
      id: authorData['id'],
      firstName: authorData['firstName'] ?? '',
      lastName: authorData['lastName'] ?? '',
      dateOfBirth: authorData['dateOfBirth'],
      genre: authorData['genre'],
      biography: authorData['biography'],
    );
  }

  Voucher _mapVoucherFromBackend(dynamic voucherData) {
    return Voucher(
      id: voucherData['id'],
      value: (voucherData['value'] as num?)?.toDouble() ?? 0.0,
      code: voucherData['code'] ?? '',
      isUsed: voucherData['isUsed'] ?? false,
      expirationDate: voucherData['expirationDate'] != null 
          ? DateTime.parse(voucherData['expirationDate']) 
          : DateTime.now(),
      purchasedByMemberId: voucherData['purchasedByMemberId'],
      purchasedAt: voucherData['purchasedAt'] != null 
          ? DateTime.parse(voucherData['purchasedAt']) 
          : DateTime.now(),
    );
  }

  TicketType _mapTicketTypeFromBackend(dynamic ticketTypeData) {
    return TicketType(
      id: ticketTypeData['id'],
      eventId: ticketTypeData['eventId'],
      name: ticketTypeData['name'] ?? '',
      price: (ticketTypeData['price'] as num?)?.toDouble() ?? 0.0,
      description: ticketTypeData['description'] ?? '',
      initialQuantity: ticketTypeData['initialQuantity'],
      currentQuantity: ticketTypeData['currentQuantity'],
    );
  }

  Event _mapEventFromBackend(dynamic eventData) {
    return Event(
      id: eventData['id'],
      title: eventData['title'] ?? '',
      description: eventData['description'] ?? '',
      location: eventData['location'],
      startAt: eventData['startAt'] != null 
          ? DateTime.parse(eventData['startAt']) 
          : DateTime.now(),
      endAt: eventData['endAt'] != null 
          ? DateTime.parse(eventData['endAt']) 
          : DateTime.now(),
      organizer: eventData['organizer'],
      lecturers: eventData['lecturers'],
      coverImageUrl: eventData['coverImageUrl'],
      maxNumberOfPeople: eventData['maxNumberOfPeople'],
      ticketTypes: eventData['ticketTypes'] != null ? (eventData['ticketTypes'] as List).map((t) => _mapTicketTypeFromBackend(t)).toList() : null,
    );
  }

  Membership _mapMembershipFromBackend(dynamic membershipData) {
    return Membership(
      id: membershipData['id'],
      startDate: DateTime.parse(membershipData['startDate']),
      endDate: DateTime.parse(membershipData['endDate']),
      memberId: membershipData['memberId'],
    );
  }
}
