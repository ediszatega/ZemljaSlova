import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/member.dart';
import '../providers/member_provider.dart';
import '../providers/membership_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_card.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/empty_state.dart';
import '../widgets/pagination_controls_widget.dart';
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

class _MembersContentState extends State<MembersContent> with WidgetsBindingObserver {
  String _sortOption = 'Ime (A-Z)';
  Map<int, bool> _membershipStatus = {}; // Track membership status for each member
  bool _loadingMembershipStatuses = false;
  bool _membershipStatusesLoaded = false; // Track if membership statuses have been loaded
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    // Register as an observer to detect when the app regains focus
    WidgetsBinding.instance.addObserver(this);
    _loadMembers();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadMembers();
    }
  }
  
  void _loadMembers() {
    // Load members data using pagination
    Future.microtask(() {
      Provider.of<MemberProvider>(context, listen: false).refresh(isUserIncluded: true);
      _loadMembershipStatuses();
    });
  }

  Future<void> _loadMembershipStatuses() async {
    setState(() {
      _loadingMembershipStatuses = true;
      _membershipStatusesLoaded = false;
    });

    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    
    // Wait for members to load first
    await Future.delayed(const Duration(milliseconds: 500));
    
    final members = memberProvider.members;
    final Map<int, bool> statuses = {};
    
    for (final member in members) {
      try {
        final activeMembership = await membershipProvider.getActiveMembership(member.id);
        statuses[member.id] = activeMembership != null && activeMembership.isActive;
      } catch (e) {
        statuses[member.id] = false; // Default to inactive on error
      }
    }
    
    setState(() {
      _membershipStatus = statuses;
      _loadingMembershipStatuses = false;
      _membershipStatusesLoaded = true;
    });
  }

  Future<void> _refreshMembershipStatuses() async {
    await _loadMembershipStatuses();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0, left: 80.0, right: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Pregled korisnika',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_loadingMembershipStatuses) ...[
                const SizedBox(width: 16),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Učitavanje statusa članarina...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
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
            ).then((_) {
              // Refresh members when returning from add screen
              _loadMembers();
            });
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
        if (memberProvider.isInitialLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (memberProvider.error != null && memberProvider.members.isEmpty) {
          return Center(
            child: Text(
              'Greška: ${memberProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final members = memberProvider.members;
        
        if (members.isEmpty) {
          return const EmptyState(
            icon: Icons.people,
            title: 'Nema korisnika za prikaz',
            description: 'Trenutno nema registrovanih korisnika.\nKreirajte novog korisnika.',
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
            // Sort by membership status (active memberships first)
            sortedMembers.sort((a, b) {
              final aHasActiveMembership = _membershipStatus[a.id] ?? false;
              final bHasActiveMembership = _membershipStatus[b.id] ?? false;
              return bHasActiveMembership == aHasActiveMembership ? 0 : (bHasActiveMembership ? 1 : -1);
            });
            break;
        }
        
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Members grid
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 40,
                mainAxisSpacing: 40,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final member = sortedMembers[index];
                  final hasActiveMembership = _membershipStatus[member.id] ?? false;
                  
                  return ZSCard.fromMember(
                    context,
                    member,
                    isActive: hasActiveMembership,
                    hideStatus: !_membershipStatusesLoaded, // Hide status until membership data is loaded
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MembersDetailOverview(
                            member: member,
                          ),
                        ),
                      );
                      // Refresh membership statuses when returning from details
                      _loadMembers();
                      _refreshMembershipStatuses();
                    },
                  );
                },
                childCount: sortedMembers.length,
              ),
            ),
            
            if (memberProvider.hasMoreData || memberProvider.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 40),
                  child: PaginationControlsWidget(
                    currentItemCount: memberProvider.members.length,
                    totalCount: memberProvider.totalCount,
                    hasMoreData: memberProvider.hasMoreData,
                    isLoadingMore: memberProvider.isLoadingMore,
                    onLoadMore: () => memberProvider.loadMore(),
                    currentPageSize: memberProvider.pageSize,
                    onPageSizeChanged: (newSize) => memberProvider.setPageSize(newSize),
                    itemName: 'korisnika',
                    loadMoreText: 'Učitaj više korisnika',
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(
                child: SizedBox(height: 60),
              ),
          ],
        );
      },
    );
  }
} 