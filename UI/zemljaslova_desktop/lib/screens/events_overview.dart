import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/event_filters.dart';
import '../providers/event_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/zs_card_vertical.dart';
import '../widgets/empty_state.dart';
import '../widgets/pagination_controls_widget.dart';
import '../widgets/search_loading_indicator.dart';
import '../widgets/filter_dialog.dart';
import '../utils/filter_configurations.dart';
import 'event_add.dart';
import 'event_detail_overview.dart';

class EventsOverview extends StatelessWidget {
  const EventsOverview({super.key});

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
            child: EventsContent(),
          ),
        ],
      ),
    );
  }
}

class EventsContent extends StatefulWidget {
  const EventsContent({super.key});

  @override
  State<EventsContent> createState() => _EventsContentState();
}

class _EventsContentState extends State<EventsContent> {
  String _sortOption = 'Najnoviji';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
    
    // Initialize with default sorting (date descending - newest first)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().setSorting('date', 'desc');
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadEvents() {
    // Load events data using pagination
    Future.microtask(() {
      Provider.of<EventProvider>(context, listen: false).refresh(isTicketTypeIncluded: true);
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
        case 'Naslov (A-Z)':
          sortBy = 'title';
          sortOrder = 'asc';
          break;
        case 'Naslov (Z-A)':
          sortBy = 'title';
          sortOrder = 'desc';
          break;
        case 'Najnoviji':
          sortBy = 'date';
          sortOrder = 'desc';
          break;
        case 'Najstariji':
          sortBy = 'date';
          sortOrder = 'asc';
          break;
        case 'Cijena (manja)':
          sortBy = 'price';
          sortOrder = 'asc';
          break;
        case 'Cijena (veća)':
          sortBy = 'price';
          sortOrder = 'desc';
          break;
        default:
          sortBy = 'date';
          sortOrder = 'desc';
          break;
      }
      
      context.read<EventProvider>().setSorting(sortBy, sortOrder);
    }
  }

  void _showFiltersDialog() {
          showDialog(
        context: context,
        builder: (context) => FilterDialog(
          title: 'Filtri za događaje',
          fields: FilterConfigurations.getEventFilters(context),
          initialValues: context.read<EventProvider>().filters.toMap(),
          onApplyFilters: (values) {
            final filters = EventFilters.fromMap(values);
            context.read<EventProvider>().setFilters(filters);
          },
          onClearFilters: () {
            context.read<EventProvider>().clearFilters();
          },
        ),
      );
  }

  int _getActiveFilterCount(EventFilters filters) {
    int count = 0;
    if (filters.minPrice != null) count++;
    if (filters.maxPrice != null) count++;
    if (filters.startDateFrom != null) count++;
    if (filters.startDateTo != null) count++;
    if (filters.showPastEvents == true) count++;
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
          const Text(
            'Pregled događaja',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Build toolbar
          _buildToolbar(),
          
          const SizedBox(height: 24),
          
          // Events grid
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildToolbar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search using our component
        Expanded(
          child: SearchInput(
            label: 'Pretraži',
            hintText: 'Pretraži događaje',
            controller: _searchController,
            borderColor: Colors.grey.shade300,
            onChanged: (value) {
              context.read<EventProvider>().setSearchQuery(value);
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
            DropdownMenuItem(value: 'Naslov (A-Z)', child: Text('Naslov (A-Z)')),
            DropdownMenuItem(value: 'Naslov (Z-A)', child: Text('Naslov (Z-A)')),
            DropdownMenuItem(value: 'Najnoviji', child: Text('Najnoviji')),
            DropdownMenuItem(value: 'Najstariji', child: Text('Najstariji')),
            DropdownMenuItem(value: 'Cijena (manja)', child: Text('Cijena (manja)')),
            DropdownMenuItem(value: 'Cijena (veća)', child: Text('Cijena (veća)')),
          ],
          onChanged: (value) {
            _handleSortChange(value);
          },
          borderColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 16),
        
        // Filter
        Consumer<EventProvider>(
          builder: (context, eventProvider, child) {
            final hasActiveFilters = eventProvider.filters.hasActiveFilters;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ZSButton(
                  onPressed: () {
                    _showFiltersDialog();
                  },
                  text: hasActiveFilters ? 'Filteri aktivni (${_getActiveFilterCount(eventProvider.filters)})' : 'Postavi filtre',
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
                        eventProvider.clearFilters();
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
                builder: (context) => const EventAddScreen(),
              ),
            ).then((_) {
              // Refresh events when returning from add screen
              _loadEvents();
            });
          },
          text: 'Dodaj događaj',
          backgroundColor: const Color(0xFFE5FFEE),
          foregroundColor: Colors.green,
          borderColor: Colors.grey.shade300,
          width: 180,
        ),
      ],
    );
  }
  
  Widget _buildEventsList() {
    return Consumer<EventProvider>(
      builder: (ctx, eventProvider, child) {
        if (eventProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (eventProvider.error != null && eventProvider.events.isEmpty) {
          return Center(
            child: Text(
              'Greška: ${eventProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        
        final events = eventProvider.events;
        
        if (events.isEmpty) {
          return const EmptyState(
            icon: Icons.event,
            title: 'Nema događaja za prikaz',
            description: 'Trenutno nema događaja u sistemu.\nKreirajte novi događaj da zainteresujete posjetioce.',
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
                  SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 3.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = events[index];
                        return ZSCardVertical.fromEvent(
                          context,
                          event,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailOverview(
                                  eventId: event.id,
                                ),
                              ),
                            ).then((_) {
                              _loadEvents();
                            });
                          },
                        );
                      },
                      childCount: events.length,
                    ),
                  ),
                  
                  if (eventProvider.hasMoreData || eventProvider.isLoadingMore)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 40),
                        child: PaginationControlsWidget(
                          currentItemCount: eventProvider.events.length,
                          totalCount: eventProvider.totalCount,
                          hasMoreData: eventProvider.hasMoreData,
                          isLoadingMore: eventProvider.isLoadingMore,
                          onLoadMore: () => eventProvider.loadMore(),
                          currentPageSize: eventProvider.pageSize,
                          onPageSizeChanged: (newSize) => eventProvider.setPageSize(newSize),
                          itemName: 'događaja',
                          loadMoreText: 'Učitaj više događaja',
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
            
            SearchLoadingIndicator(
              isVisible: eventProvider.isUpdating,
              text: 'Pretražujem događaje...',
              top: 20,
            ),
          ],
        );
      },
    );
  }
} 