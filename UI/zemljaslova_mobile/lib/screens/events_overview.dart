import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../models/event_filters.dart';
import '../widgets/zs_card_vertical.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/paginated_data_widget.dart';
import '../widgets/filter_dialog.dart';
import '../utils/filter_configurations.dart';
import '../providers/event_provider.dart';
import 'event_detail_overview.dart';

class EventsOverviewScreen extends StatefulWidget {
  const EventsOverviewScreen({super.key});

  @override
  State<EventsOverviewScreen> createState() => _EventsOverviewScreenState();
}

class _EventsOverviewScreenState extends State<EventsOverviewScreen> with WidgetsBindingObserver {
  String _sortOption = 'Najnoviji';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear any existing search and reset to default state
      context.read<EventProvider>().clearSearch();
      context.read<EventProvider>().fetchEvents(refresh: true);
      context.read<EventProvider>().setSorting('date', 'desc');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Clear search when leaving the screen
      context.read<EventProvider>().clearSearch();
      _searchController.clear();
    }
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<EventProvider>().refresh();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Pregled događaja',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // Search bar
            SearchInput(
              label: 'Pretraži',
              hintText: 'Pretraži događaje po naslovu',
              controller: _searchController,
              borderColor: Colors.grey.shade300,
              onChanged: (value) {
                context.read<EventProvider>().setSearchQuery(value);
              },
            ),
            
            const SizedBox(height: 8),
            
            // Toolbar - Sort and Filter
            Row(
              children: [
                // Sort dropdown
                Expanded(
                  child: ZSDropdown<String>(
                    label: 'Sortiraj',
                    value: _sortOption,
                    items: const [
                      DropdownMenuItem(value: 'Naslov (A-Z)', child: Text('Naslov (A-Z)')),
                      DropdownMenuItem(value: 'Naslov (Z-A)', child: Text('Naslov (Z-A)')),
                      DropdownMenuItem(value: 'Najnoviji', child: Text('Najnoviji')),
                      DropdownMenuItem(value: 'Najstariji', child: Text('Najstariji')),
                      DropdownMenuItem(value: 'Cijena (manja)', child: Text('Cijena (manja)')),
                      DropdownMenuItem(value: 'Cijena (veća)', child: Text('Cijena (veća)')),
                    ],
                    onChanged: _handleSortChange,
                    borderColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Filter button
                Consumer<EventProvider>(
                  builder: (context, eventProvider, child) {
                    final hasActiveFilters = eventProvider.filters.hasActiveFilters;
                    return Expanded(
                      child: ZSButton(
                        onPressed: () => _showFiltersDialog(),
                        text: hasActiveFilters ? 'Filteri aktivni (${_getActiveFilterCount(eventProvider.filters)})' : 'Postavi filtre',
                        label: 'Filtriraj',
                        backgroundColor: hasActiveFilters ? const Color(0xFFE3F2FD) : Colors.white,
                        foregroundColor: hasActiveFilters ? Colors.blue : Colors.black,
                        borderColor: hasActiveFilters ? Colors.blue : Colors.grey.shade300,
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Events grid
            _buildEventsGrid(),
          ],
        ),
      ),
    );
  }
  
  void _showFiltersDialog() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          title: 'Filtriraj događaje',
          fields: FilterConfigurations.getEventFilters(context),
          initialValues: eventProvider.filters.toMap(),
          onApplyFilters: (Map<String, dynamic> filters) {
            final eventFilters = EventFilters.fromMap(filters);
            eventProvider.setFilters(eventFilters);
          },
          onClearFilters: () {
            eventProvider.clearFilters();
          },
        );
      },
    );
  }

  int _getActiveFilterCount(EventFilters filters) {
    int count = 0;
    if (filters.minPrice != null) count++;
    if (filters.maxPrice != null) count++;
    if (filters.startDateFrom != null) count++;
    if (filters.startDateTo != null) count++;
    return count;
  }

  Widget _buildEventsGrid() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return PaginatedDataWidget<Event>(
          provider: eventProvider,
          itemName: 'događaja',
          loadMoreText: 'Učitaj više događaja',
          emptyStateIcon: Icons.event_outlined,
          emptyStateMessage: 'Nema dostupnih događaja',
          gridBuilder: (context, events) {
            return LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ZSCardVertical.fromEvent(
                      context,
                      event,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailOverviewScreen(
                              event: event,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
} 