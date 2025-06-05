class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final CartItemType type;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.type,
  });

  CartItem copyWith({
    String? id,
    String? title,
    double? price,
    int? quantity,
    CartItemType? type,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
    );
  }

  double get totalPrice => price * quantity;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum CartItemType {
  voucher,
  book,
  membership,
  ticket,
} 