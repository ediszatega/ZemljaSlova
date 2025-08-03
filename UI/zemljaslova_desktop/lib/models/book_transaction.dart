import 'package:json_annotation/json_annotation.dart';

part 'book_transaction.g.dart';

@JsonSerializable()
class BookTransaction {
  final int? id;
  final int activityTypeId;
  final int bookId;
  @JsonKey(name: 'qantity')
  final int quantity;
  final DateTime createdAt;
  final int userId;
  final String? data;

  BookTransaction({
    this.id,
    required this.activityTypeId,
    required this.bookId,
    required this.quantity,
    required this.createdAt,
    required this.userId,
    this.data,
  });

  factory BookTransaction.fromJson(Map<String, dynamic> json) => _$BookTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$BookTransactionToJson(this);
}

enum BookActivityType {
  stock(1),
  sold(2);

  const BookActivityType(this.value);
  final int value;

  static BookActivityType fromValue(int value) {
    return BookActivityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BookActivityType.stock,
    );
  }
} 