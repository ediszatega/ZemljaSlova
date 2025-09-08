import 'package:json_annotation/json_annotation.dart';
import 'author.dart';
import 'discount.dart';

part 'book.g.dart';

enum BookPurpose {
  @JsonValue(1)
  sell,
  @JsonValue(2)
  rent,
}

@JsonSerializable()
class Book {
  final int id;
  final String title;
  final double? price;
  final String? coverImageUrl;
  final bool isAvailable;
  final int quantityInStock;
  final int quantitySold;
  
  final String? description;
  final String? dateOfPublish;
  final int? edition;
  final String? publisher;
  @JsonKey(name: 'bookPurpose')
  final BookPurpose? bookPurpose;
  final int numberOfPages;
  final double? weight;
  final String? dimensions;
  final String? genre;
  final String? binding;
  final String? language;  
  final List<int> authorIds;  
  final List<Author>? authors;
  
  // Discount related fields
  final int? discountId;
  final double? discountedPrice;
  final Discount? discount;

  Book({
    required this.id,
    required this.title,
    this.price,
    this.coverImageUrl,
    this.isAvailable = true,
    this.quantityInStock = 0,
    this.quantitySold = 0,
    this.description,
    this.dateOfPublish,
    this.edition,
    this.publisher,
    this.bookPurpose,
    this.numberOfPages = 0,
    this.weight,
    this.dimensions,
    this.genre,
    this.binding,
    this.language,
    this.authorIds = const [],
    this.authors,
    this.discountId,
    this.discountedPrice,
    this.discount,
  });

  String get authorNames {
    if (authors != null && authors!.isNotEmpty) {
      return authors!.map((a) => '${a.firstName} ${a.lastName}').join(', ');
    }
    return "Autor nepoznat";
  }

  /// Returns the effective price (discounted price if available, otherwise regular price)
  double? get effectivePrice {
    return discountedPrice ?? price;
  }

  /// Returns true if the book has an active discount
  bool get hasDiscount {
    return discountedPrice != null && discountedPrice! < (price ?? 0);
  }

  /// Returns the discount percentage if available
  double? get discountPercentage {
    if (discount != null && price != null && price! > 0) {
      return discount!.discountPercentage;
    }
    return null;
  }

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);
} 