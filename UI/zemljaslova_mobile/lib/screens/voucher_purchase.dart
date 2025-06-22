import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/zs_input.dart';
import '../widgets/zs_button.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../utils/snackbar_util.dart';

class VoucherPurchaseScreen extends StatefulWidget {
  const VoucherPurchaseScreen({super.key});

  @override
  State<VoucherPurchaseScreen> createState() => _VoucherPurchaseScreenState();
}

class _VoucherPurchaseScreenState extends State<VoucherPurchaseScreen> {
  String? selectedAmount;
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 24),
          _buildHowItWorksSection(),
          const SizedBox(height: 18),
          _buildBenefitsSection(),
          const SizedBox(height: 32),
          _buildAmountSelectionSection(),
          const SizedBox(height: 16),
          _buildPurchaseButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE3F2FD), // Light blue
            Color(0xFFF3E5F5), // Light purple
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kupi poklon bon, usreći najmilije',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kako poklon bon funkcioniše?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Benefiti',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Odaberi vrijednost kupona',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _buildAmountOption('25 KM'),
            _buildAmountOption('50 KM'),
            _buildAmountOption('100 KM'),
            _buildCustomAmountOption(),
          ],
        ),
        if (selectedAmount == 'custom') ...[
          const SizedBox(height: 16),
          _buildCustomAmountInput(),
        ],
      ],
    );
  }

  Widget _buildAmountOption(String amount) {
    final isSelected = selectedAmount == amount;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = amount;
          // Clear custom amount input when selecting preset amount
          if (amount != 'custom') {
            _customAmountController.clear();
          }
        });
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 50) / 2, // Half width minus padding and spacing
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
        ),
        child: Center(
          child: Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAmountOption() {
    final isSelected = selectedAmount == 'custom';
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = 'custom';
        });
      },
      child: Container(
        width: (MediaQuery.of(context).size.width - 50) / 2, // Half width minus padding and spacing
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
        ),
        child: Center(
          child: Text(
            'Odredi vrijednost',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAmountInput() {
    return ZSInput(
      label: 'Unesite vrijednost',
      controller: _customAmountController,
      keyboardType: TextInputType.number,
      hintText: '75',
      suffixText: 'KM',
    );
  }

  Widget _buildPurchaseButton() {
    return ZSButton(
      text: 'Dodaj u korpu',
      backgroundColor: Colors.green.shade50,
      foregroundColor: Colors.green,
      borderColor: Colors.grey.shade300,
      onPressed: () {
        double voucherAmount;
        String voucherTitle;
        
        if (selectedAmount == 'custom') {
          final customAmountText = _customAmountController.text.trim();
          
          if (customAmountText.isEmpty) {
            _showValidationError('Molimo unesite vrijednost poklon bona.');
            return;
          }
          
          final customAmount = double.tryParse(customAmountText);
          
          if (customAmount == null) {
            _showValidationError('Molimo unesite važeću vrijednost.');
            return;
          }
          
          if (customAmount < 25) {
            _showValidationError('Minimalna vrijednost poklon bona je 25 KM.');
            return;
          }
          
          if (customAmount > 1000) {
            _showValidationError('Maksimalna vrijednost poklon bona je 1000 KM.');
            return;
          }
          
          voucherAmount = customAmount;
          voucherTitle = 'Poklon bon ${customAmount.toInt()} KM';
        } else if (selectedAmount == null) {
          _showValidationError('Molimo odaberite vrijednost poklon bona.');
          return;
        } else {
          final amountText = selectedAmount!.replaceAll(' KM', '');
          voucherAmount = double.parse(amountText);
          voucherTitle = 'Poklon bon $selectedAmount';
        }
        
        // Add voucher to cart
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        final cartItem = CartItem(
          id: 'voucher_${voucherAmount.toInt()}_${DateTime.now().microsecondsSinceEpoch}',
          title: voucherTitle,
          price: voucherAmount,
          quantity: 1,
          type: CartItemType.voucher,
        );
        
        cartProvider.addItem(cartItem);
        _showSuccessMessage('Poklon bon je dodan u korpu! Da biste završili kupovinu otvorite korpu.');
      },
    );
  }

  void _showValidationError(String message) {
    SnackBarUtil.showTopSnackBar(context, message, isError: true);
  }

  void _showSuccessMessage(String message) {
    SnackBarUtil.showTopSnackBar(context, message);
  }
} 