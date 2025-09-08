import 'package:json_annotation/json_annotation.dart';

part 'discount.g.dart';

enum DiscountScope {
  @JsonValue(1)
  book,
  @JsonValue(2)
  order,
}

@JsonSerializable()
class Discount {
  final int id;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final String? code;
  final String? name;
  final String? description;
  final DiscountScope scope;
  final int usageCount;
  final int? maxUsage;
  final bool isActive;

  Discount({
    required this.id,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    this.code,
    this.name,
    this.description,
    required this.scope,
    required this.usageCount,
    this.maxUsage,
    required this.isActive,
  });

  /// Returns true if the discount is currently valid
  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           startDate.isBefore(now) && 
           endDate.isAfter(now) &&
           (maxUsage == null || usageCount < maxUsage!);
  }

  factory Discount.fromJson(Map<String, dynamic> json) => _$DiscountFromJson(json);

  Map<String, dynamic> toJson() => _$DiscountToJson(this);
}
