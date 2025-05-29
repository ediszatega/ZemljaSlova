// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Membership _$MembershipFromJson(Map<String, dynamic> json) => Membership(
  id: (json['id'] as num).toInt(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  memberId: (json['memberId'] as num).toInt(),
  member:
      json['member'] == null
          ? null
          : Member.fromJson(json['member'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MembershipToJson(Membership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'memberId': instance.memberId,
      'member': instance.member,
    };
