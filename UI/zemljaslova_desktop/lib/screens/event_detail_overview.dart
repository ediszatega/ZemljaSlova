import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../models/event.dart';
import '../models/ticket_type.dart';
import '../widgets/sidebar.dart';
import '../widgets/zs_button.dart';
import 'event_add.dart';
import 'event_edit.dart';
import 'ticket_inventory_screen.dart';

class EventDetailOverview extends StatefulWidget {
  final int eventId;
  
  const EventDetailOverview({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailOverview> createState() => _EventDetailOverviewState();
}

class _EventDetailOverviewState extends State<EventDetailOverview> {
  late Future<Event?> _eventFuture;
  
  @override
  void initState() {
    super.initState();
    // Load fresh event data to ensure we have the latest info
    _loadEventData();
  }
  
  void _loadEventData() async {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    _eventFuture = eventProvider.getEventById(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          const SidebarWidget(),
          
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 44, left: 80.0, right: 80.0),
              child: FutureBuilder<Event?>(
                future: _eventFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Greška pri učitavanju: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  
                  final event = snapshot.data;
                  
                  if (event == null) {
                    return const Center(
                      child: Text('Događaj nije pronađen'),
                    );
                  }
                  
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Nazad na pregled događaja'),
                        ),
                        const SizedBox(height: 24),
                        
                        // Header
                        const Text(
                          'Pregled detalja o događaju',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Main content area with event cover and details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column - Event cover
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.5,
                                  child: Center(
                                    child: event.coverImageUrl != null
                                      ? Image.network(
                                          event.coverImageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/no_image.jpg',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.event,
                                              size: 120,
                                              color: Colors.black,
                                            );
                                          },
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 40),
                            
                            // Right column - Event details
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Event title
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Event date and time
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.calendar_today,
                                              color: Colors.black87,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Datum početka',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  '${event.startAt.day}.${event.startAt.month}.${event.startAt.year} ${event.startAt.hour}:${event.startAt.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.event_available,
                                              color: Colors.black87,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Datum završetka',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                Text(
                                                  '${event.endAt.day}.${event.endAt.month}.${event.endAt.year} ${event.endAt.hour}:${event.endAt.minute.toString().padLeft(2, '0')}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),
                                  
                                  // Event details section
                                  const Text(
                                    'Detalji o događaju',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Detail rows
                                  DetailRow(label: 'Opis', value: event.description),
                                  if (event.organizer != null && event.organizer!.isNotEmpty)
                                    DetailRow(label: 'Organizator', value: event.organizer!),
                                  if (event.location != null && event.location!.isNotEmpty)
                                    DetailRow(label: 'Lokacija', value: event.location!),
                                  if (event.lecturers != null && event.lecturers!.isNotEmpty)
                                    DetailRow(label: 'Predavači', value: event.lecturers!),
                                  if (event.maxNumberOfPeople != null)
                                    DetailRow(label: 'Maksimalan broj učesnika', value: event.maxNumberOfPeople.toString()),
                                  
                                  const SizedBox(height: 30),
                                  
                                  // Ticket types section
                                  ...[
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tipovi ulaznica',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 16),
                                    
                                    // Show ticket types from the event
                                    if (event.ticketTypes != null && event.ticketTypes!.isNotEmpty)
                                      _buildTicketTypesList(event.ticketTypes!.cast<TicketType>())
                                    else
                                      const Text(
                                        'Nema dostupnih ulaznica za ovaj događaj',
                                        style: TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // Action buttons
                        Column(
                          children: [
                            ZSButton(
                              text: 'Uredi događaj',
                              backgroundColor: Colors.blue.shade50,
                              foregroundColor: Colors.blue,
                              borderColor: Colors.grey.shade300,
                              width: 410,
                              topPadding: 5,
                              onPressed: () async {
                                final updatedEvent = await Navigator.of(context).push<Event>(
                                  MaterialPageRoute(
                                    builder: (context) => EventEditScreen(eventId: event.id),
                                  ),
                                );
                                
                                if (updatedEvent != null) {
                                  setState(() {
                                    _loadEventData();
                                  });
                                } 
                              },
                            ),
                            
                            const SizedBox(height: 8),
                            
                            ZSButton(
                              text: 'Obriši događaj',
                              backgroundColor: Colors.red.shade50,
                              foregroundColor: Colors.red,
                              borderColor: Colors.grey.shade300,
                              width: 410,
                              topPadding: 5,
                              onPressed: () {
                                // TODO: Implement delete functionality
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTicketTypesList(List<TicketType> ticketTypes) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: ticketTypes.map((ticket) {
        return Container(
          width: 280,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.confirmation_number,
                    color: Colors.black87,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ticket.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            ticket.description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${ticket.price.toStringAsFixed(2)} KM',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (ticket.currentQuantity != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ticket.currentQuantity! > 0 
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${ticket.currentQuantity} na stanju',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ticket.currentQuantity! > 0 ? Colors.green : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TicketInventoryScreen(
                            ticketTypeId: ticket.id!,
                            ticketTypeName: ticket.name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.inventory, size: 16),
                    label: const Text('Inventar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 