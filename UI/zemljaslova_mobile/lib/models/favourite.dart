import 'package:json_annotation/json_annotation.dart';
import 'book.dart';

part 'favourite.g.dart';

@JsonSerializable()
class Favourite {
  final int id;
  final int memberId;
  final int bookId;
  final Book? book;

  Favourite({
    required this.id,
    required this.memberId,
    required this.bookId,
    this.book,
  });

  factory Favourite.fromJson(Map<String, dynamic> json) => _$FavouriteFromJson(json);

  Map<String, dynamic> toJson() => _$FavouriteToJson(this);
} 