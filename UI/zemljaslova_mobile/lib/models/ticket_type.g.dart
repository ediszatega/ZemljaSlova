// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketType _$TicketTypeFromJson(Map<String, dynamic> json) => TicketType(
  id: (json['id'] as num).toInt(),
  eventId: (json['eventId'] as num).toInt(),
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  description: json['description'] as String,
);

Map<String, dynamic> _$TicketTypeToJson(TicketType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'name': instance.name,
      'price': instance.price,
      'description': instance.description,
    };
