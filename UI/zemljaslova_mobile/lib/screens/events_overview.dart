import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../widgets/zs_card_vertical.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../providers/event_provider.dart';
import 'event_detail_overview.dart';

class EventsOverviewScreen extends StatefulWidget {
  const EventsOverviewScreen({super.key});

  @override
  State<EventsOverviewScreen> createState() => _EventsOverviewScreenState();
}

class _EventsOverviewScreenState extends State<EventsOverviewScreen> {
  String _sortOption = 'Najnoviji';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                ),
                const SizedBox(width: 12),
                
                // Filter button
                Expanded(
                  child: ZSButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filteri će biti implementirani')),
                      );
                    },
                    text: 'Postavi filtre',
                    label: 'Filtriraj',
                    borderColor: Colors.grey.shade300,
                  ),
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
  
  Widget _buildEventsGrid() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Nema događaja za prikaz',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Trenutno nema događaja u sistemu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Sort the events list based on the selected option
        final sortedEvents = List<Event>.from(events);
        switch (_sortOption) {
          case 'Najnoviji':
            sortedEvents.sort((a, b) => b.startAt.compareTo(a.startAt));
            break;
          case 'Najstariji':
            sortedEvents.sort((a, b) => a.startAt.compareTo(b.startAt));
            break;
          case 'Cijena (veća)':
            sortedEvents.sort((a, b) {
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
            sortedEvents.sort((a, b) {
              double getMinPrice(Event event) {
                if (event.ticketTypes == null || event.ticketTypes!.isEmpty) {
                  return double.infinity;
                }
                return event.ticketTypes!.map((t) => t.price).reduce((min, price) => price < min ? price : min);
              }
              
              double minPriceA = getMinPrice(a);
              double minPriceB = getMinPrice(b);
              
              if (minPriceA == double.infinity && minPriceB == double.infinity) {
                return 0;
              } else if (minPriceA == double.infinity) {
                return 1;
              } else if (minPriceB == double.infinity) {
                return -1;
              }
              
              return minPriceA.compareTo(minPriceB);
            });
            break;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate number of columns based on screen width
            int crossAxisCount = 1;
            if (constraints.maxWidth > 600) {
              crossAxisCount = 2;
            }
            
            return Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: sortedEvents.length,
                  itemBuilder: (context, index) {
                    final event = sortedEvents[index];
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
                ),
                
                if (eventProvider.hasMoreData)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: eventProvider.isLoading ? null : () {
                          eventProvider.loadMore();
                        },
                        child: eventProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Učitaj više događaja'),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
} 