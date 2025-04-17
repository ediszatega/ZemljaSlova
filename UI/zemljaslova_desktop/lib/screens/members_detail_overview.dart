import 'package:flutter/material.dart';
import 'package:zemljaslova_desktop/widgets/zs_button.dart';
import '../models/member.dart';
import '../widgets/sidebar.dart';
import 'members_overview.dart';

class MembersDetailOverview extends StatelessWidget {
  final Member member;
  
  const MembersDetailOverview({
    super.key,
    required this.member,
  });

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
              padding: const EdgeInsets.only(top: 44, left: 80.0, right: 80.0),
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
                              child: member.profileImageUrl != null
                                ? Image.network(
                                    member.profileImageUrl!,
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
                                  member.fullName,
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
                                    color: member.isActive 
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    member.isActive ? 'Aktivan' : 'Neaktivan',
                                    style: TextStyle(
                                      color: member.isActive ? Colors.green : Colors.red,
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
                            DetailRow(label: 'Grad', value: 'Sarajevo'),
                            DetailRow(label: 'Broj telefona', value: '+387 61 123 456'),
                            DetailRow(label: 'Datum kreiranja profila', value: '01.01.2023'),
                            DetailRow(label: 'Datum učlanjenja', value: '15.01.2023'),
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
                        paddingHorizontal: 130,
                        topPadding: 5,
                        onPressed: () {},
                      ),
                      
                      ZSButton(
                        text: 'Uredi korisnika',
                        backgroundColor: Colors.blue.shade50,
                        foregroundColor: Colors.blue,
                        borderColor: Colors.grey.shade300,
                        paddingHorizontal: 150,
                        topPadding: 5,
                        onPressed: () {},
                      ),

                      ZSButton(
                        text: 'Arhiviraj korisnika',
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        borderColor: Colors.grey.shade300,
                        paddingHorizontal: 140,
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