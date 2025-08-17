// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_intent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentIntentResponse _$PaymentIntentResponseFromJson(
  Map<String, dynamic> json,
) => PaymentIntentResponse(
  clientSecret: json['clientSecret'] as String,
  paymentIntentId: json['paymentIntentId'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$PaymentIntentResponseToJson(
  PaymentIntentResponse instance,
) => <String, dynamic>{
  'clientSecret': instance.clientSecret,
  'paymentIntentId': instance.paymentIntentId,
  'amount': instance.amount,
  'currency': instance.currency,
  'status': instance.status,
};

PaymentResultResponse _$PaymentResultResponseFromJson(
  Map<String, dynamic> json,
) => PaymentResultResponse(
  isSuccess: json['isSuccess'] as bool,
  errorMessage: json['errorMessage'] as String?,
  voucherPurchase:
      json['voucherPurchase'] == null
          ? null
          : VoucherPurchaseResult.fromJson(
            json['voucherPurchase'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$PaymentResultResponseToJson(
  PaymentResultResponse instance,
) => <String, dynamic>{
  'isSuccess': instance.isSuccess,
  'errorMessage': instance.errorMessage,
  'voucherPurchase': instance.voucherPurchase,
};

VoucherPurchaseResult _$VoucherPurchaseResultFromJson(
  Map<String, dynamic> json,
) => VoucherPurchaseResult(
  voucherId: (json['voucherId'] as num).toInt(),
  voucherCode: json['voucherCode'] as String,
  value: (json['value'] as num).toDouble(),
  expirationDate: DateTime.parse(json['expirationDate'] as String),
  paymentId: json['paymentId'] as String,
  purchaseDate: DateTime.parse(json['purchaseDate'] as String),
);

Map<String, dynamic> _$VoucherPurchaseResultToJson(
  VoucherPurchaseResult instance,
) => <String, dynamic>{
  'voucherId': instance.voucherId,
  'voucherCode': instance.voucherCode,
  'value': instance.value,
  'expirationDate': instance.expirationDate.toIso8601String(),
  'paymentId': instance.paymentId,
  'purchaseDate': instance.purchaseDate.toIso8601String(),
};
