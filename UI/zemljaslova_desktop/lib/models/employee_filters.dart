class EmployeeFilters {
  final String? gender;
  final String? accessLevel;

  const EmployeeFilters({
    this.gender,
    this.accessLevel,
  });

  EmployeeFilters copyWith({
    String? gender,
    String? accessLevel,
  }) {
    return EmployeeFilters(
      gender: gender ?? this.gender,
      accessLevel: accessLevel ?? this.accessLevel,
    );
  }

  bool get hasActiveFilters {
    return gender != null || accessLevel != null;
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (gender != null) params['Gender'] = gender;
    if (accessLevel != null) params['AccessLevel'] = accessLevel;
    
    return params;
  }

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'accessLevel': accessLevel,
    };
  }

  static EmployeeFilters fromMap(Map<String, dynamic> map) {
    return EmployeeFilters(
      gender: map['gender'] as String?,
      accessLevel: map['accessLevel'] as String?,
    );
  }
} 