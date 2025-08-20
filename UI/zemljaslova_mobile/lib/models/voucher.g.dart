// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voucher.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Voucher _$VoucherFromJson(Map<String, dynamic> json) => Voucher(
  id: (json['id'] as num).toInt(),
  value: (json['value'] as num).toDouble(),
  code: json['code'] as String,
  isUsed: json['isUsed'] as bool,
  expirationDate: DateTime.parse(json['expirationDate'] as String),
  purchasedByMemberId: (json['purchasedByMemberId'] as num?)?.toInt(),
  purchasedAt:
      json['purchasedAt'] == null
          ? null
          : DateTime.parse(json['purchasedAt'] as String),
);

Map<String, dynamic> _$VoucherToJson(Voucher instance) => <String, dynamic>{
  'id': instance.id,
  'value': instance.value,
  'code': instance.code,
  'isUsed': instance.isUsed,
  'expirationDate': instance.expirationDate.toIso8601String(),
  'purchasedByMemberId': instance.purchasedByMemberId,
  'purchasedAt': instance.purchasedAt?.toIso8601String(),
};
