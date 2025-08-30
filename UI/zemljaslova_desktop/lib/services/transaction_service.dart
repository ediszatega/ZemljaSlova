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
    int? memberId,
  }) async {
    try {
      dynamic response;
      
      response = await _apiService.get('Order');
      
      if (response == null || response['resultList'] == null || (response['resultList'] as List).isEmpty) {
        final queryParams = <String, String>{
          'page': '1',
          'pageSize': '1000',
        };

        final queryString = queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
        
        final endpoint = 'Order${queryString.isNotEmpty ? '?$queryString' : ''}';

        response = await _apiService.get(endpoint);
      }
      
      if (response != null) {
        List<dynamic> allOrders = response['resultList'] ?? [];
        
        if (memberId != null) {
          allOrders = allOrders.where((order) => order['memberId'] == memberId).toList();
        }
        
        if (transactionType != null && transactionType.isNotEmpty) {          
          List<dynamic> filteredOrders = [];
          
          for (final order in allOrders) {
            try {
              final orderItemsResponse = await _apiService.get('Order/order-items/${order['id']}');
              final orderItems = orderItemsResponse as List? ?? [];
              
              
              bool shouldInclude = false;
              switch (transactionType.toLowerCase()) {
                case 'vouchers':
                  shouldInclude = orderItems.any((item) => item['voucherId'] != null);
                  break;
                case 'books':
                  shouldInclude = orderItems.any((item) => item['bookId'] != null);
                  break;
                case 'tickets':
                  shouldInclude = orderItems.any((item) => item['ticketTypeId'] != null);
                  break;
                case 'memberships':
                  shouldInclude = orderItems.any((item) => item['membershipId'] != null);
                  break;
                default:
                  shouldInclude = true;
              }
              
              if (shouldInclude) {
                filteredOrders.add(order);
              }
            } catch (e) {
              filteredOrders.add(order);
            }
          }
          
          allOrders = filteredOrders;
        }
        
        allOrders.sort((a, b) => DateTime.parse(b['purchasedAt']).compareTo(DateTime.parse(a['purchasedAt'])));
        
        final totalCount = allOrders.length;
        final startIndex = (page - 1) * pageSize;
        final endIndex = startIndex + pageSize;
        
        final paginatedOrders = allOrders.sublist(
          startIndex < totalCount ? startIndex : totalCount,
          endIndex < totalCount ? endIndex : totalCount,
        );
        
        return {
          'resultList': paginatedOrders,
          'count': totalCount,
        };
      }
      
      throw Exception('Greška prilikom učitavanja transakcija.');
    } catch (e) {
      throw Exception('Greška prilikom dobijanja transakcija.');
    }
  }

  Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) async {
    try {
      final response = await _apiService.get('Order/order-items/$orderId');
      
      if (response != null && response is List) {
        return response.map((itemJson) => _mapOrderItemFromBackend(itemJson)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Greška prilikom dobijanja stavki narudžbe.');
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

  Future<List<BookTransaction>> getMemberRentalTransactions(int memberId) async {
    try {
      final response = await _apiService.get('BookTransaction/member/$memberId/rental-transactions');
      
      if (response != null && response is List) {
        final transactions = response.map((json) {
          final transaction = BookTransaction.fromJson(json);
          return transaction;
        }).toList();
        return transactions;
      }
      
      return [];
    } catch (e) {
      throw Exception('Greška prilikom dobijanja iznajmljivanja člana.');
    }
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

  Membership _mapMembershipFromBackend(dynamic membershipData) {
    return Membership(
      id: membershipData['id'],
      startDate: DateTime.parse(membershipData['startDate']),
      endDate: DateTime.parse(membershipData['endDate']),
      memberId: membershipData['memberId'],
    );
  }
}
