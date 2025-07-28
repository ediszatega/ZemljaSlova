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
import '../widgets/search_loading_indicator.dart';
import '../widgets/filter_dialog.dart';
import '../utils/filter_configurations.dart';
import '../models/member_filters.dart';
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
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadMembers();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProvider>().setSorting('name', 'asc');
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _searchController.dispose();
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
  
  void _handleSortChange(String? value) {
    if (value != null) {
      setState(() {
        _sortOption = value;
      });
      
      String sortBy;
      String sortOrder;
      
      switch (value) {
        case 'Ime (A-Z)':
          sortBy = 'name';
          sortOrder = 'asc';
          break;
        case 'Ime (Z-A)':
          sortBy = 'name';
          sortOrder = 'desc';
          break;
        default:
          sortBy = 'name';
          sortOrder = 'asc';
          break;
      }
      
      context.read<MemberProvider>().setSorting(sortBy, sortOrder);
    }
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

  void _showFiltersDialog() {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        title: 'Filtriraj članove',
        fields: FilterConfigurations.getMemberFilters(context),
        initialValues: memberProvider.filters.toMap(),
        onApplyFilters: (Map<String, dynamic> values) {
          final filters = MemberFilters.fromMap(values);
          memberProvider.setFilters(filters);
        },
        onClearFilters: () {
          memberProvider.clearFilters();
        },
      ),
    );
  }

  int _getActiveFilterCount(MemberFilters filters) {
    int count = 0;
    if (filters.gender != null) count++;
    if (filters.birthYearFrom != null) count++;
    if (filters.birthYearTo != null) count++;
    if (filters.joinedYearFrom != null) count++;
    if (filters.joinedYearTo != null) count++;
    if (filters.showInactiveMembers == true) count++;
    return count;
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
            controller: _searchController,
            borderColor: Colors.grey.shade300,
            onChanged: (value) {
              context.read<MemberProvider>().setSearchQuery(value);
            },
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
          ],
          onChanged: (value) {
            _handleSortChange(value);
          },
          borderColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 16),
        
        // Filter
        Consumer<MemberProvider>(
          builder: (context, memberProvider, child) {
            final hasActiveFilters = memberProvider.filters.hasActiveFilters;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ZSButton(
                  onPressed: () {
                    _showFiltersDialog();
                  },
                  text: hasActiveFilters ? 'Filteri aktivni (${_getActiveFilterCount(memberProvider.filters)})' : 'Postavi filtre',
                  label: 'Filtriraj',
                  backgroundColor: hasActiveFilters ? const Color(0xFFE3F2FD) : Colors.white,
                  foregroundColor: hasActiveFilters ? Colors.blue : Colors.black,
                  borderColor: hasActiveFilters ? Colors.blue : Colors.grey.shade300,
                  width: 180,
                ),
                if (hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 40,
                    child: IconButton(
                      onPressed: () {
                        memberProvider.clearFilters();
                      },
                      icon: const Icon(Icons.clear, color: Colors.red),
                      tooltip: 'Očisti filtre',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
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
        if (memberProvider.isLoading) {
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
            title: 'Nema članova za prikaz',
            description: 'Trenutno nema članova u sistemu.\nDodajte novog člana da biste počeli.',
          );
        }
        
        return Stack(
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 100),
              child: CustomScrollView(
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
                        final member = members[index];
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
                      childCount: members.length,
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
              ),
            ),
            
            // Search loading indicator
            SearchLoadingIndicator(
              isVisible: memberProvider.isUpdating,
              text: 'Pretražujem korisnike...',
              top: 20,
            ),
          ],
        );
      },
    );
  }
} 