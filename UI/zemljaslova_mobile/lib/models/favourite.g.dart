// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Favourite _$FavouriteFromJson(Map<String, dynamic> json) => Favourite(
  id: (json['id'] as num).toInt(),
  memberId: (json['memberId'] as num).toInt(),
  bookId: (json['bookId'] as num).toInt(),
  book:
      json['book'] == null
          ? null
          : Book.fromJson(json['book'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FavouriteToJson(Favourite instance) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'bookId': instance.bookId,
  'book': instance.book,
};
