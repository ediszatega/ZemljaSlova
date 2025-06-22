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
      context.read<EventProvider>().fetchEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            controller: _searchController,
            hintText: 'Pretraži događaje',
            borderColor: Colors.grey.shade300,
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
                    // TODO: Implement filter functionality
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
          
          // Events list
          _buildEventsList(),
        ],
      ),
    );
  }
  
  Widget _buildEventsList() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        if (eventProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (eventProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Greška pri učitavanju događaja',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    eventProvider.fetchEvents();
                  },
                  child: const Text('Pokušaj ponovo'),
                ),
              ],
            ),
          );
        }

        if (eventProvider.events.isEmpty) {
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
                  'Nema dostupnih događaja',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Sort the events list based on the selected option
        final sortedEvents = List<Event>.from(eventProvider.events);
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

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedEvents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
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
        );
      },
    );
  }
} 