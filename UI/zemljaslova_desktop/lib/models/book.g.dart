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
  description: json['description'] as String?,
  dateOfPublish: json['dateOfPublish'] as String?,
  edition: json['edition'] as int?,
  publisher: json['publisher'] as String?,
  bookPurpos: json['bookPurpos'] as String?,
  numberOfPages: json['numberOfPages'] as int? ?? 0,
  weight: (json['weight'] as num?)?.toDouble(),
  dimensions: json['dimensions'] as String?,
  genre: json['genre'] as String?,
  binding: json['binding'] as String?,
  language: json['language'] as String?,
  authorId: json['authorId'] as int?,
  authorFirstName: json['authorFirstName'] as String?,
  authorLastName: json['authorLastName'] as String?,
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
  'authorId': instance.authorId,
  'authorFirstName': instance.authorFirstName,
  'authorLastName': instance.authorLastName,
};
