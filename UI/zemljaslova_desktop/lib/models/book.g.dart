// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Book _$BookFromJson(Map<String, dynamic> json) => Book(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  price: (json['price'] as num).toDouble(),
  coverImageUrl: json['coverImageUrl'] as String?,
  isAvailable: json['isAvailable'] as bool? ?? true,
  quantityInStock: (json['quantityInStock'] as num?)?.toInt() ?? 0,
  quantitySold: (json['quantitySold'] as num?)?.toInt() ?? 0,
  description: json['description'] as String?,
  dateOfPublish: json['dateOfPublish'] as String?,
  edition: (json['edition'] as num?)?.toInt(),
  publisher: json['publisher'] as String?,
  bookPurpos: json['bookPurpos'] as String?,
  numberOfPages: (json['numberOfPages'] as num?)?.toInt() ?? 0,
  weight: (json['weight'] as num?)?.toDouble(),
  dimensions: json['dimensions'] as String?,
  genre: json['genre'] as String?,
  binding: json['binding'] as String?,
  language: json['language'] as String?,
  authorIds:
      (json['authorIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  authors:
      (json['authors'] as List<dynamic>?)
          ?.map((e) => Author.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BookToJson(Book instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'price': instance.price,
  'coverImageUrl': instance.coverImageUrl,
  'isAvailable': instance.isAvailable,
  'quantityInStock': instance.quantityInStock,
  'quantitySold': instance.quantitySold,
  'description': instance.description,
  'dateOfPublish': instance.dateOfPublish,
  'edition': instance.edition,
  'publisher': instance.publisher,
  'bookPurpos': instance.bookPurpos,
  'numberOfPages': instance.numberOfPages,
  'weight': instance.weight,
  'dimensions': instance.dimensions,
  'genre': instance.genre,
  'binding': instance.binding,
  'language': instance.language,
  'authorIds': instance.authorIds,
  'authors': instance.authors,
};
