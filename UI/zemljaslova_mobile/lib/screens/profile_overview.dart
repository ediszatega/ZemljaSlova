import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/member_provider.dart';
import '../providers/membership_provider.dart';
import '../models/member.dart';
import '../utils/authorization.dart';
import '../screens/login_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/membership_purchase_screen.dart';
import '../widgets/zs_button.dart';
import '../services/user_service.dart';

class ProfileOverview extends StatefulWidget {
  const ProfileOverview({super.key});

  @override
  State<ProfileOverview> createState() => _ProfileOverviewState();
}

class _ProfileOverviewState extends State<ProfileOverview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemberData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load membership data when member data is available
    final memberProvider = context.read<MemberProvider>();
    if (memberProvider.currentMember != null) {
      _loadMembershipData();
    }
  }

  void _loadMemberData() {
    final memberProvider = context.read<MemberProvider>();
    final membershipProvider = context.read<MembershipProvider>();
    
    if (Authorization.userId != null) {
      memberProvider.getMemberByUserId(Authorization.userId!);
    }
  }

  void _loadMembershipData() {
    final memberProvider = context.read<MemberProvider>();
    final membershipProvider = context.read<MembershipProvider>();
    
    if (memberProvider.currentMember != null) {
      membershipProvider.getActiveMembership(memberProvider.currentMember!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberProvider>(
      builder: (context, memberProvider, child) {
        if (memberProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final member = memberProvider.currentMember;
        
        if (member == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Greška pri učitavanju podataka',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  memberProvider.error ?? 'Nepoznata greška',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMemberData,
                  child: const Text('Pokušaj ponovo'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildProfileCard(context, member),
              const SizedBox(height: 24),
              _buildMembershipCard(context, member),
              const SizedBox(height: 24),
              _buildPersonalInfoCard(context, member),
              const SizedBox(height: 24),
              _buildActionButtons(context),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return const Text(
      'Moj profil',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, Member member) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: member.profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      member.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            member.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          
          // Email
          Text(
            member.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: member.isActive ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              member.isActive ? 'Aktivan' : 'Neaktivan',
              style: TextStyle(
                color: member.isActive ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(BuildContext context, Member member) {
    return Consumer<MembershipProvider>(
      builder: (context, membershipProvider, child) {
        final activeMembership = membershipProvider.activeMembership;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Članstvo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (activeMembership != null && activeMembership.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Aktivno',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Neaktivno',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (activeMembership != null && activeMembership.isActive) ...[
                _buildInfoRow('Status', 'Aktivno'),
                _buildInfoRow('Početak', _formatDate(activeMembership.startDate)),
                _buildInfoRow('Kraj', _formatDate(activeMembership.endDate)),
                _buildInfoRow('Preostalo dana', '${activeMembership.daysRemaining}'),
              ] else ...[
                const Text(
                  'Nemate aktivno članstvo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ZSButton(
                  text: 'Aktiviraj članstvo',
                  onPressed: () => _navigateToMembershipPurchase(context),
                  backgroundColor: const Color(0xFF28A745),
                  foregroundColor: Colors.white,
                  borderColor: const Color(0xFF28A745),
                  borderRadius: 8,
                  paddingVertical: 12,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  topPadding: 0,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _navigateToMembershipPurchase(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MembershipPurchaseScreen(),
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, Member member) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Podaci o korisniku',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Datum rođenja', _formatDate(member.dateOfBirth)),
          _buildInfoRow('Spol', _formatGender(member.gender)),
          _buildInfoRow('Datum registracije', _formatDate(member.joinedAt)),
        ],
      ),
    );
  }



  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Change Password Button
        ZSButton(
          text: 'Promijeni lozinku',
          onPressed: () async {
            final userService = UserService(Provider.of<AuthProvider>(context, listen: false).apiService);
            
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider(
                  create: (_) => UserProvider(userService),
                  child: const ChangePasswordScreen(),
                ),
              ),
            );
          },
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.blue,
          borderColor: Colors.blue.shade200,
          borderWidth: 1,
          borderRadius: 8,
          paddingVertical: 16,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          topPadding: 0,
        ),
        
        // Edit Profile Button
        ZSButton(
          text: 'Uredi profil',
          onPressed: () {
            // TODO: Navigate to edit profile screen
          },
          backgroundColor: Colors.green.shade50,
          foregroundColor: Colors.green,
          borderColor: Colors.green.shade200,
          borderWidth: 1,
          borderRadius: 8,
          paddingVertical: 16,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          topPadding: 12,
        ),
        
        // Logout Button
        ZSButton(
          text: 'Odjavi se',
          onPressed: () => _showLogoutDialog(context),
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red,
          borderColor: Colors.red.shade200,
          borderWidth: 1,
          borderRadius: 8,
          paddingVertical: 16,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          topPadding: 12,
        ),
      ],
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
    Navigator.of(context).pop(); // Close dialog
    
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatGender(String? gender) {
    if (gender == null) return 'Nije navedeno';
    
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Muški';
      case 'female':
        return 'Ženski';
      default:
        return gender;
    }
  }
} 