import 'package:json_annotation/json_annotation.dart';

part 'voucher.g.dart';

@JsonSerializable()
class Voucher {
  final int id;
  final double value;
  final String code;
  final bool isUsed;
  final DateTime expirationDate;
  final int? purchasedByMemberId;
  final DateTime? purchasedAt;

  Voucher({
    required this.id,
    required this.value,
    required this.code,
    required this.isUsed,
    required this.expirationDate,
    this.purchasedByMemberId,
    this.purchasedAt,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) => _$VoucherFromJson(json);
  Map<String, dynamic> toJson() => _$VoucherToJson(this);
}
