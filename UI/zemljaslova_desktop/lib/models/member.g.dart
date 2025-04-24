// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      dateOfBirth: json['dateOfBirth'] == null
          ? DateTime.now()
          : DateTime.parse(json['dateOfBirth'] as String),
      joinedAt: json['joinedAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['joinedAt'] as String),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      gender: json['gender'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      profileImageUrl: json['profileImageUrl'] as String?,
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'joinedAt': instance.joinedAt.toIso8601String(),
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'gender': instance.gender,
      'isActive': instance.isActive,
      'profileImageUrl': instance.profileImageUrl,
    };
