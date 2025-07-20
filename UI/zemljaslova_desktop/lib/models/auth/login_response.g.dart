// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      (json['result'] as num?)?.toInt(),
      json['token'] as String?,
      (json['userId'] as num?)?.toInt(),
      json['role'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'result': instance.result,
      'token': instance.token,
      'userId': instance.userId,
      'role': instance.role,
    };
