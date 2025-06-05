import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../widgets/zs_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  
  static const int maxQuantityPerItem = 10;

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        if (cartProvider.isEmpty) {
          return _buildEmptyCart(context);
        }
        
        return Column(
          children: [
            Expanded(
              child: _buildCartItems(context, cartProvider),
            ),
            _buildCartSummary(context, cartProvider),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Vaša korpa je prazna',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dodajte neke proizvode da biste počeli kupovinu',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, CartProvider cartProvider) {
    return ListView.separated(
      padding: const EdgeInsets.all(12.0),
      itemCount: cartProvider.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final item = cartProvider.items[index];
        return _buildCartItemCard(context, item, cartProvider);
      },
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item, CartProvider cartProvider) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getItemTypeColor(item.type),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getItemTypeIcon(item.type),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.price.toStringAsFixed(0)} KM',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showRemoveItemDialog(context, item, cartProvider),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        _buildQuantityButton(
                          context,
                          Icons.remove,
                          () => cartProvider.updateItemQuantity(item.id, item.quantity - 1),
                          enabled: item.quantity > 1,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Text(
                            item.quantity.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildQuantityButton(
                          context,
                          Icons.add,
                          () => cartProvider.updateItemQuantity(item.id, item.quantity + 1),
                          enabled: item.quantity < maxQuantityPerItem,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${item.totalPrice.toStringAsFixed(0)} KM',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(BuildContext context, IconData icon, VoidCallback onPressed, {required bool enabled}) {
    return Container(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.black : Colors.grey.shade400,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ukupno stavki: ${cartProvider.itemCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${cartProvider.totalPrice.toStringAsFixed(0)} KM',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ZSButton(
                    text: 'Očisti korpu',
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    borderColor: Colors.red.shade200,
                    paddingHorizontal: 5,
                    onPressed: () => _showClearCartDialog(context, cartProvider),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ZSButton(
                    text: 'Nastavi na plaćanje',
                    backgroundColor: Colors.green.shade50,
                    foregroundColor: Colors.green,
                    borderColor: Colors.green.shade200,
                    onPressed: () {
                      // TODO: Implement checkout functionality
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getItemTypeColor(CartItemType type) {
    switch (type) {
      case CartItemType.voucher:
        return Colors.purple.shade200;
      case CartItemType.book:
        return Colors.blue.shade200;
      case CartItemType.membership:
        return Colors.green.shade200;
      case CartItemType.ticket:
        return Colors.red.shade200;
    }
  }

  IconData _getItemTypeIcon(CartItemType type) {
    switch (type) {
      case CartItemType.voucher:
        return Icons.card_giftcard;
      case CartItemType.book:
        return Icons.book;
      case CartItemType.membership:
        return Icons.card_membership;
      case CartItemType.ticket:
        return Icons.event_seat;
    }
  }

  void _showRemoveItemDialog(BuildContext context, CartItem item, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ukloni stavku'),
          content: Text('Da li ste sigurni da želite ukloniti "${item.title}" iz korpe?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.removeItem(item.id);
                Navigator.of(context).pop();
              },
              child: const Text('Ukloni', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Očisti korpu'),
          content: const Text('Da li ste sigurni da želite obrisati sve stavke iz korpe?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Otkaži'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.of(context).pop();
              },
              child: const Text('Obriši sve', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
} 