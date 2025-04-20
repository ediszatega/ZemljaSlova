// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  author: json['author'] as String,
  price: (json['price'] as num).toDouble(),
  coverImageUrl: json['coverImageUrl'] as String?,
  isAvailable: json['isAvailable'] as bool? ?? true,
  quantityInStock: json['quantityInStock'] as int? ?? 0,
  quantitySold: json['quantitySold'] as int? ?? 0,
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'author': instance.author,
  'price': instance.price,
  'coverImageUrl': instance.coverImageUrl,
  'isAvailable': instance.isAvailable,
  'quantityInStock': instance.quantityInStock,
  'quantitySold': instance.quantitySold,
};
