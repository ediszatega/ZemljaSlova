import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';

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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<MemberProvider>(context, listen: false).fetchMembers();
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
          
          // Toolbar
          Row(
            children: [
              // Search
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        'Pretraži',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Pretraži',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Sort
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Sortiraj',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: const [
                        Text('Sortiraj'),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Filter
              ZSButton(
                onPressed: () {},
                text: 'Postavi filtre',
                label: 'Filtriraj',
                borderColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 16),
              
              // Add button
              ZSButton(
                onPressed: () {},
                text: 'Dodaj korisnika',
                backgroundColor: const Color(0xFFE5FFEE),
                foregroundColor: Colors.green,
                borderColor: Colors.grey.shade300,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Members grid
          Expanded(
            child: Consumer<MemberProvider>(
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
                
                return GridView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 40,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return ZSCard(member: members[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 