import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/ticket_type.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/top_branding.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/snackbar_util.dart';

class TicketTypeSelectionScreen extends StatefulWidget {
  final Event event;
  
  const TicketTypeSelectionScreen({
    super.key,
    required this.event,
  });

  @override
  State<TicketTypeSelectionScreen> createState() => _TicketTypeSelectionScreenState();
}

class _TicketTypeSelectionScreenState extends State<TicketTypeSelectionScreen> {
  TicketType? _selectedTicketType;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const TopBranding(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTicketTypesList(),
                  if (_selectedTicketType != null) ...[
                    const SizedBox(height: 24),
                    _buildQuantitySelector(),
                    const SizedBox(height: 24),
                    _buildTotalSection(),
                    const SizedBox(height: 32),
                    _buildAddToCartButton(),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const BottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Odabir ulaznica',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.event.title,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatEventDate(widget.event.startAt),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTypesList() {
    if (widget.event.ticketTypes == null || widget.event.ticketTypes!.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nema dostupnih ulaznica za ovaj događaj',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dostupne ulaznice',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.event.ticketTypes!.map((ticketType) => _buildTicketTypeCard(ticketType)),
      ],
    );
  }

  Widget _buildTicketTypeCard(TicketType ticketType) {
    final isSelected = _selectedTicketType?.id == ticketType.id;
    final currentQty = ticketType.currentQuantity ?? ticketType.initialQuantity;
    final cartProvider = Provider.of<CartProvider>(context, listen: true);
    final inCartQty = cartProvider.getTicketTypeQuantityInCart(ticketType.id);
    final availableQty = currentQty != null ? currentQty - inCartQty : null;
    final isAvailable = availableQty != null && availableQty > 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF28A745) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isAvailable ? () {
          setState(() {
             _selectedTicketType = ticketType;
             _resetQuantityForSelectedTicket();
           });
         } : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Radio<TicketType>(
                    value: ticketType,
                    groupValue: _selectedTicketType,
                    onChanged: isAvailable ? (TicketType? value) {
                      setState(() {
                         _selectedTicketType = value;
                         _resetQuantityForSelectedTicket();
                       });
                     } : null,
                    activeColor: const Color(0xFF28A745),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticketType.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF28A745) : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticketType.price == 0 
                              ? 'Besplatno'
                              : '${ticketType.price.toStringAsFixed(2)} KM',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? const Color(0xFF28A745) : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          availableQty != null
                              ? (isAvailable 
                                  ? 'Dostupno: $availableQty'
                                  : 'Nema na stanju (0)')
                              : 'Dostupno: ${currentQty ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (ticketType.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 48),
                  child: Text(
                    ticketType.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Količina',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: _quantity > 1 ? () {
                    setState(() {
                      _quantity--;
                    });
                  } : null,
                  icon: Icon(
                    Icons.remove,
                    size: 18,
                    color: _quantity > 1 ? Colors.black : Colors.grey.shade400,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  _quantity.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 36,
                height: 36,
                child: IconButton(
                  onPressed: _canIncreaseQuantity() ? () {
                    setState(() {
                      _quantity++;
                    });
                  } : null,
                  icon: Icon(
                    Icons.add,
                    size: 18,
                    color: _canIncreaseQuantity() ? Colors.black : Colors.grey.shade400,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    if (_selectedTicketType == null) return const SizedBox.shrink();
    
    final total = _selectedTicketType!.price * _quantity;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF28A745).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF28A745).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedTicketType!.name} x $_quantity',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                total == 0 
                    ? 'Besplatno'
                    : '${total.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ukupno:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                total == 0 
                    ? 'Besplatno'
                    : '${total.toStringAsFixed(2)} KM',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF28A745),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    if (_selectedTicketType == null) return ZSButton(
      text: 'Nema na stanju',
      backgroundColor: Colors.grey,
      foregroundColor: Colors.white,
      borderColor: Colors.grey,
      onPressed: null,
    );

    final currentQty = _selectedTicketType!.currentQuantity ?? _selectedTicketType!.initialQuantity;
    final cartProvider = Provider.of<CartProvider>(context, listen: true);
    final inCartQty = cartProvider.getTicketTypeQuantityInCart(_selectedTicketType!.id);
    final availableQty = currentQty != null ? currentQty - inCartQty : null;
    final isAvailable = availableQty != null && availableQty > 0;
    
    return ZSButton(
      text: isAvailable ? 'Dodaj u korpu' : 'Nema na stanju',
      backgroundColor: isAvailable ? const Color(0xFF28A745) : Colors.grey,
      foregroundColor: Colors.white,
      borderColor: isAvailable ? const Color(0xFF28A745) : Colors.grey,
      onPressed: isAvailable ? () {
        _addToCart();
      } : null,
    );
  }

  String _formatEventDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} u ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool _canIncreaseQuantity() {
    if (_selectedTicketType == null) return false;
    
    // Check if we have enough stock
    final currentQty = _selectedTicketType!.currentQuantity ?? _selectedTicketType!.initialQuantity;
    final cartProvider = Provider.of<CartProvider>(context, listen: true);
    final inCartQty = cartProvider.getTicketTypeQuantityInCart(_selectedTicketType!.id);
    final availableQty = currentQty != null ? currentQty - inCartQty : null;
    
    if (availableQty != null) {
      return _quantity < availableQty && _quantity < 10;
    }
    
    // If no stock info, limit to 10
    return _quantity < 10;
  }

  void _resetQuantityForSelectedTicket() {
    if (_selectedTicketType == null) {
      _quantity = 1;
      return;
    }

    final currentQty = _selectedTicketType!.currentQuantity ?? _selectedTicketType!.initialQuantity;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final inCartQty = cartProvider.getTicketTypeQuantityInCart(_selectedTicketType!.id);
    final availableQty = currentQty != null ? currentQty - inCartQty : null;
    
    if (availableQty != null && availableQty > 0) {
      _quantity = 1;
    } else {
      _quantity = 1;
    }
  }

  void _addToCart() {
    if (_selectedTicketType == null) return;

    // Check stock availability before adding to cart
    final currentQty = _selectedTicketType!.currentQuantity ?? _selectedTicketType!.initialQuantity;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final inCartQty = cartProvider.getTicketTypeQuantityInCart(_selectedTicketType!.id);
    final availableQty = currentQty != null ? currentQty - inCartQty : null;
    
    if (availableQty != null && availableQty <= 0) {
      SnackBarUtil.showTopSnackBar(context, 'Ulaznica nije na stanju!');
      return;
    }

    // Check if we have enough stock for the requested quantity
    if (availableQty != null && _quantity > availableQty) {
      SnackBarUtil.showTopSnackBar(context, 'Nema dovoljno ulaznica na stanju!');
      return;
    }

    // Create unique ID for the cart item
    final cartItemId = 'ticket_${_selectedTicketType!.id}_${widget.event.id}';
    
    // Create cart item
    final cartItem = CartItem(
      id: cartItemId,
      title: '${widget.event.title} - ${_selectedTicketType!.name}',
      price: _selectedTicketType!.price,
      quantity: _quantity,
      type: CartItemType.ticket,
    );

    cartProvider.addItem(cartItem);

    if (_quantity == 1) {
      SnackBarUtil.showTopSnackBar(context, 'Ulaznica je dodana u korpu! Da biste završili kupovinu otvorite korpu.');
    } else {
      SnackBarUtil.showTopSnackBar(context, 'Ulaznice su dodane u korpu! Da biste završili kupovinu otvorite korpu.');
    }
  }
}