import 'package:flutter/material.dart';

class DiscountFilters {
  final bool? isActive;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final DateTime? endDateFrom;
  final DateTime? endDateTo;
  final int? scope;
  final double? minPercentage;
  final double? maxPercentage;
  final bool? hasUsageLimit;
  final int? bookId;

  const DiscountFilters({
    this.isActive,
    this.startDateFrom,
    this.startDateTo,
    this.endDateFrom,
    this.endDateTo,
    this.scope,
    this.minPercentage,
    this.maxPercentage,
    this.hasUsageLimit,
    this.bookId,
  });

  DiscountFilters copyWith({
    bool? isActive,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
    int? scope,
    double? minPercentage,
    double? maxPercentage,
    bool? hasUsageLimit,
    int? bookId,
  }) {
    return DiscountFilters(
      isActive: isActive ?? this.isActive,
      startDateFrom: startDateFrom ?? this.startDateFrom,
      startDateTo: startDateTo ?? this.startDateTo,
      endDateFrom: endDateFrom ?? this.endDateFrom,
      endDateTo: endDateTo ?? this.endDateTo,
      scope: scope ?? this.scope,
      minPercentage: minPercentage ?? this.minPercentage,
      maxPercentage: maxPercentage ?? this.maxPercentage,
      hasUsageLimit: hasUsageLimit ?? this.hasUsageLimit,
      bookId: bookId ?? this.bookId,
    );
  }

  bool get hasActiveFilters {
    return isActive != null ||
           startDateFrom != null ||
           startDateTo != null ||
           endDateFrom != null ||
           endDateTo != null ||
           scope != null ||
           minPercentage != null ||
           maxPercentage != null ||
           hasUsageLimit != null ||
           bookId != null;
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (isActive != null) params['IsActive'] = isActive;
    if (startDateFrom != null) params['StartDateFrom'] = startDateFrom!.toIso8601String();
    if (startDateTo != null) params['StartDateTo'] = startDateTo!.toIso8601String();
    if (endDateFrom != null) params['EndDateFrom'] = endDateFrom!.toIso8601String();
    if (endDateTo != null) params['EndDateTo'] = endDateTo!.toIso8601String();
    if (scope != null) params['Scope'] = scope;
    if (minPercentage != null) params['MinPercentage'] = minPercentage;
    if (maxPercentage != null) params['MaxPercentage'] = maxPercentage;
    if (hasUsageLimit != null) params['HasUsageLimit'] = hasUsageLimit;
    if (bookId != null) params['BookId'] = bookId;
    
    return params;
  }

  Map<String, dynamic> toMap() {
    return {
      'isActive': isActive,
      'startDateFrom': startDateFrom?.millisecondsSinceEpoch,
      'startDateTo': startDateTo?.millisecondsSinceEpoch,
      'endDateFrom': endDateFrom?.millisecondsSinceEpoch,
      'endDateTo': endDateTo?.millisecondsSinceEpoch,
      'scope': scope,
      'minPercentage': minPercentage,
      'maxPercentage': maxPercentage,
      'hasUsageLimit': hasUsageLimit,
      'bookId': bookId,
    };
  }

  factory DiscountFilters.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return DiscountFilters(
      isActive: map['isActive'] as bool?,
      startDateFrom: _parseDateTime(map['startDateFrom']),
      startDateTo: _parseDateTime(map['startDateTo']),
      endDateFrom: _parseDateTime(map['endDateFrom']),
      endDateTo: _parseDateTime(map['endDateTo']),
      scope: map['scope'] as int?,
      minPercentage: map['minPercentage'] as double?,
      maxPercentage: map['maxPercentage'] as double?,
      hasUsageLimit: map['hasUsageLimit'] as bool?,
      bookId: map['bookId'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscountFilters &&
           other.isActive == isActive &&
           other.startDateFrom == startDateFrom &&
           other.startDateTo == startDateTo &&
           other.endDateFrom == endDateFrom &&
           other.endDateTo == endDateTo &&
           other.scope == scope &&
           other.minPercentage == minPercentage &&
           other.maxPercentage == maxPercentage &&
           other.hasUsageLimit == hasUsageLimit &&
           other.bookId == bookId;
  }

  @override
  int get hashCode {
    return Object.hash(
      isActive,
      startDateFrom,
      startDateTo,
      endDateFrom,
      endDateTo,
      scope,
      minPercentage,
      maxPercentage,
      hasUsageLimit,
      bookId,
    );
  }
} 