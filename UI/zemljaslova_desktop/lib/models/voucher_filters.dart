class VoucherFilters {
  final int? memberId;
  final bool? isUsed;
  final String? code;
  final DateTime? expirationDateFrom;
  final DateTime? expirationDateTo;
  final double? minValue;
  final double? maxValue;
  final String? voucherType;

  const VoucherFilters({
    this.memberId,
    this.isUsed,
    this.code,
    this.expirationDateFrom,
    this.expirationDateTo,
    this.minValue,
    this.maxValue,
    this.voucherType,
  });

  VoucherFilters copyWith({
    int? memberId,
    bool? isUsed,
    String? code,
    DateTime? expirationDateFrom,
    DateTime? expirationDateTo,
    double? minValue,
    double? maxValue,
    String? voucherType,
  }) {
    return VoucherFilters(
      memberId: memberId ?? this.memberId,
      isUsed: isUsed ?? this.isUsed,
      code: code ?? this.code,
      expirationDateFrom: expirationDateFrom ?? this.expirationDateFrom,
      expirationDateTo: expirationDateTo ?? this.expirationDateTo,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      voucherType: voucherType ?? this.voucherType,
    );
  }

  bool get hasActiveFilters {
    return memberId != null ||
           isUsed != null ||
           code != null ||
           expirationDateFrom != null ||
           expirationDateTo != null ||
           minValue != null ||
           maxValue != null ||
           voucherType != null;
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (memberId != null) params['MemberId'] = memberId;
    if (isUsed != null) params['IsUsed'] = isUsed;
    if (code != null) params['Code'] = code;
    if (expirationDateFrom != null) params['ExpirationDateFrom'] = expirationDateFrom!.toIso8601String();
    if (expirationDateTo != null) params['ExpirationDateTo'] = expirationDateTo!.toIso8601String();
    if (minValue != null) params['MinValue'] = minValue;
    if (maxValue != null) params['MaxValue'] = maxValue;
    if (voucherType != null) params['VoucherType'] = voucherType;
    
    return params;
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'isUsed': isUsed,
      'code': code,
      'expirationDateFrom': expirationDateFrom?.millisecondsSinceEpoch,
      'expirationDateTo': expirationDateTo?.millisecondsSinceEpoch,
      'minValue': minValue,
      'maxValue': maxValue,
      'voucherType': voucherType,
    };
  }

  static VoucherFilters fromMap(Map<String, dynamic> map) {
    return VoucherFilters(
      memberId: map['memberId'] as int?,
      isUsed: map['isUsed'] as bool?,
      code: map['code'] as String?,
      expirationDateFrom: map['expirationDateFrom'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['expirationDateFrom'] as int)
          : null,
      expirationDateTo: map['expirationDateTo'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['expirationDateTo'] as int)
          : null,
      minValue: map['minValue'] as double?,
      maxValue: map['maxValue'] as double?,
      voucherType: map['voucherType'] as String?,
    );
  }
} 