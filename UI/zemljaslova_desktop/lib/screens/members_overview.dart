import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../screens/members_detail_overview.dart';
import '../screens/member_add.dart';

class MembersOverview extends StatelessWidget {
  const MembersOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          // Sidebar
          SidebarWidget(),
          
          // Main content
          Expanded(
            child: MembersContent(),
          ),
        ],
      ),
    );
  }
}

class MembersContent extends StatefulWidget {
  const MembersContent({super.key});

  @override
  State<MembersContent> createState() => _MembersContentState();
}

class _MembersContentState extends State<MembersContent> {
  String _sortOption = 'Ime (A-Z)';
  
  @override
  void initState() {
    super.initState();
    // Load members data
    Future.microtask(() {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers(isUserIncluded: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, left: 80.0, right: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Pregled korisnika',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Build toolbar
          _buildToolbar(),
          
          const SizedBox(height: 24),
          
          // Members grid
          Expanded(
            child: _buildMembersGrid(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search using our new component
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži korisnike',
            borderColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(width: 16),
        
        // Sort dropdown
        ZSDropdown<String>(
          label: 'Sortiraj',
          value: _sortOption,
          width: 180,
          items: const [
            DropdownMenuItem(value: 'Ime (A-Z)', child: Text('Ime (A-Z)')),
            DropdownMenuItem(value: 'Ime (Z-A)', child: Text('Ime (Z-A)')),
            DropdownMenuItem(value: 'Najnoviji', child: Text('Najnoviji')),
            DropdownMenuItem(value: 'Najstariji', child: Text('Najstariji')),
            DropdownMenuItem(value: 'Status', child: Text('Status')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _sortOption = value;
              });
            }
          },
          borderColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 16),
        
        // Filter
        ZSButton(
          onPressed: () {},
          text: 'Postavi filtre',
          label: 'Filtriraj',
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
        const SizedBox(width: 16),
        
        // Add button
        ZSButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MemberAddScreen(),
              ),
            );
          },
          text: 'Dodaj korisnika',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }
  
  Widget _buildMembersGrid() {
    return Consumer<MemberProvider>(
      builder: (ctx, memberProvider, child) {
        if (memberProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (memberProvider.error != null) {
          return Center(
            child: Text(
              'Greška: ${memberProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final members = memberProvider.members;
        
        if (members.isEmpty) {
          return const Center(
            child: Text('Nema korisnika za prikaz.'),
          );
        }
        
        // Sort the members list based on the selected option
        final sortedMembers = List<Member>.from(members);
        switch (_sortOption) {
          case 'Ime (A-Z)':
            sortedMembers.sort((a, b) => a.fullName.compareTo(b.fullName));
            break;
          case 'Ime (Z-A)':
            sortedMembers.sort((a, b) => b.fullName.compareTo(a.fullName));
            break;
          case 'Najnoviji':
            // In a real app, this would sort by creation date
            sortedMembers.sort((a, b) => b.id.compareTo(a.id));
            break;
          case 'Najstariji':
            // In a real app, this would sort by creation date
            sortedMembers.sort((a, b) => a.id.compareTo(b.id));
            break;
          case 'Status':
            // Sort active users first
            sortedMembers.sort((a, b) => b.isActive == a.isActive ? 0 : (b.isActive ? 1 : -1));
            break;
        }
        
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 40,
            mainAxisSpacing: 40,
            childAspectRatio: 0.7,
          ),
          itemCount: sortedMembers.length,
          itemBuilder: (context, index) {
            final member = sortedMembers[index];
            return ZSCard.fromMember(
              context,
              member,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MembersDetailOverview(
                      member: member,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
} 