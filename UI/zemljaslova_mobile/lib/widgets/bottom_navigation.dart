import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/cart_provider.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<MobileNavigationProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Container(
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
        child: Container(
          height: 70,
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            top: 8.0,
            bottom: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home,
                label: 'Početna',
                isSelected: navigationProvider.currentItem == MobileNavigationItem.home,
                onTap: () => navigationProvider.setCurrentItem(MobileNavigationItem.home),
              ),
              _buildNavItemWithBadge(
                context,
                icon: Icons.shopping_cart,
                label: 'Korpa',
                isSelected: navigationProvider.currentItem == MobileNavigationItem.cart,
                badgeCount: cartProvider.itemCount,
                onTap: () => navigationProvider.setCurrentItem(MobileNavigationItem.cart),
              ),
              _buildNavItem(
                context,
                icon: Icons.favorite,
                label: 'Favoriti',
                isSelected: false,
                onTap: () => navigationProvider.setCurrentItem(MobileNavigationItem.home),
              ),
              _buildNavItem(
                context,
                icon: Icons.person,
                label: 'Profil',
                isSelected: false,
                onTap: () => navigationProvider.setCurrentItem(MobileNavigationItem.home),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = isSelected 
        ? Theme.of(context).primaryColor 
        : Colors.grey.shade600;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    final color = isSelected 
        ? Theme.of(context).primaryColor 
        : Colors.grey.shade600;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.only(right: 0, top: 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -3,
                        top: -7,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : badgeCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 