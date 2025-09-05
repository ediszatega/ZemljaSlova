import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/image_display_widget.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/change_password_screen.dart';
import '../screens/profile_edit.dart';
import '../services/user_service.dart';
import '../utils/authorization.dart';

class ProfileOverview extends StatefulWidget {
  const ProfileOverview({super.key});

  @override
  State<ProfileOverview> createState() => _ProfileOverviewState();
}

class _ProfileOverviewState extends State<ProfileOverview> {
  @override
  void initState() {
    super.initState();
    // Load user profile data when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadCurrentUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  if (userProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (userProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Greška: ${userProvider.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              userProvider.loadCurrentUserProfile();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Pokušaj ponovo'),
                          ),
                        ],
                      ),
                    );
                  }

                  final currentUser = userProvider.currentUserProfile;
                  
                  if (currentUser == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nema dostupnih podataka o korisniku.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              userProvider.loadCurrentUserProfile();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Učitaj ponovo'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Success message if available
                      if (userProvider.successMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border.all(color: Colors.green.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  userProvider.successMessage!,
                                  style: TextStyle(color: Colors.green.shade700),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.green.shade600),
                                onPressed: () {
                                  userProvider.resetMessages();
                                },
                              ),
                            ],
                          ),
                        ),
                      
                      // Main content
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await userProvider.refreshUserProfile();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                          child: ImageDisplayWidget.profile(
                                            imageUrl: currentUser['profileImageUrl'],
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
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
                                          DetailRow(label: 'Spol', value: currentUser['gender'] as String),
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
                                      onPressed: () async {
                                        // Check if userId is available
                                        if (Authorization.userId == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Greška: Korisnički ID nije dostupan. Molimo se ponovno prijavite.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        
                                        final userService = UserService(Provider.of<AuthProvider>(context, listen: false).apiService);
                                        
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ChangeNotifierProvider(
                                              create: (_) => UserProvider(userService),
                                              child: ChangePasswordScreen(userId: Authorization.userId!),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    
                                    ZSButton(
                                      text: 'Uredi profil',
                                      backgroundColor: Colors.green.shade50,
                                      foregroundColor: Colors.green,
                                      borderColor: Colors.grey.shade300,
                                      width: 410,
                                      topPadding: 5,
                                      onPressed: () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const ProfileEditScreen(),
                                          ),
                                        );
                                        
                                        // Refresh the profile data when returning from edit screen
                                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                                        await userProvider.loadCurrentUserProfile();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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