import 'book.dart';

class BookTransaction {
  final int? id;
  final int activityTypeId;
  final int bookId;
  final int quantity;
  final DateTime createdAt;
  final int userId;
  final String? data;
  final int? pointsEarned;
  final Book? book;

  BookTransaction({
    this.id,
    required this.activityTypeId,
    required this.bookId,
    required this.quantity,
    required this.createdAt,
    required this.userId,
    this.data,
    this.pointsEarned,
    this.book,
  });

  factory BookTransaction.fromJson(Map<String, dynamic> json) {
    return BookTransaction(
      id: json['id'] as int?,
      activityTypeId: json['activityTypeId'] as int,
      bookId: json['bookId'] as int,
      quantity: json['quantity'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as int,
      data: json['data'] as String?,
      pointsEarned: json['pointsEarned'] as int?,
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityTypeId': activityTypeId,
      'bookId': bookId,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'data': data,
      'pointsEarned': pointsEarned,
      'book': book?.toJson(),
    };
  }
}

enum BookActivityType {
  stock(1),
  sold(2),
  remove(3),
  rent(4);

  const BookActivityType(this.value);
  final int value;

  static BookActivityType fromValue(int value) {
    return BookActivityType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BookActivityType.stock,
    );
  }
}
