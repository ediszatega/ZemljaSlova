import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../screens/books_sell_overview.dart';
import '../screens/book_rent_overview.dart';
import '../screens/events_overview.dart';
import '../screens/members_overview.dart';
import '../screens/reports_overview.dart';
import '../screens/profile_overview.dart';
import '../screens/authors_overview.dart';
import '../screens/employees_overview.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    
    return Container(
      width: 250,
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Zemlja slova',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Menu items
          SidebarMenuItemWidget(
            title: 'Knjige prodaja',
            icon: Icons.shopping_cart,
            isSelected: navigationProvider.currentItem == NavigationItem.booksSell,
            onTap: () => _navigateToScreen(context, NavigationItem.booksSell),
          ),
          SidebarMenuItemWidget(
            title: 'Knjige izdavanje',
            icon: Icons.book,
            isSelected: navigationProvider.currentItem == NavigationItem.bookRent,
            onTap: () => _navigateToScreen(context, NavigationItem.bookRent),
          ),
          SidebarMenuItemWidget(
            title: 'Događaji',
            icon: Icons.event,
            isSelected: navigationProvider.currentItem == NavigationItem.events,
            onTap: () => _navigateToScreen(context, NavigationItem.events),
          ),
          SidebarMenuItemWidget(
            title: 'Autori',
            icon: Icons.person_outline,
            isSelected: navigationProvider.currentItem == NavigationItem.authors,
            onTap: () => _navigateToScreen(context, NavigationItem.authors),
          ),
          SidebarMenuItemWidget(
            title: 'Korisnici',
            icon: Icons.people,
            isSelected: navigationProvider.currentItem == NavigationItem.members,
            onTap: () => _navigateToScreen(context, NavigationItem.members),
          ),
          SidebarMenuItemWidget(
            title: 'Članarine',
            icon: Icons.card_membership,
            isSelected: navigationProvider.currentItem == NavigationItem.memberships,
            onTap: () => _navigateToScreen(context, NavigationItem.memberships),
          ),
          SidebarMenuItemWidget(
            title: 'Uposlenici',
            icon: Icons.badge,
            isSelected: navigationProvider.currentItem == NavigationItem.employees,
            onTap: () => _navigateToScreen(context, NavigationItem.employees),
          ),
          SidebarMenuItemWidget(
            title: 'Vaučeri',
            icon: Icons.card_giftcard,
            isSelected: navigationProvider.currentItem == NavigationItem.vouchers,
            onTap: () => _navigateToScreen(context, NavigationItem.vouchers),
          ),
          SidebarMenuItemWidget(
            title: 'Izvještaji',
            icon: Icons.bar_chart,
            isSelected: navigationProvider.currentItem == NavigationItem.reports,
            onTap: () => _navigateToScreen(context, NavigationItem.reports),
          ),
          SidebarMenuItemWidget(
            title: 'Profil',
            icon: Icons.person,
            isSelected: navigationProvider.currentItem == NavigationItem.profile,
            onTap: () => _navigateToScreen(context, NavigationItem.profile),
          ),
        ],
      ),
    );
  }
  
  void _navigateToScreen(BuildContext context, NavigationItem item) {
    // First update the navigation provider
    Provider.of<NavigationProvider>(context, listen: false).setCurrentItem(item);
    
    // Then navigate to the new screen using named routes
    String routeName;
    
    switch (item) {
      case NavigationItem.booksSell:
        routeName = '/books-sell';
        break;
      case NavigationItem.bookRent:
        routeName = '/book-rent';
        break;
      case NavigationItem.events:
        routeName = '/events';
        break;
      case NavigationItem.members:
        routeName = '/members';
        break;
      case NavigationItem.memberships:
        routeName = '/memberships';
        break;
      case NavigationItem.reports:
        routeName = '/reports';
        break;
      case NavigationItem.profile:
        routeName = '/profile';
        break;
      case NavigationItem.authors:
        routeName = '/authors';
        break;
      case NavigationItem.employees:
        routeName = '/employees';
        break;
      case NavigationItem.vouchers:
        routeName = '/vouchers';
        break;
    }
    
    // Use pushNamedAndRemoveUntil to clear the navigation stack
    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false, // Remove all previous routes
    );
  }
}

class SidebarMenuItemWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  
  const SidebarMenuItemWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? Colors.grey.withOpacity(0.2) : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 