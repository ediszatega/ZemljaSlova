import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../models/shipping_address.dart';
import '../models/voucher.dart';
import '../models/payment_intent.dart';
import '../services/payment_service.dart';
import '../services/voucher_service.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_input.dart';
import '../widgets/top_branding.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/snackbar_util.dart';

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
  final VoucherService _voucherService = VoucherService(ApiService());
  final TextEditingController _voucherCodeController = TextEditingController();
  final TextEditingController _discountCodeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isValidatingVoucher = false;
  bool _isValidatingDiscountCode = false;
  String? _errorMessage;
  Voucher? _appliedVoucher;
  String? _appliedDiscountCode;
  double _discountAmount = 0.0;
  double _orderDiscountAmount = 0.0;
  double _finalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _finalAmount = widget.totalAmount;
  }

  @override
  void dispose() {
    _voucherCodeController.dispose();
    _discountCodeController.dispose();
    super.dispose();
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPaymentSummary(),
                        const SizedBox(height: 24),
                        _buildDiscountCodeSection(),
                        const SizedBox(height: 24),
                        _buildVoucherSection(),
                        const SizedBox(height: 24),
                        _buildShippingInfo(),
                        const SizedBox(height: 32),
                        _buildPaymentButton(),
                        const SizedBox(height: 24),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (_appliedDiscountCode != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popust ($_appliedDiscountCode):',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade600,
                  ),
                ),
                Text(
                  '-${_orderDiscountAmount.toStringAsFixed(2)} BAM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ],
          if (_appliedVoucher != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popust (${_appliedVoucher!.code}):',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade600,
                  ),
                ),
                Text(
                  '-${_discountAmount.toStringAsFixed(2)} BAM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Za plaćanje:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_finalAmount.toStringAsFixed(2)} BAM',
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

  Widget _buildDiscountCodeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_offer,
                color: Colors.orange.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Kod za popust',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (_appliedDiscountCode != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kod "$_appliedDiscountCode" je primijenjen!',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _removeDiscountCode,
                    child: const Text(
                      'Ukloni',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ZSInput(
              controller: _discountCodeController,
              label: 'Unesite kod za popust',
              hintText: 'POPUST20',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _isValidatingDiscountCode
                  ? ZSButton(
                      text: 'Provjera...',
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      onPressed: null,
                    )
                  : ZSButton(
                      text: 'Primijeni kod za popust',
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      onPressed: _validateDiscountCode,
                    ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Text(
                'Kod vaučera',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_appliedVoucher == null) ...[
            ZSInput(
              label: 'Unesite kod vaučera',
              controller: _voucherCodeController,
              hintText: 'ABC123',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ZSButton(
                text: _isValidatingVoucher ? 'Provjera...' : 'Primijeni vaučer',
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                onPressed: _isValidatingVoucher ? null : _validateAndApplyVoucher,
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kupon ${_appliedVoucher!.code} primijenjen (-${_discountAmount.toStringAsFixed(2)} BAM)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _removeVoucher,
                    child: Text(
                      'Ukloni',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            text: _isLoading ? 'Obrađujem plaćanje...' : 'Plati ${_finalAmount.toStringAsFixed(2)} BAM',
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

  Future<void> _validateAndApplyVoucher() async {
    final code = _voucherCodeController.text.trim();
    
    if (code.isEmpty) {
      SnackBarUtil.showTopSnackBar(context, 'Molimo unesite kod kupona', isError: true);
      return;
    }

    setState(() {
      _isValidatingVoucher = true;
    });

    try {
      final voucher = await _voucherService.getVoucherByCode(code);
      
      if (voucher == null) {
        SnackBarUtil.showTopSnackBar(context, 'Kupon nije pronađen', isError: true);
        return;
      }

      if (voucher.isUsed) {
        SnackBarUtil.showTopSnackBar(context, 'Kupon je već iskorišten', isError: true);
        return;
      }

      final now = DateTime.now();
      if (voucher.expirationDate.isBefore(now)) {
        SnackBarUtil.showTopSnackBar(context, 'Kupon je istekao', isError: true);
        return;
      }

      // Calculate discount amount
      final discountAmount = voucher.value > widget.totalAmount 
          ? widget.totalAmount 
          : voucher.value;

      setState(() {
        _appliedVoucher = voucher;
        _discountAmount = discountAmount;
        _finalAmount = widget.totalAmount - discountAmount;
      });

      SnackBarUtil.showTopSnackBar(context, 'Kupon je uspješno primijenjen!');
    } catch (e) {
      SnackBarUtil.showTopSnackBar(context, 'Greška pri validaciji kupona: $e', isError: true);
    } finally {
      setState(() {
        _isValidatingVoucher = false;
      });
    }
  }

  void _removeVoucher() {
    setState(() {
      _appliedVoucher = null;
      _discountAmount = 0.0;
      _finalAmount = widget.totalAmount;
      _voucherCodeController.clear();
    });
    SnackBarUtil.showTopSnackBar(context, 'Kupon je uklonjen');
  }

  Future<void> _validateDiscountCode() async {
    final code = _discountCodeController.text.trim();
    if (code.isEmpty) {
      SnackBarUtil.showTopSnackBar(context, 'Unesite kod za popust', isError: true);
      return;
    }

    setState(() {
      _isValidatingDiscountCode = true;
    });

    try {
      // Call the discount validation API
      final apiService = ApiService();
      final response = await apiService.post('Discount/validate_discount_code/$code', {});
      
      if (response == true) {
        // Get discount details
        final discountResponse = await apiService.get('Discount/get_discount_by_code/$code');
        
        // Calculate order discount amount
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final cartItems = cartProvider.items;
        
        // Calculate total before discount
        final orderTotal = cartItems.fold<double>(
          0.0, 
          (sum, item) => sum + (item.price * item.quantity)
        );
        
        // Calculate discount amount (percentage of order total)
        final discountPercentage = discountResponse['discountPercentage']?.toDouble() ?? 0.0;
        final discountAmount = orderTotal * (discountPercentage / 100);
        
        setState(() {
          _appliedDiscountCode = code;
          _orderDiscountAmount = discountAmount;
          _finalAmount = widget.totalAmount - _discountAmount - _orderDiscountAmount;
        });

        SnackBarUtil.showTopSnackBar(context, 'Kod za popust je uspješno primijenjen!');
      } else {
        SnackBarUtil.showTopSnackBar(context, 'Kod za popust nije valjan ili je istekao', isError: true);
      }
    } catch (e) {
      SnackBarUtil.showTopSnackBar(context, 'Greška pri validaciji koda za popust: $e', isError: true);
    } finally {
      setState(() {
        _isValidatingDiscountCode = false;
      });
    }
  }

  void _removeDiscountCode() {
    setState(() {
      _appliedDiscountCode = null;
      _orderDiscountAmount = 0.0;
      _finalAmount = widget.totalAmount - _discountAmount;
      _discountCodeController.clear();
    });
    SnackBarUtil.showTopSnackBar(context, 'Kod za popust je uklonjen');
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
      PaymentIntentResponse? paymentIntent;
      String? paymentIntentId;
      String? clientSecret;
      
      if (_finalAmount <= 0) {
        // If voucher covers entire amount, skip payment processing
        paymentIntentId = 'voucher_covered_' + DateTime.now().millisecondsSinceEpoch.toString();
        clientSecret = 'voucher_covered';
      } else {
        paymentIntent = await _paymentService.createPaymentIntent(_finalAmount);
        paymentIntentId = paymentIntent.paymentIntentId;
        clientSecret = paymentIntent.clientSecret;

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
      }

      // Process order
      await _processOrder(paymentIntentId, clientSecret);

      // Mark voucher as used if applied
      if (_appliedVoucher != null) {
        await _voucherService.markVoucherAsUsed(_appliedVoucher!.id);
      }

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
      if (clientSecret == 'voucher_covered') {
        // No actual payment, use a placeholder
        paymentMethodId = 'voucher_covered';
      } else {
        try {
          final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
          paymentMethodId = paymentIntent.paymentMethodId;
        } catch (e) {
          // Fallback - use the payment intent ID itself
          paymentMethodId = paymentIntentId;
        }
      }

      print('Processing order with appliedVoucherId: ${_appliedVoucher?.id}, discountAmount: $_discountAmount, discountCode: $_appliedDiscountCode, orderDiscountAmount: $_orderDiscountAmount');
      await _paymentService.processOrder(
        items: cartItems,
        shippingAddress: widget.shippingAddress,
        paymentIntentId: paymentIntentId,
        paymentMethodId: paymentMethodId ?? paymentIntentId,
        appliedVoucherId: _appliedVoucher?.id,
        discountAmount: _discountAmount,
        discountCode: _appliedDiscountCode,
        orderDiscountAmount: _orderDiscountAmount,
      );
    } catch (e) {
      throw Exception('Greška pri obradi porudžbine: $e');
    }
  }
}
