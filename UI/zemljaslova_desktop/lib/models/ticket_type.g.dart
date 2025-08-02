// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketType _$TicketTypeFromJson(Map<String, dynamic> json) => TicketType(
  id: (json['id'] as num?)?.toInt(),
  eventId: (json['eventId'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  name: json['name'] as String,
  description: json['description'] as String?,
  initialQuantity: (json['initialQuantity'] as num?)?.toInt(),
  currentQuantity: (json['currentQuantity'] as num?)?.toInt(),
);

Map<String, dynamic> _$TicketTypeToJson(TicketType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'price': instance.price,
      'name': instance.name,
      'description': instance.description,
      'initialQuantity': instance.initialQuantity,
      'currentQuantity': instance.currentQuantity,
    };
