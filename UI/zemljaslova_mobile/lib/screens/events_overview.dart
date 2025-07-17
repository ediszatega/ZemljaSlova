import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../widgets/zs_card_vertical.dart';
import '../widgets/zs_button.dart';
import '../widgets/zs_dropdown.dart';
import '../widgets/search_input.dart';
import '../widgets/paginated_data_widget.dart';
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
      context.read<EventProvider>().refresh();
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
        return PaginatedDataWidget<Event>(
          provider: eventProvider,
          itemName: 'događaja',
          emptyStateMessage: 'Nema dostupnih događaja',
          emptyStateIcon: Icons.event_outlined,
          itemBuilder: (context, event, index) {
            return _buildEventCard(event);
          },
        );
      },
    );
  }
  
  Widget _buildEventCard(Event event) {
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
  }
} 