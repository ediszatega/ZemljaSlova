class AuthorFilters {
  final int? birthYearFrom;
  final int? birthYearTo;

  const AuthorFilters({
    this.birthYearFrom,
    this.birthYearTo,
  });

  AuthorFilters copyWith({
    int? birthYearFrom,
    int? birthYearTo,
  }) {
    return AuthorFilters(
      birthYearFrom: birthYearFrom ?? this.birthYearFrom,
      birthYearTo: birthYearTo ?? this.birthYearTo,
    );
  }

  bool get hasActiveFilters {
    return birthYearFrom != null || birthYearTo != null;
  }

  static AuthorFilters get empty => const AuthorFilters();

  // Convert to query parameters for API
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (birthYearFrom != null) {
      params['BirthYearFrom'] = birthYearFrom!.toString();
    }
    if (birthYearTo != null) {
      params['BirthYearTo'] = birthYearTo!.toString();
    }
    
    return params;
  }

  // Convert from unified dialog values
  static AuthorFilters fromMap(Map<String, dynamic> values) {
    return AuthorFilters(
      birthYearFrom: values['birthYearFrom'] as int?,
      birthYearTo: values['birthYearTo'] as int?,
    );
  }

  // Convert to unified dialog values
  Map<String, dynamic> toMap() {
    return {
      'birthYearFrom': birthYearFrom,
      'birthYearTo': birthYearTo,
    };
  }
} 