// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_type_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketTypeTransaction _$TicketTypeTransactionFromJson(
  Map<String, dynamic> json,
) => TicketTypeTransaction(
  id: (json['id'] as num?)?.toInt(),
  activityTypeId: (json['activityTypeId'] as num).toInt(),
  ticketTypeId: (json['ticketTypeId'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  userId: (json['userId'] as num).toInt(),
  data: json['data'] as String?,
);

Map<String, dynamic> _$TicketTypeTransactionToJson(
  TicketTypeTransaction instance,
) => <String, dynamic>{
  'id': instance.id,
  'activityTypeId': instance.activityTypeId,
  'ticketTypeId': instance.ticketTypeId,
  'quantity': instance.quantity,
  'createdAt': instance.createdAt.toIso8601String(),
  'userId': instance.userId,
  'data': instance.data,
};
