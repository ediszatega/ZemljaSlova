import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../widgets/zs_button.dart';
import '../widgets/top_branding.dart';
import '../widgets/bottom_navigation.dart';
import 'ticket_type_selection.dart';

class EventDetailOverviewScreen extends StatefulWidget {
  final Event event;
  
  const EventDetailOverviewScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailOverviewScreen> createState() => _EventDetailOverviewScreenState();
}

class _EventDetailOverviewScreenState extends State<EventDetailOverviewScreen> {
  late Future<Event?> _eventFuture;
  
  @override
  void initState() {
    super.initState();
    // Load fresh event data to ensure we have the latest info
    _loadEventData();
  }
  
  void _loadEventData() {
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    _eventFuture = eventProvider.getEventById(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const TopBranding(),
          Expanded(
            child: FutureBuilder<Event?>(
              future: _eventFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final event = snapshot.data ?? widget.event;
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEventHeader(event),
                      
                      const SizedBox(height: 8),

                      _buildActionButtons(event),

                      const SizedBox(height: 30),
                      
                      _buildEventDetailsSection(event),
                      
                      const SizedBox(height: 24),
                      
                      _buildDescriptionSection(event.description),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
          const BottomNavigation(),
        ],
      ),
    );
  }
  
  Widget _buildEventHeader(Event event) {
    // Format price based on ticket types
    String priceText = 'Besplatno';
    
    if (event.ticketTypes != null && event.ticketTypes!.isNotEmpty) {
      if (event.ticketTypes!.length == 1) {
        final price = event.ticketTypes![0].price;
        priceText = price == 0 ? 'Besplatno' : '${price.toStringAsFixed(2)} KM';
      } else {
        final prices = event.ticketTypes!.map((t) => t.price).toList()..sort();
        final lowestPrice = prices.first;
        final highestPrice = prices.last;
        
        if (lowestPrice == 0 && highestPrice == 0) {
          priceText = 'Besplatno';
        } else if (lowestPrice == 0) {
          priceText = '0 - ${highestPrice.toStringAsFixed(2)} KM';
        } else if (lowestPrice == highestPrice) {
          priceText = '${lowestPrice.toStringAsFixed(2)} KM';
        } else {
          priceText = '${lowestPrice.toStringAsFixed(2)} - ${highestPrice.toStringAsFixed(2)} KM';
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 400,
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: event.coverImageUrl != null
                ? Image.network(
                    event.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildFallbackImage();
                    },
                  )
                : _buildFallbackImage(),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  event.organizer ?? 'Nije navedeno',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  priceText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventDetailsSection(Event event) {
    String formatDate(DateTime date) {
      return '${date.day}.${date.month}.${date.year}';
    }
    
    String formatTime(DateTime date) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalji o događaju',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (event.organizer != null && event.organizer!.isNotEmpty)
            _DetailRow(label: 'Organizator', value: event.organizer!),
          _DetailRow(label: 'Datum održavanja', value: formatDate(event.startAt)),
          _DetailRow(label: 'Vrijeme održavanja', value: '${formatTime(event.startAt)} - ${formatTime(event.endAt)}'),
          if (event.location != null && event.location!.isNotEmpty)
            _DetailRow(label: 'Mjesto održavanja', value: event.location!),
          if (event.lecturers != null && event.lecturers!.isNotEmpty)
            _DetailRow(label: 'Predavači', value: event.lecturers!),
        ],
      ),
    );
  }
  
  Widget _buildDescriptionSection(String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'O događaja',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _ExpandableDescription(description: description),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(Event event) {
    return ZSButton(
      text: 'Kupi ulaznicu',
      backgroundColor: const Color(0xFF28A745),
      foregroundColor: Colors.white,
      borderColor: const Color(0xFF28A745),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TicketTypeSelectionScreen(event: event),
          ),
        );
      },
    );
  }
  
  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.event,
        size: 60,
        color: Colors.black54,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _DetailRow({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableDescription extends StatefulWidget {
  final String description;
  
  const _ExpandableDescription({
    required this.description,
  });
  
  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isExpanded || widget.description.length <= 100
              ? widget.description 
              : '${widget.description.substring(0, 100)}...',
          style: const TextStyle(fontSize: 14),
        ),
        if (widget.description.length > 100)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(
              _isExpanded ? 'Prikaži manje' : 'Prikaži više',
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
} 