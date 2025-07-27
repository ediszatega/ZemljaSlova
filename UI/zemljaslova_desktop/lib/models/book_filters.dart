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

  static BookFilters get empty => const BookFilters();

  // Convert to query parameters for API
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
} 