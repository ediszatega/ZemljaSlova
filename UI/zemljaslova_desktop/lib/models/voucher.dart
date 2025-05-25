import 'package:json_annotation/json_annotation.dart';
import 'member.dart';

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
  final Member? purchasedByMember;

  Voucher({
    required this.id,
    required this.value,
    required this.code,
    required this.isUsed,
    required this.expirationDate,
    this.purchasedByMemberId,
    this.purchasedAt,
    this.purchasedByMember,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) => _$VoucherFromJson(json);

  Map<String, dynamic> toJson() => _$VoucherToJson(this);

  // Helper getters
  bool get isPurchasedByMember => purchasedByMemberId != null;
  bool get isPromotional => purchasedByMemberId == null;
  String get typeDisplay => isPurchasedByMember ? 'Kupljen' : 'Promocijski';
  String get statusDisplay => isUsed ? 'Iskorišten' : 'Aktivan';
  
  String get purchaserDisplay {
    if (purchasedByMember != null) {
      return '${purchasedByMember!.firstName} ${purchasedByMember!.lastName}';
    } else if (isPurchasedByMember) {
      return 'Korisnik ID: $purchasedByMemberId';
    } else {
      return 'Admin';
    }
  }
} 