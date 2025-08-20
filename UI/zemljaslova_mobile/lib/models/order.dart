import 'package:json_annotation/json_annotation.dart';
import 'book.dart';
import 'voucher.dart';
import 'ticket_type.dart';
import 'membership.dart';

part 'order.g.dart';

@JsonSerializable()
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

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
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

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
