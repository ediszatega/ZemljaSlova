// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num).toInt(),
  memberId: (json['memberId'] as num).toInt(),
  discountId: (json['discountId'] as num?)?.toInt(),
  purchasedAt: DateTime.parse(json['purchasedAt'] as String),
  amount: (json['amount'] as num).toDouble(),
  voucherId: (json['voucherId'] as num?)?.toInt(),
  paymentIntentId: json['paymentIntentId'] as String?,
  paymentStatus: json['paymentStatus'] as String?,
  shippingAddress: json['shippingAddress'] as String?,
  shippingCity: json['shippingCity'] as String?,
  shippingPostalCode: json['shippingPostalCode'] as String?,
  shippingCountry: json['shippingCountry'] as String?,
  shippingPhoneNumber: json['shippingPhoneNumber'] as String?,
  shippingEmail: json['shippingEmail'] as String?,
  orderItems:
      (json['orderItems'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'discountId': instance.discountId,
  'purchasedAt': instance.purchasedAt.toIso8601String(),
  'amount': instance.amount,
  'voucherId': instance.voucherId,
  'paymentIntentId': instance.paymentIntentId,
  'paymentStatus': instance.paymentStatus,
  'shippingAddress': instance.shippingAddress,
  'shippingCity': instance.shippingCity,
  'shippingPostalCode': instance.shippingPostalCode,
  'shippingCountry': instance.shippingCountry,
  'shippingPhoneNumber': instance.shippingPhoneNumber,
  'shippingEmail': instance.shippingEmail,
  'orderItems': instance.orderItems,
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: (json['id'] as num).toInt(),
  bookId: (json['bookId'] as num?)?.toInt(),
  ticketTypeId: (json['ticketTypeId'] as num?)?.toInt(),
  membershipId: (json['membershipId'] as num?)?.toInt(),
  quantity: (json['quantity'] as num).toInt(),
  discountId: (json['discountId'] as num?)?.toInt(),
  orderId: (json['orderId'] as num).toInt(),
  voucherId: (json['voucherId'] as num?)?.toInt(),
  book:
      json['book'] == null
          ? null
          : Book.fromJson(json['book'] as Map<String, dynamic>),
  voucher:
      json['voucher'] == null
          ? null
          : Voucher.fromJson(json['voucher'] as Map<String, dynamic>),
  ticketType:
      json['ticketType'] == null
          ? null
          : TicketType.fromJson(json['ticketType'] as Map<String, dynamic>),
  membership:
      json['membership'] == null
          ? null
          : Membership.fromJson(json['membership'] as Map<String, dynamic>),
  pointsEarned: (json['pointsEarned'] as num?)?.toInt(),
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'bookId': instance.bookId,
  'ticketTypeId': instance.ticketTypeId,
  'membershipId': instance.membershipId,
  'quantity': instance.quantity,
  'discountId': instance.discountId,
  'orderId': instance.orderId,
  'voucherId': instance.voucherId,
  'book': instance.book,
  'voucher': instance.voucher,
  'ticketType': instance.ticketType,
  'membership': instance.membership,
  'pointsEarned': instance.pointsEarned,
};
