import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import '../providers/membership_provider.dart';
import '../providers/member_provider.dart';
import '../services/payment_service.dart';
import '../widgets/zs_button.dart';
import '../widgets/top_branding.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/mobile_layout.dart';
import '../utils/snackbar_util.dart';
import '../utils/authorization.dart';

class MembershipPurchaseScreen extends StatefulWidget {
  final bool isFromRegistration;
  final bool isFromLogin;
  
  const MembershipPurchaseScreen({
    super.key,
    this.isFromRegistration = false,
    this.isFromLogin = false,
  });

  @override
  State<MembershipPurchaseScreen> createState() => _MembershipPurchaseScreenState();
}

class _MembershipPurchaseScreenState extends State<MembershipPurchaseScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

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
                  _buildMembershipInfo(),
                  const SizedBox(height: 24),
                  _buildBenefitsList(),
                  const SizedBox(height: 32),
                  _buildPurchaseButton(),
                  if (widget.isFromRegistration || widget.isFromLogin) ...[
                    const SizedBox(height: 16),
                    _buildSkipButton(),
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
            'Članstvo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isFromRegistration 
                ? 'Dobrodošli! Ovdje možete aktivirati svoje članstvo'
                : widget.isFromLogin
                    ? 'Aktivirajte svoje članstvo kako biste ostvarili različite pogodnosti!'
                    : 'Aktivirajte svoje članstvo',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF28A745).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF28A745).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.card_membership,
            size: 48,
            color: Color(0xFF28A745),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mjesečno članstvo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28A745),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '15.00 KM',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28A745),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '30 dana aktivnosti',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Šta uključuje članstvo:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(Icons.book, 'Iznajmljivanje knjiga'),
          _buildBenefitItem(Icons.library_books, 'Rezervacije knjiga'),
          _buildBenefitItem(Icons.local_offer, 'Posebne ponude i popusti'),
          _buildBenefitItem(Icons.card_giftcard, 'Nagrade i pokloni'),
          _buildBenefitItem(Icons.group, 'Pristup čitalačkim klubovima'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF28A745),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return Consumer<MembershipProvider>(
      builder: (context, membershipProvider, child) {
        return ZSButton(
          text: _isProcessing ? 'Obrađujem...' : 'Plati 15.00 KM',
          backgroundColor: const Color(0xFF28A745),
          foregroundColor: Colors.white,
          borderColor: const Color(0xFF28A745),
          onPressed: _isProcessing ? null : () => _handlePurchase(membershipProvider),
        );
      },
    );
  }

  Widget _buildSkipButton() {
    return ZSButton(
      text: 'Preskoči za sada',
      backgroundColor: Colors.grey.shade100,
      foregroundColor: Colors.grey.shade700,
      borderColor: Colors.grey.shade300,
      onPressed: () {
        // Navigate to main app (home screen)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MobileLayout(),
          ),
          (route) => false,
        );
      },
    );
  }

  Future<void> _handlePurchase(MembershipProvider membershipProvider) async {
    if (Authorization.userId == null) {
      SnackBarUtil.showTopSnackBar(context, 'Morate biti prijavljeni da biste kupili članstvo');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Get member ID from the current user
      final memberProvider = context.read<MemberProvider>();
      final member = memberProvider.currentMember;
      
      if (member == null) {
        SnackBarUtil.showTopSnackBar(context, 'Greška: Nije moguće dohvatiti podatke o članu');
        return;
      }

      // Create payment intent for membership (15.00 KM)
      final paymentIntent = await _paymentService.createPaymentIntent(15.00);

      if (paymentIntent == null) {
        SnackBarUtil.showTopSnackBar(context, 'Greška pri kreiranju uplate');
        return;
      }

      // Configure payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent.clientSecret,
          merchantDisplayName: 'Zemlja Slova',
          style: ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF28A745),
            ),
          ),
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Payment successful - process the membership creation
      await _processMembershipPayment(member.id, paymentIntent.paymentIntentId, paymentIntent.clientSecret);

      // Show success message and navigate back
      if (mounted) {
        SnackBarUtil.showTopSnackBar(
          context, 
          'Članstvo uspješno aktivirano!',
        );
           
        // Navigate to home screen for all cases
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MobileLayout(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtil.showTopSnackBar(context, 'Greška pri plaćanju: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _processMembershipPayment(int memberId, String paymentIntentId, String clientSecret) async {
    try {
      // Get the payment intent to retrieve the payment method ID
      String? paymentMethodId;
      try {
        final paymentIntent = await Stripe.instance.retrievePaymentIntent(clientSecret);
        paymentMethodId = paymentIntent.paymentMethodId;
      } catch (e) {
        // Fallback - use the payment intent ID itself
        paymentMethodId = paymentIntentId;
      }

      // Process the membership payment through the order system
      await _paymentService.processMembershipPayment(
        memberId: memberId,
        paymentIntentId: paymentIntentId,
        paymentMethodId: paymentMethodId ?? paymentIntentId,
      );

      // Refresh membership data to show the newly created membership
      final membershipProvider = context.read<MembershipProvider>();
      await membershipProvider.getActiveMembership(memberId);
    } catch (e) {
      throw Exception('Greška pri obradi članstva: $e');
    }
  }
}
