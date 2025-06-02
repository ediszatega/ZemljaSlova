import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'discount.g.dart';

@JsonSerializable()
class Discount {
  final int id;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final String? code;
  final String name;
  final String? description;
  final int scope; // 1 = Book, 2 = Order
  final int usageCount;
  final int? maxUsage;
  final bool isActive;

  Discount({
    required this.id,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    this.code,
    required this.name,
    this.description,
    required this.scope,
    required this.usageCount,
    this.maxUsage,
    required this.isActive,
  });

  factory Discount.fromJson(Map<String, dynamic> json) => _$DiscountFromJson(json);

  Map<String, dynamic> toJson() => _$DiscountToJson(this);

  // Helper getters
  String get scopeDisplay => scope == 1 ? 'Knjiga' : 'Narudžba';
  String get statusDisplay {
    if (!isActive) return 'Neaktivan';
    
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 'Nadolazeći';
    if (now.isAfter(endDate)) return 'Istekao';
    if (maxUsage != null && usageCount >= maxUsage!) return 'Iscrpljen';
    
    return 'Aktivan';
  }
  
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           !now.isBefore(startDate) && 
           !now.isAfter(endDate) && 
           (maxUsage == null || usageCount < maxUsage!);
  }
  
  String get usageDisplay {
    if (maxUsage != null) {
      return '$usageCount / $maxUsage';
    }
    return usageCount.toString();
  }
  
  Color get statusColor {
    if (!isActive) return Colors.grey;
    if (isExpired) return Colors.red;
    if (maxUsage != null && usageCount >= maxUsage!) return Colors.orange;
    return Colors.green;
  }
} 