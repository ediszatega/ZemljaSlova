class MemberFilters {
  final String? gender;
  final int? birthYearFrom;
  final int? birthYearTo;
  final int? joinedYearFrom;
  final int? joinedYearTo;
  final bool? showInactiveMembers;

  const MemberFilters({
    this.gender,
    this.birthYearFrom,
    this.birthYearTo,
    this.joinedYearFrom,
    this.joinedYearTo,
    this.showInactiveMembers,
  });

  MemberFilters copyWith({
    String? gender,
    int? birthYearFrom,
    int? birthYearTo,
    int? joinedYearFrom,
    int? joinedYearTo,
    bool? showInactiveMembers,
  }) {
    return MemberFilters(
      gender: gender ?? this.gender,
      birthYearFrom: birthYearFrom ?? this.birthYearFrom,
      birthYearTo: birthYearTo ?? this.birthYearTo,
      joinedYearFrom: joinedYearFrom ?? this.joinedYearFrom,
      joinedYearTo: joinedYearTo ?? this.joinedYearTo,
      showInactiveMembers: showInactiveMembers ?? this.showInactiveMembers,
    );
  }

  bool get hasActiveFilters {
    return gender != null ||
           birthYearFrom != null ||
           birthYearTo != null ||
           joinedYearFrom != null ||
           joinedYearTo != null ||
           showInactiveMembers == true;
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (gender != null) params['Gender'] = gender;
    if (birthYearFrom != null) params['BirthYearFrom'] = birthYearFrom;
    if (birthYearTo != null) params['BirthYearTo'] = birthYearTo;
    if (joinedYearFrom != null) params['JoinedYearFrom'] = joinedYearFrom;
    if (joinedYearTo != null) params['JoinedYearTo'] = joinedYearTo;
    if (showInactiveMembers == true) params['ShowInactiveMembers'] = true;
    
    return params;
  }

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'birthYearFrom': birthYearFrom,
      'birthYearTo': birthYearTo,
      'joinedYearFrom': joinedYearFrom,
      'joinedYearTo': joinedYearTo,
      'showInactiveMembers': showInactiveMembers,
    };
  }

  static MemberFilters fromMap(Map<String, dynamic> map) {
    return MemberFilters(
      gender: map['gender'] as String?,
      birthYearFrom: map['birthYearFrom'] as int?,
      birthYearTo: map['birthYearTo'] as int?,
      joinedYearFrom: map['joinedYearFrom'] as int?,
      joinedYearTo: map['joinedYearTo'] as int?,
      showInactiveMembers: map['showInactiveMembers'] as bool?,
    );
  }
} 