// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Discount _$DiscountFromJson(Map<String, dynamic> json) => Discount(
  id: (json['id'] as num).toInt(),
  discountPercentage: (json['discountPercentage'] as num).toDouble(),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  code: json['code'] as String?,
  name: json['name'] as String,
  description: json['description'] as String?,
  scope: (json['scope'] as num).toInt(),
  usageCount: (json['usageCount'] as num).toInt(),
  maxUsage: (json['maxUsage'] as num?)?.toInt(),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$DiscountToJson(Discount instance) => <String, dynamic>{
  'id': instance.id,
  'discountPercentage': instance.discountPercentage,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'code': instance.code,
  'name': instance.name,
  'description': instance.description,
  'scope': instance.scope,
  'usageCount': instance.usageCount,
  'maxUsage': instance.maxUsage,
  'isActive': instance.isActive,
};
