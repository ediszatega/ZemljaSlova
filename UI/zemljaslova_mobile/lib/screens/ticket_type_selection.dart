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
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF28A745) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTicketType = ticketType;
            _quantity = 1; // Reset quantity when selecting new ticket type
          });
        },
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
                    onChanged: (TicketType? value) {
                      setState(() {
                        _selectedTicketType = value;
                        _quantity = 1;
                      });
                    },
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
                  onPressed: _quantity < 10 ? () { // Max quantity limit of 10
                    setState(() {
                      _quantity++;
                    });
                  } : null,
                  icon: Icon(
                    Icons.add,
                    size: 18,
                    color: _quantity < 10 ? Colors.black : Colors.grey.shade400,
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
    return ZSButton(
      text: 'Dodaj u korpu',
      backgroundColor: const Color(0xFF28A745),
      foregroundColor: Colors.white,
      borderColor: const Color(0xFF28A745),
      onPressed: _selectedTicketType != null ? () {
        _addToCart();
      } : null,
    );
  }

  String _formatEventDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} u ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _addToCart() {
    if (_selectedTicketType == null) return;

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

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(cartItem);

    if (_quantity == 1) {
      SnackBarUtil.showTopSnackBar(context, 'Ulaznica je dodana u korpu! Da biste završili kupovinu otvorite korpu.');
    } else {
      SnackBarUtil.showTopSnackBar(context, 'Ulaznice su dodane u korpu! Da biste završili kupovinu otvorite korpu.');
    }
  }
}