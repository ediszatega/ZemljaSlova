class EventFilters {
  final double? minPrice;
  final double? maxPrice;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;

  const EventFilters({
    this.minPrice,
    this.maxPrice,
    this.startDateFrom,
    this.startDateTo,
  });

  EventFilters copyWith({
    double? minPrice,
    double? maxPrice,
    DateTime? startDateFrom,
    DateTime? startDateTo,
  }) {
    return EventFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      startDateFrom: startDateFrom ?? this.startDateFrom,
      startDateTo: startDateTo ?? this.startDateTo,
    );
  }

  bool get hasActiveFilters {
    return minPrice != null ||
           maxPrice != null ||
           startDateFrom != null ||
           startDateTo != null;
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (minPrice != null) {
      params['MinPrice'] = minPrice!.toString();
    }
    
    if (maxPrice != null) {
      params['MaxPrice'] = maxPrice!.toString();
    }
    
    if (startDateFrom != null) {
      params['StartDateFrom'] = startDateFrom!.toIso8601String();
    }
    
    if (startDateTo != null) {
      params['StartDateTo'] = startDateTo!.toIso8601String();
    }
    
    return params;
  }

  Map<String, dynamic> toMap() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'startDateFrom': startDateFrom?.millisecondsSinceEpoch,
      'startDateTo': startDateTo?.millisecondsSinceEpoch,
    };
  }

  static EventFilters fromMap(Map<String, dynamic> map) {
    return EventFilters(
      minPrice: map['minPrice']?.toDouble(),
      maxPrice: map['maxPrice']?.toDouble(),
      startDateFrom: map['startDateFrom'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['startDateFrom'])
          : null,
      startDateTo: map['startDateTo'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['startDateTo'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventFilters &&
           other.minPrice == minPrice &&
           other.maxPrice == maxPrice &&
           other.startDateFrom == startDateFrom &&
           other.startDateTo == startDateTo;
  }

  @override
  int get hashCode {
    return minPrice.hashCode ^
           maxPrice.hashCode ^
           startDateFrom.hashCode ^
           startDateTo.hashCode;
  }
} 