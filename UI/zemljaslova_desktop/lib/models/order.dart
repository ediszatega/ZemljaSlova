import 'book.dart';
import 'voucher.dart';
import 'ticket_type.dart';
import 'membership.dart';

class Order {
  final int id;
  final int memberId;
  final int? discountId;
  final DateTime purchasedAt;
  final double amount;
  final int? voucherId;
  final String? paymentIntentId;
  final String? paymentStatus;
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingPostalCode;
  final String? shippingCountry;
  final String? shippingPhoneNumber;
  final String? shippingEmail;
  final List<OrderItem> orderItems;

  Order({
    required this.id,
    required this.memberId,
    this.discountId,
    required this.purchasedAt,
    required this.amount,
    this.voucherId,
    this.paymentIntentId,
    this.paymentStatus,
    this.shippingAddress,
    this.shippingCity,
    this.shippingPostalCode,
    this.shippingCountry,
    this.shippingPhoneNumber,
    this.shippingEmail,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final orderItems = (json['orderItems'] as List?)
        ?.map((itemJson) => OrderItem.fromJson(itemJson))
        .toList() ?? [];

    return Order(
      id: json['id'],
      memberId: json['memberId'],
      discountId: json['discountId'],
      purchasedAt: DateTime.parse(json['purchasedAt']),
      amount: (json['amount'] as num).toDouble(),
      voucherId: json['voucherId'],
      paymentIntentId: json['paymentIntentId'],
      paymentStatus: json['paymentStatus'],
      shippingAddress: json['shippingAddress'],
      shippingCity: json['shippingCity'],
      shippingPostalCode: json['shippingPostalCode'],
      shippingCountry: json['shippingCountry'],
      shippingPhoneNumber: json['shippingPhoneNumber'],
      shippingEmail: json['shippingEmail'],
      orderItems: orderItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'discountId': discountId,
      'purchasedAt': purchasedAt.toIso8601String(),
      'amount': amount,
      'voucherId': voucherId,
      'paymentIntentId': paymentIntentId,
      'paymentStatus': paymentStatus,
      'shippingAddress': shippingAddress,
      'shippingCity': shippingCity,
      'shippingPostalCode': shippingPostalCode,
      'shippingCountry': shippingCountry,
      'shippingPhoneNumber': shippingPhoneNumber,
      'shippingEmail': shippingEmail,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int id;
  final int? bookId;
  final int? ticketTypeId;
  final int? membershipId;
  final int quantity;
  final int? discountId;
  final int orderId;
  final int? voucherId;
  final Book? book;
  final Voucher? voucher;
  final TicketType? ticketType;
  final Membership? membership;
  final int? pointsEarned;

  OrderItem({
    required this.id,
    this.bookId,
    this.ticketTypeId,
    this.membershipId,
    required this.quantity,
    this.discountId,
    required this.orderId,
    this.voucherId,
    this.book,
    this.voucher,
    this.ticketType,
    this.membership,
    this.pointsEarned,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      bookId: json['bookId'],
      ticketTypeId: json['ticketTypeId'],
      membershipId: json['membershipId'],
      quantity: json['quantity'],
      discountId: json['discountId'],
      orderId: json['orderId'],
      voucherId: json['voucherId'],
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
      voucher: json['voucher'] != null ? Voucher.fromJson(json['voucher']) : null,
      ticketType: json['ticketType'] != null ? TicketType.fromJson(json['ticketType']) : null,
      membership: json['membership'] != null ? Membership.fromJson(json['membership']) : null,
      pointsEarned: json['pointsEarned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'ticketTypeId': ticketTypeId,
      'membershipId': membershipId,
      'quantity': quantity,
      'discountId': discountId,
      'orderId': orderId,
      'voucherId': voucherId,
      'book': book?.toJson(),
      'voucher': voucher?.toJson(),
      'ticketType': ticketType?.toJson(),
      'membership': membership?.toJson(),
      'pointsEarned': pointsEarned,
    };
  }
}
