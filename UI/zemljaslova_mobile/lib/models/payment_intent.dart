import 'package:json_annotation/json_annotation.dart';

part 'payment_intent.g.dart';

@JsonSerializable()
class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;
  final double amount;
  final String currency;
  final String status;

  PaymentIntentResponse({
    required this.clientSecret,
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) => _$PaymentIntentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentIntentResponseToJson(this);
}

@JsonSerializable()
class PaymentResultResponse {
  final bool isSuccess;
  final String? errorMessage;
  final VoucherPurchaseResult? voucherPurchase;

  PaymentResultResponse({
    required this.isSuccess,
    this.errorMessage,
    this.voucherPurchase,
  });

  factory PaymentResultResponse.fromJson(Map<String, dynamic> json) => _$PaymentResultResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentResultResponseToJson(this);
}

@JsonSerializable()
class VoucherPurchaseResult {
  final int voucherId;
  final String voucherCode;
  final double value;
  @JsonKey(name: 'expirationDate')
  final DateTime expirationDate;
  final String paymentId;
  @JsonKey(name: 'purchaseDate')
  final DateTime purchaseDate;

  VoucherPurchaseResult({
    required this.voucherId,
    required this.voucherCode,
    required this.value,
    required this.expirationDate,
    required this.paymentId,
    required this.purchaseDate,
  });

  factory VoucherPurchaseResult.fromJson(Map<String, dynamic> json) => _$VoucherPurchaseResultFromJson(json);
  Map<String, dynamic> toJson() => _$VoucherPurchaseResultToJson(this);
}
