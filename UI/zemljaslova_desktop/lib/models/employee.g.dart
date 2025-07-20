// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  accessLevel: json['accessLevel'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  email: json['email'] as String,
  gender: json['gender'] as String?,
  isActive: json['isActive'] as bool,
  profileImageUrl: json['profileImageUrl'] as String?,
);

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'accessLevel': instance.accessLevel,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'gender': instance.gender,
  'isActive': instance.isActive,
  'profileImageUrl': instance.profileImageUrl,
};
