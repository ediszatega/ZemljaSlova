import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBox(),
          
          const SizedBox(height: 24),

          _buildNavigationTabs(context),
        ],
      ),
    );
  }

  Widget _buildWelcomeBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dobrodošli,',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'uplovi u svijet knjiga',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'i uživaj u našim uslugama',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Image.asset(
              'assets/books_home.png',
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs(BuildContext context) {
    return Column(
      children: [
        _buildTabItem(
          context,
          title: 'Pregled knjiga na prodaju',
          icon: Icons.shopping_cart_outlined,
          onTap: () {
            // TODO: Navigate to books for sale
          },
        ),
        const SizedBox(height: 12),
        _buildTabItem(
          context,
          title: 'Pregled knjiga za iznajmljivanje',
          icon: Icons.book_outlined,
          onTap: () {
            // TODO: Navigate to books for rent
          },
        ),
        const SizedBox(height: 12),
        _buildTabItem(
          context,
          title: 'Pregled događaja',
          icon: Icons.event_outlined,
          onTap: () {
            // TODO: Navigate to events
          },
        ),
        const SizedBox(height: 12),
        _buildTabItem(
          context,
          title: 'Kupi poklon bon',
          icon: Icons.card_giftcard_outlined,
          onTap: () {
            // TODO: Navigate to gift card purchase
          },
        ),
      ],
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
