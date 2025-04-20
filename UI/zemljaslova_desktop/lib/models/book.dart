import 'package:json_annotation/json_annotation.dart';

part 'book.g.dart';

@JsonSerializable()
class Book {
  final int id;
  final String title;
  final String author;
  final double price;
  final String? coverImageUrl;
  final bool isAvailable;
  final int quantityInStock; // Number of books currently in stock
  final int quantitySold; // Number of books sold

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    this.coverImageUrl,
    this.isAvailable = true,
    this.quantityInStock = 0,
    this.quantitySold = 0,
  });

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

  Map<String, dynamic> toJson() => _$BookToJson(this);
} 