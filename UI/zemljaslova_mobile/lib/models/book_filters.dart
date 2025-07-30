class BookFilters {
  final double? minPrice;
  final double? maxPrice;
  final int? authorId;
  final bool? isAvailable;

  const BookFilters({
    this.minPrice,
    this.maxPrice,
    this.authorId,
    this.isAvailable,
  });

  BookFilters copyWith({
    double? minPrice,
    double? maxPrice,
    int? authorId,
    bool? isAvailable,
  }) {
    return BookFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      authorId: authorId ?? this.authorId,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  bool get hasActiveFilters {
    return minPrice != null ||
           maxPrice != null ||
           authorId != null ||
           isAvailable != null;
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (minPrice != null) {
      params['MinPrice'] = minPrice!.toString();
    }
    
    if (maxPrice != null) {
      params['MaxPrice'] = maxPrice!.toString();
    }
    
    if (authorId != null) {
      params['AuthorId'] = authorId!.toString();
    }
    
    if (isAvailable != null) {
      params['IsAvailable'] = isAvailable!.toString();
    }
    
    return params;
  }

  Map<String, dynamic> toMap() {
    return {
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'authorId': authorId,
      'isAvailable': isAvailable,
    };
  }

  static BookFilters fromMap(Map<String, dynamic> map) {
    return BookFilters(
      minPrice: map['minPrice']?.toDouble(),
      maxPrice: map['maxPrice']?.toDouble(),
      authorId: map['authorId']?.toInt(),
      isAvailable: map['isAvailable']?.toBool(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BookFilters &&
           other.minPrice == minPrice &&
           other.maxPrice == maxPrice &&
           other.authorId == authorId &&
           other.isAvailable == isAvailable;
  }

  @override
  int get hashCode {
    return minPrice.hashCode ^
           maxPrice.hashCode ^
           authorId.hashCode ^
           isAvailable.hashCode;
  }
} 