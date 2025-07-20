import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

class ProfileOverview extends StatelessWidget {
  const ProfileOverview({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock current user data
    final currentUser = {
      'firstName': 'Admin',
      'lastName': 'Korisnik',
      'email': 'admin@zemljaslova.ba',
      'position': 'Administrator',
      'joinDate': '01.01.2023',
      'lastLogin': '15.06.2024',
      'phoneNumber': '+387 61 123 456',
      'address': 'Sarajevo, Bosna i Hercegovina',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          const SidebarWidget(),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 100, left: 80.0, right: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Moj profil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Main content area with profile and details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column - Profile image
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Center(
                              child: const Icon(
                                Icons.person,
                                size: 120,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 40),
                      
                      // Right column - User details
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User name and status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${currentUser['firstName']} ${currentUser['lastName']}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16, 
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    currentUser['position'] as String,
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 30),
                            
                            // User details section
                            const Text(
                              'Lični podaci',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Detail rows
                            DetailRow(label: 'Email', value: currentUser['email'] as String),
                            DetailRow(label: 'Broj telefona', value: currentUser['phoneNumber'] as String),
                            DetailRow(label: 'Adresa', value: currentUser['address'] as String),
                            DetailRow(label: 'Datum registracije', value: currentUser['joinDate'] as String),
                            DetailRow(label: 'Zadnja prijava', value: currentUser['lastLogin'] as String),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action buttons
                  Column(
                    children: [
                      ZSButton(
                        text: 'Promijeni lozinku',
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue,
                        borderColor: Colors.grey.shade300,
                        width: 410,
                        topPadding: 5,
                        onPressed: () {},
                      ),
                      
                      ZSButton(
                        text: 'Uredi profil',
                        backgroundColor: Colors.green.shade50,
                        foregroundColor: Colors.green,
                        borderColor: Colors.grey.shade300,
                        width: 410,
                        topPadding: 5,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 