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

  static EventFilters get empty => const EventFilters();

  // Convert to query parameters for API
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

  // Convert from unified dialog values
  static EventFilters fromMap(Map<String, dynamic> values) {
    return EventFilters(
      minPrice: values['minPrice'] as double?,
      maxPrice: values['maxPrice'] as double?,
      startDateFrom: values['startDateFrom'] as DateTime?,
      startDateTo: values['startDateTo'] as DateTime?,
    );
  }

  // Convert to unified dialog values
  Map<String, dynamic> toMap() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'startDateFrom': startDateFrom,
      'startDateTo': startDateTo,
    };
  }
} 