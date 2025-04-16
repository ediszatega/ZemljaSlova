import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

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
            isSelected: navigationProvider.currentItem == NavigationItem.bookSell,
            onTap: () => navigationProvider.setCurrentItem(NavigationItem.bookSell),
          ),
          SidebarMenuItemWidget(
            title: 'Knjige izdavanje',
            icon: Icons.book,
            isSelected: navigationProvider.currentItem == NavigationItem.bookRent,
            onTap: () => navigationProvider.setCurrentItem(NavigationItem.bookRent),
          ),
          SidebarMenuItemWidget(
            title: 'Događaji',
            icon: Icons.event,
            isSelected: navigationProvider.currentItem == NavigationItem.events,
            onTap: () => navigationProvider.setCurrentItem(NavigationItem.events),
          ),
          SidebarMenuItemWidget(
            title: 'Korisnici',
            icon: Icons.people,
            isSelected: navigationProvider.currentItem == NavigationItem.members,
            onTap: () => navigationProvider.setCurrentItem(NavigationItem.members),
          ),
          SidebarMenuItemWidget(
            title: 'Izvještaji',
            icon: Icons.bar_chart,
            isSelected: navigationProvider.currentItem == NavigationItem.reports,
            onTap: () => navigationProvider.setCurrentItem(NavigationItem.reports),
          ),
          SidebarMenuItemWidget(
            title: 'Profil',
            icon: Icons.person,
            isSelected: navigationProvider.currentItem == NavigationItem.profile,
            onTap: () => navigationProvider.setCurrentItem(NavigationItem.profile),
          ),
        ],
      ),
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