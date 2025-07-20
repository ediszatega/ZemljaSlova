import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zemljaslova_desktop/widgets/zs_button.dart';
import '../models/member.dart';
import '../widgets/sidebar.dart';
import '../widgets/permission_guard.dart';
import '../providers/user_provider.dart';
import '../providers/member_provider.dart';
import '../providers/membership_provider.dart';
import '../services/user_service.dart';
import 'members_overview.dart';
import 'member_edit.dart';
import 'change_password_screen.dart';
import 'membership_add.dart';

class MembersDetailOverview extends StatefulWidget {
  final Member member;
  
  const MembersDetailOverview({
    super.key,
    required this.member,
  });

  @override
  State<MembersDetailOverview> createState() => _MembersDetailOverviewState();
}

class _MembersDetailOverviewState extends State<MembersDetailOverview> {
  late Member _member;
  bool _loadingMembership = false;
  String? _membershipStatus;
  bool? _hasMembershipActive;
  
  @override
  void initState() {
    super.initState();
    _member = widget.member;
    _loadMembershipStatus();
  }

  Future<void> _loadMembershipStatus() async {
    setState(() {
      _loadingMembership = true;
    });

    try {
      final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
      final activeMembership = await membershipProvider.getActiveMembership(_member.id);
      
      setState(() {
        if (activeMembership != null) {
          _hasMembershipActive = activeMembership.isActive;
          final daysRemaining = activeMembership.daysRemaining;
          if (daysRemaining > 0) {
            _membershipStatus = 'Aktivna (još $daysRemaining dana)';
          } else {
            _membershipStatus = 'Nema aktivnu članarinu';
          }
        } else {
          _hasMembershipActive = false;
          _membershipStatus = 'Nema aktivnu članarinu';
        }
        _loadingMembership = false;
      });
    } catch (e) {
      setState(() {
        _hasMembershipActive = false;
        _membershipStatus = 'Greška pri učitavanju';
        _loadingMembership = false;
      });
    }
  }

  Future<void> handleMemberDeleted() async {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izbriši korisnika'),
        content: Text(
          'Da li ste sigurni da želite izbrisati korisnika ${_member.fullName}?\n\n'
          'Ova akcija će trajno obrisati korisnika i sve povezane podatke.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Izbriši'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final success = await memberProvider.deleteMember(_member.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Korisnik je uspješno izbrisan'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/members',
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Greška prilikom brisanja korisnika'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 44, left: 80.0, right: 80.0, bottom: 44.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/members',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Nazad na pregled korisnika'),
                    ),
                    const SizedBox(height: 24),
                    
                    // Header
                    const Text(
                      'Pregled detalja o korisniku',
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
                                child: _member.profileImageUrl != null
                                  ? Image.network(
                                      _member.profileImageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
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
                                    _member.fullName,
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
                                      color: _loadingMembership 
                                          ? Colors.grey.shade50
                                          : (_hasMembershipActive == true)
                                              ? Colors.green.shade50
                                              : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _loadingMembership 
                                          ? 'Učitavam...'
                                          : (_hasMembershipActive == true) 
                                              ? 'Aktivan' 
                                              : 'Neaktivan',
                                      style: TextStyle(
                                        color: _loadingMembership 
                                            ? Colors.grey.shade600
                                            : (_hasMembershipActive == true) 
                                                ? Colors.green 
                                                : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // User details section
                              const Text(
                                'Detalji o korisniku',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Detail rows
                              DetailRow(label: 'Email', value: _member.email),
                              if (_member.gender != null)
                                DetailRow(label: 'Spol', value: _member.gender!),
                              DetailRow(
                                label: 'Datum rođenja', 
                                value: '${_member.dateOfBirth.day}.${_member.dateOfBirth.month}.${_member.dateOfBirth.year}'
                              ),
                              DetailRow(
                                label: 'Datum učlanjenja', 
                                value: '${_member.joinedAt.day}.${_member.joinedAt.month}.${_member.joinedAt.year}'
                              ),
                              DetailRow(
                                label: 'Status članarine', 
                                value: _loadingMembership 
                                    ? 'Učitavam...' 
                                    : _membershipStatus ?? 'Nepoznato'
                              ),
                              DetailRow(label: 'Broj aktivnih mjeseci', value: '3'),
                              DetailRow(label: 'Broj kupljenih knjiga', value: '5'),
                              DetailRow(label: 'Broj iznajmljenih knjiga', value: '2'),
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
                          text: 'Evidentiraj članarinu',
                          backgroundColor: Colors.green.shade50,
                          foregroundColor: Colors.green,
                          borderColor: Colors.grey.shade300,
                          width: 410,
                          topPadding: 5,
                          onPressed: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => MembershipAddScreen(
                                  preselectedMember: _member,
                                ),
                              ),
                            );
                            
                            // Optionally refresh data if needed
                            if (result == true) {
                              _loadMembershipStatus();
                            }
                          },
                        ),
                        
                        ZSButton(
                          text: 'Uredi korisnika',
                          backgroundColor: Colors.blue.shade50,
                          foregroundColor: Colors.blue,
                          borderColor: Colors.grey.shade300,
                          width: 410,
                          topPadding: 5,
                          onPressed: () async {
                            final updatedMember = await Navigator.of(context).push<Member>(
                              MaterialPageRoute(
                                builder: (context) => MemberEditScreen(memberId: _member.id),
                              ),
                            );
                            
                            if (updatedMember != null) {
                              setState(() {
                                _member = updatedMember;
                              });
                            }
                          },
                        ),

                        ZSButton(
                          text: 'Promijeni lozinku',
                          backgroundColor: Colors.orange.shade50,
                          foregroundColor: Colors.orange,
                          borderColor: Colors.grey.shade300,
                          width: 410,
                          topPadding: 5,
                          onPressed: () async {
                            final userService = Provider.of<UserProvider>(context, listen: false).userService;
                            
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                  create: (_) => UserProvider(userService),
                                  child: ChangePasswordScreen(userId: _member.userId),
                                ),
                              ),
                            );
                          },
                        ),

                        CanDeleteUsers(
                          child: ZSButton(
                            text: 'Izbriši korisnika',
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            borderColor: Colors.grey.shade300,
                            width: 410,
                            topPadding: 5,
                            onPressed: handleMemberDeleted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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

class ActionButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onPressed;
  
  const ActionButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: backgroundColor == Colors.green.shade50 
              ? Colors.green 
              : backgroundColor == Colors.blue.shade50
                  ? Colors.blue
                  : Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(text),
      ),
    );
  }
} 