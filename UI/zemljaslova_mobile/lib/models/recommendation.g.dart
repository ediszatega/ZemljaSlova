// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      id: (json['id'] as num).toInt(),
      memberId: (json['memberId'] as num).toInt(),
      bookId: (json['bookId'] as num).toInt(),
      book:
          json['book'] == null
              ? null
              : Book.fromJson(json['book'] as Map<String, dynamic>),
      member:
          json['member'] == null
              ? null
              : Member.fromJson(json['member'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'bookId': instance.bookId,
      'book': instance.book,
      'member': instance.member,
    };
