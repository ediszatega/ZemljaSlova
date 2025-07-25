import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/zs_card_vertical.dart';
import '../widgets/empty_state.dart';
import '../widgets/pagination_controls_widget.dart';
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
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _loadEvents() {
    // Load events data using pagination
    Future.microtask(() {
      Provider.of<EventProvider>(context, listen: false).refresh(isTicketTypeIncluded: true);
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
            DropdownMenuItem(value: 'Najnoviji', child: Text('Najnoviji')),
            DropdownMenuItem(value: 'Najstariji', child: Text('Najstariji')),
            DropdownMenuItem(value: 'Cijena (veća)', child: Text('Cijena (veća)')),
            DropdownMenuItem(value: 'Cijena (manja)', child: Text('Cijena (manja)')),
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
        if (eventProvider.isInitialLoading) {
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
        
        // Sort the events list based on the selected option
        final sortedEvents = List<Event>.from(events);
        switch (_sortOption) {
          case 'Najnoviji':
            // Sort by startDate - newest first
            sortedEvents.sort((a, b) => b.startAt.compareTo(a.startAt));
            break;
          case 'Najstariji':
            // Sort by startDate - oldest first
            sortedEvents.sort((a, b) => a.startAt.compareTo(b.startAt));
            break;
          case 'Cijena (veća)':
            // Sort by highest ticket price, if available
            sortedEvents.sort((a, b) {
              // Get max prices from ticket types
              double getMaxPrice(Event event) {
                if (event.ticketTypes == null || event.ticketTypes!.isEmpty) {
                  return 0.0;
                }
                return event.ticketTypes!.map((t) => t.price).reduce((max, price) => price > max ? price : max);
              }
              return getMaxPrice(b).compareTo(getMaxPrice(a));
            });
            break;
          case 'Cijena (manja)':
            // Sort by lowest ticket price, if available
            sortedEvents.sort((a, b) {
              // Get min prices from ticket types
              double getMinPrice(Event event) {
                if (event.ticketTypes == null || event.ticketTypes!.isEmpty) {
                  return double.infinity;
                }
                return event.ticketTypes!.map((t) => t.price).reduce((min, price) => price < min ? price : min);
              }
              
              double minPriceA = getMinPrice(a);
              double minPriceB = getMinPrice(b);
              
              // Handle the case where there are no ticket types
              if (minPriceA == double.infinity && minPriceB == double.infinity) {
                return 0; // Both are equal
              } else if (minPriceA == double.infinity) {
                return 1; // b comes first
              } else if (minPriceB == double.infinity) {
                return -1; // a comes first
              }
              
              return minPriceA.compareTo(minPriceB);
            });
            break;
        }
        
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Events grid
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final event = sortedEvents[index];
                  return ZSCardVertical.fromEvent(
                    context,
                    event,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailOverview(eventId: event.id),
                        ),
                      ).then((_) {
                        _loadEvents();
                      });
                    },
                  );
                },
                childCount: sortedEvents.length,
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
        );
      },
    );
  }
} 