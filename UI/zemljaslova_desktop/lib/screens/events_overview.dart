import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/zs_card_vertical.dart';

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
  
  @override
  void initState() {
    super.initState();
    // Load events data
    Future.microtask(() {
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
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
          
          // Events list
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
          onPressed: () {},
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
        
        if (eventProvider.error != null) {
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
            child: Text('Nema događaja za prikaz.'),
          );
        }
        
        // Sort the events list based on the selected option
        final sortedEvents = List<Event>.from(events);
        switch (_sortOption) {
          case 'Najnoviji':
            // In a real app, this would sort by date
            sortedEvents.sort((a, b) => b.id.compareTo(a.id));
            break;
          case 'Najstariji':
            // In a real app, this would sort by date
            sortedEvents.sort((a, b) => a.id.compareTo(b.id));
            break;
          case 'Cijena (veća)':
            sortedEvents.sort((a, b) => b.price.compareTo(a.price));
            break;
          case 'Cijena (manja)':
            sortedEvents.sort((a, b) => a.price.compareTo(b.price));
            break;
        }
        
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3.0,
          ),
          itemCount: sortedEvents.length,
          itemBuilder: (context, index) {
            final event = sortedEvents[index];
            return ZSCardVertical.fromEvent(
              context,
              event,
              onTap: () {
                // Navigate to event details (to be implemented)
              },
            );
          },
        );
      },
    );
  }
} 