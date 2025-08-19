import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  static const int maxQuantityPerItem = 10;

  List<CartItem> get items => List.unmodifiable(_items);
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);
  
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((cartItem) => cartItem.id == item.id);
    
    if (existingIndex >= 0) {
      // Update existing item quantity, but don't exceed maximum
      final newQuantity = _items[existingIndex].quantity + item.quantity;
      final clampedQuantity = newQuantity > maxQuantityPerItem ? maxQuantityPerItem : newQuantity;
      
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: clampedQuantity,
      );
    } else {
      // Add new item, but clamp quantity to maximum
      final clampedQuantity = item.quantity > maxQuantityPerItem ? maxQuantityPerItem : item.quantity;
      _items.add(item.copyWith(quantity: clampedQuantity));
    }
    
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }
    
    // Clamp quantity to maximum allowed
    final clampedQuantity = newQuantity > maxQuantityPerItem ? maxQuantityPerItem : newQuantity;
    
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: clampedQuantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  CartItem? getItemById(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    return index >= 0 ? _items[index] : null;
  }

  int getTicketTypeQuantityInCart(int ticketTypeId) {
    return _items
        .where((item) => item.type == CartItemType.ticket && 
                        item.id.startsWith('ticket_${ticketTypeId}_'))
        .fold(0, (sum, item) => sum + item.quantity);
  }
} 