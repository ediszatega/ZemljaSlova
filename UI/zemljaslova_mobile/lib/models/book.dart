import 'package:json_annotation/json_annotation.dart';
import 'author.dart';

part 'book.g.dart';

@JsonSerializable()
class Book {
  final int id;
  final String title;
  final double price;
  final String? coverImageUrl;
  final bool isAvailable;
  final int quantityInStock;
  final int quantitySold;
  
  final String? description;
  final String? dateOfPublish;
  final int? edition;
  final String? publisher;
  final String? bookPurpos;
  final int numberOfPages;
  final double? weight;
  final String? dimensions;
  final String? genre;
  final String? binding;
  final String? language;  
  final List<int> authorIds;  
  final List<Author>? authors;

  Book({
    required this.id,
    required this.title,
    required this.price,
    this.coverImageUrl,
    this.isAvailable = true,
    this.quantityInStock = 0,
    this.quantitySold = 0,
    this.description,
    this.dateOfPublish,
    this.edition,
    this.publisher,
    this.bookPurpos,
    this.numberOfPages = 0,
    this.weight,
    this.dimensions,
    this.genre,
    this.binding,
    this.language,
    this.authorIds = const [],
    this.authors,
  });

  String get authorNames {
    if (authors != null && authors!.isNotEmpty) {
      return authors!.map((a) => '${a.firstName} ${a.lastName}').join(', ');
    }
    return "Autor nepoznat";
  }

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);
} 