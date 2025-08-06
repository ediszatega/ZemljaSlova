import 'package:json_annotation/json_annotation.dart';
import '../widgets/inventory_screen.dart';

part 'book_transaction.g.dart';

@JsonSerializable()
class BookTransaction implements InventoryTransaction {
  final int? id;
  @override
  final int activityTypeId;
  final int bookId;
  @override
  @JsonKey(name: 'quantity')
  final int quantity;
  @override
  final DateTime createdAt;
  final int userId;
  @override
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