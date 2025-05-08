// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketType _$TicketTypeFromJson(Map<String, dynamic> json) => TicketType(
      id: json['id'] as int?,
      eventId: json['eventId'] as int,
      price: (json['price'] as num).toDouble(),
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TicketTypeToJson(TicketType instance) => <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'price': instance.price,
      'name': instance.name,
      'description': instance.description,
    }; 