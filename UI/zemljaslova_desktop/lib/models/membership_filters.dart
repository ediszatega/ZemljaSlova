class MembershipFilters {
  final bool? isActive;
  final DateTime? startDateFrom;
  final DateTime? startDateTo;
  final DateTime? endDateFrom;
  final DateTime? endDateTo;

  const MembershipFilters({
    this.isActive,
    this.startDateFrom,
    this.startDateTo,
    this.endDateFrom,
    this.endDateTo,
  });

  MembershipFilters copyWith({
    bool? isActive,
    DateTime? startDateFrom,
    DateTime? startDateTo,
    DateTime? endDateFrom,
    DateTime? endDateTo,
  }) {
    return MembershipFilters(
      isActive: isActive ?? this.isActive,
      startDateFrom: startDateFrom ?? this.startDateFrom,
      startDateTo: startDateTo ?? this.startDateTo,
      endDateFrom: endDateFrom ?? this.endDateFrom,
      endDateTo: endDateTo ?? this.endDateTo,
    );
  }

  bool get hasActiveFilters {
    return isActive != null ||
           startDateFrom != null ||
           startDateTo != null ||
           endDateFrom != null ||
           endDateTo != null;
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (isActive != null) {
      params['IsActive'] = isActive;
    }
    if (startDateFrom != null) {
      params['StartDateFrom'] = startDateFrom!.toIso8601String();
    }
    if (startDateTo != null) {
      params['StartDateTo'] = startDateTo!.toIso8601String();
    }
    if (endDateFrom != null) {
      params['EndDateFrom'] = endDateFrom!.toIso8601String();
    }
    if (endDateTo != null) {
      params['EndDateTo'] = endDateTo!.toIso8601String();
    }
    
    return params;
  }

  factory MembershipFilters.fromMap(Map<String, dynamic> map) {
    DateTime? _parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return MembershipFilters(
      isActive: map['isActive'] as bool?,
      startDateFrom: _parseDateTime(map['startDateFrom']),
      startDateTo: _parseDateTime(map['startDateTo']),
      endDateFrom: _parseDateTime(map['endDateFrom']),
      endDateTo: _parseDateTime(map['endDateTo']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isActive': isActive,
      'startDateFrom': startDateFrom?.millisecondsSinceEpoch,
      'startDateTo': startDateTo?.millisecondsSinceEpoch,
      'endDateFrom': endDateFrom?.millisecondsSinceEpoch,
      'endDateTo': endDateTo?.millisecondsSinceEpoch,
    };
  }
} 