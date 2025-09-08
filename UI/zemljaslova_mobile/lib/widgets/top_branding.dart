import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/authorization.dart';
import '../screens/login_screen.dart';

class TopBranding extends StatelessWidget {
  const TopBranding({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<MobileNavigationProvider>(context);
    final canGoBackProvider = navigationProvider.canGoBack;
    final canGoBackNavigator = Navigator.canPop(context);
    final canGoBack = canGoBackProvider || canGoBackNavigator;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 60,
          child: Stack(
            children: [
              // Show back button if we can go back in our navigation stack
              if (canGoBack)
                Positioned(
                  left: 4,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black87,
                      size: 24,
                    ),
                    onPressed: () {
                      if (canGoBackNavigator) {
                        Navigator.of(context).pop();
                      } 
                      else if (canGoBackProvider) {
                        navigationProvider.goBack();
                      }
                    },
                  ),
                ),
              
              // Centered title
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: canGoBack ? 56.0 : 16.0,
                  ),
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
              ),
              
              // Logout button
              if (Authorization.userId != null)
                Positioned(
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 24,
                    ),
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Odjava'),
        content: const Text('Da li ste sigurni da se želite odjaviti?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Otkaži'),
          ),
          ElevatedButton(
            onPressed: () => _handleLogout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Odjavi se'),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    Navigator.of(context).pop();
    
    // Clear stored credentials
    Authorization.email = '';
    Authorization.password = '';
    
    // Clear auth provider
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    
    // Navigate to login screen and clear all routes
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }
} 