// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  organizer: json['organizer'] as String,
  date: json['date'] as String,
  price: (json['price'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'organizer': instance.organizer,
  'date': instance.date,
  'price': instance.price,
  'imageUrl': instance.imageUrl,
}; 