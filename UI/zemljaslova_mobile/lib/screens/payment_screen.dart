import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../models/shipping_address.dart';
import '../services/payment_service.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/top_branding.dart';
import '../widgets/bottom_navigation.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final ShippingAddress shippingAddress;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
    required this.shippingAddress,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const TopBranding(),
          Expanded(
            child: _errorMessage != null
                ? _buildErrorView()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPaymentSummary(),
                        const SizedBox(height: 24),
                        _buildShippingInfo(),
                        const SizedBox(height: 32),
                        _buildPaymentButton(),
                        const SizedBox(height: 24), // Extra padding for bottom navigation
                      ],
                    ),
                  ),
          ),
          const BottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Greška',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ZSButton(
              text: 'Pokušaj ponovo',
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                // Reload the page to reinitialize
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      totalAmount: widget.totalAmount,
                      shippingAddress: widget.shippingAddress,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Pregled plaćanja',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ukupan iznos:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.totalAmount.toStringAsFixed(2)} BAM',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sigurno plaćanje putem platforme Stripe',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              const Text(
                'Adresa za dostavu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.shippingAddress.fullName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.shippingAddress.fullAddress,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tel: ${widget.shippingAddress.phoneNumber}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ZSButton(
            text: _isLoading ? 'Obrađujem plaćanje...' : 'Plati ${widget.totalAmount.toStringAsFixed(2)} BAM',
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            onPressed: _isLoading ? null : _handlePayment,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.security, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vaši podaci su sigurni uz platformu za plaćanje Stripe',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handlePayment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check authentication first
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = await authProvider.checkAuthStatus();
      
      if (!isLoggedIn) {
        throw Exception('Morate biti prijavljeni da biste izvršili plaćanje');
      }

      // Get cart items
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final cartItems = cartProvider.items;

      if (cartItems.isEmpty) {
        throw Exception('Korpa je prazna');
      }

      // Create payment intent
      final paymentIntent = await _paymentService.createPaymentIntent(widget.totalAmount);

      // Configure payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: 'Zemlja Slova',
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.green,
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful - get the payment intent details to retrieve payment method
      await _processOrder(paymentIntent.paymentIntentId, paymentIntent.clientSecret);

      // Show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plaćanje uspješno! Vaša porudžbina je obrađena.'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear cart and navigate back
        cartProvider.clearCart();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Greška pri plaćanju: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processOrder(String paymentIntentId, String clientSecret) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final cartItems = cartProvider.items;

      // Get the payment intent to retrieve the payment method ID
      String? paymentMethodId;
      try {
        final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
        paymentMethodId = paymentIntent.paymentMethodId;
      } catch (e) {
        // Fallback - use the payment intent ID itself
        paymentMethodId = paymentIntentId;
      }

      await _paymentService.processOrder(
        items: cartItems,
        shippingAddress: widget.shippingAddress,
        paymentIntentId: paymentIntentId,
        paymentMethodId: paymentMethodId ?? paymentIntentId,
      );
    } catch (e) {
      throw Exception('Greška pri obradi porudžbine: $e');
    }
  }
}
