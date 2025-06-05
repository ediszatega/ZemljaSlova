import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/top_branding.dart';
import '../widgets/bottom_navigation.dart';
import '../screens/home.dart';
import '../screens/cart.dart';
import '../screens/voucher_purchase.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<MobileNavigationProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const TopBranding(),
          Expanded(
            child: _buildCurrentScreen(navigationProvider.currentItem),
          ),
          const BottomNavigation(),
        ],
      ),
    );
  }
  
  Widget _buildCurrentScreen(MobileNavigationItem item) {
    switch (item) {
      case MobileNavigationItem.home:
        return const HomeScreen();
      case MobileNavigationItem.cart:
        return const CartScreen();
      case MobileNavigationItem.voucherPurchase:
        return const VoucherPurchaseScreen();
      default:
        return const HomeScreen();
    }
  }
} 