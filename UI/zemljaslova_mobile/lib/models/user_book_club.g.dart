// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_book_club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBookClub _$UserBookClubFromJson(Map<String, dynamic> json) => UserBookClub(
  id: (json['id'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  memberId: (json['memberId'] as num).toInt(),
  member:
      json['member'] == null
          ? null
          : Member.fromJson(json['member'] as Map<String, dynamic>),
  userBookClubTransactions:
      (json['userBookClubTransactions'] as List<dynamic>?)
          ?.map(
            (e) => UserBookClubTransaction.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$UserBookClubToJson(UserBookClub instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'memberId': instance.memberId,
      'member': instance.member,
      'userBookClubTransactions': instance.userBookClubTransactions,
    };
