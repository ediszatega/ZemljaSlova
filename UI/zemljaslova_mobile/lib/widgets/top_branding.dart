import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

class TopBranding extends StatelessWidget {
  const TopBranding({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<MobileNavigationProvider>(context);
    final canGoBack = navigationProvider.canGoBack;
    
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
                    onPressed: () => navigationProvider.goBack(),
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
            ],
          ),
        ),
      ),
    );
  }
} 