import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book_transaction.dart';
import '../services/book_rental_service.dart';
import '../services/api_service.dart';
import '../widgets/top_branding.dart';
import '../widgets/bottom_navigation.dart';

class DateRange {
  final DateTime start;
  final DateTime end;
  
  DateRange(this.start, this.end);
}

class BookAvailabilityScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;
  
  const BookAvailabilityScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<BookAvailabilityScreen> createState() => _BookAvailabilityScreenState();
}

class _BookAvailabilityScreenState extends State<BookAvailabilityScreen> {
  bool _isLoading = true;
  List<BookTransaction> _activeRentals = [];
  String? _error;
  String? _selectedDateInfo;
  int _physicalStock = 0;
  int _currentlyRented = 0;
  
  late BookRentalService _bookRentalService;

  @override
  void initState() {
    super.initState();
    _bookRentalService = BookRentalService(
      Provider.of<ApiService>(context, listen: false),
    );
    _loadActiveRentals();
  }

  Future<void> _loadActiveRentals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get all active rental transactions for this book
      final transactions = await _bookRentalService.getActiveRentals(widget.bookId);
      
      // Filter only rental transactions (activityTypeId = 4)
      _activeRentals = transactions.where((t) => t.activityTypeId == BookActivityType.rent.value).toList();
      // Fetch stock information
      final physical = await _bookRentalService.getPhysicalStock(widget.bookId);
      final rented = await _bookRentalService.getCurrentlyRented(widget.bookId);

      setState(() {
        _isLoading = false;
        _physicalStock = physical;
        _currentlyRented = rented;
      });
    } catch (e) {
      setState(() {
        _error = 'Greška pri učitavanju podataka: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          const TopBranding(),
          // Content
          Expanded(
            child: _buildContent(),
          ),
          const BottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadActiveRentals,
                child: const Text('Pokušaj ponovo'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildAvailabilityView();
  }

  Widget _buildAvailabilityView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dostupnost knjige',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.bookTitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          
          const SizedBox(height: 20),
          
          // Availability timeline
           if (_physicalStock > 0) ...[
             _buildAvailabilityTimeline(),
             const SizedBox(height: 20),
           ],
          
          // Current status
          _buildCurrentStatus(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.book,
                size: 28,
                color: Colors.purple.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktivna iznajmljivanja',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '${_activeRentals.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityTimeline() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: Colors.purple),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Kalendar dostupnosti (sljedećih 60 dana)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (_selectedDateInfo != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _selectedDateInfo!,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildTimelineVisualization(),
            const SizedBox(height: 16),
            _buildTimelineLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineVisualization() {
    final today = DateTime.now();
    
    // Calculate the timeline ranges
    DateTime? latestReturnDate;
    
    // Find the latest return date from all active rentals
    for (var rental in _activeRentals) {
      final returnDateStr = _extractReturnDate(rental);
      if (returnDateStr != null) {
        final returnDate = _parseDate(returnDateStr);
        if (returnDate != null) {
          if (latestReturnDate == null || returnDate.isAfter(latestReturnDate)) {
            latestReturnDate = returnDate;
          }
        }
      }
    }
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildRangeBasedTimeline(today, latestReturnDate),
    );
  }

  Widget _buildRangeBasedTimeline(DateTime today, DateTime? latestReturnDate) {
    List<Widget> segments = [];
    final bool hasPhysicalStock = _physicalStock > 0;
    final bool allCopiesRented = hasPhysicalStock && _currentlyRented >= _physicalStock;
    
    if (!hasPhysicalStock) {
      return const SizedBox.shrink();
    }

    if (!allCopiesRented) {
      // Some copies are available now
      segments.addAll([
        // Today marker
        _buildTimelineSegment(
          color: Colors.blue,
          fixedWidth: 60,
          label: 'Danas',
          icon: Icons.today,
          onTap: () => _showDateInfo(today, false),
        ),
        // Available period
        _buildTimelineSegment(
          color: Colors.green.shade400,
          flex: 8,
          label: 'Dostupno',
          onTap: () => _showRangeInfo('Dostupno za iznajmljivanje'),
        ),
      ]);
    } else if (latestReturnDate == null || _activeRentals.isEmpty) {
      // Book is available - show only today marker and available period
      segments.addAll([
        // Today marker
        _buildTimelineSegment(
          color: Colors.blue,
          fixedWidth: 60,
          label: 'Danas',
          icon: Icons.today,
          onTap: () => _showDateInfo(today, false),
        ),
        // Available period
        _buildTimelineSegment(
          color: Colors.green.shade400,
          flex: 8,
          label: 'Dostupno',
          onTap: () => _showRangeInfo('Dostupno za iznajmljivanje'),
        ),
      ]);
    } else {
      final daysDifference = latestReturnDate.difference(today).inDays;
      
      if (daysDifference <= 0) {
        // Return date is today or in the past - book should be available
        segments.addAll([
          _buildTimelineSegment(
            color: Colors.blue,
            fixedWidth: 60,
            label: 'Danas',
            icon: Icons.today,
            onTap: () => _showDateInfo(today, false),
          ),
          _buildTimelineSegment(
            color: Colors.green.shade400,
            flex: 8,
            label: 'Dostupno',
            onTap: () => _showRangeInfo('Dostupno za iznajmljivanje'),
          ),
        ]);
      } else {
        // Book is rented until future date
        segments.addAll([
          // Today marker
          _buildTimelineSegment(
            color: Colors.blue,
            fixedWidth: 60,
            label: 'Danas',
            icon: Icons.today,
            onTap: () => _showDateInfo(today, true),
          ),
          // Rental period
          _buildTimelineSegment(
            color: Colors.red.shade400,
            flex: 6,
            label: 'Iznajmljeno ($daysDifference dana)',
            onTap: () => _showRangeInfo('Iznajmljeno do ${_formatDate(latestReturnDate)}'),
          ),
          // Available period
          _buildTimelineSegment(
            color: Colors.green.shade400,
            flex: 2,
            label: 'Dostupno',
            onTap: () => _showRangeInfo('Dostupno od ${_formatDate(latestReturnDate.add(const Duration(days: 1)))}'),
          ),
        ]);
      }
    }
    
    return Row(children: segments);
  }

  Widget _buildTimelineLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildLegendItem(Colors.red.shade400, 'Nedostupno'),
            _buildLegendItem(Colors.green.shade400, 'Dostupno'),
            _buildLegendItem(Colors.blue, 'Danas', Icons.today),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Dodirnite bilo koji period za prikaz detaljnih informacija',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, [IconData? icon]) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: icon != null ? Border.all(color: color, width: 2) : null,
          ),
          child: icon != null 
            ? Icon(icon, size: 10, color: Colors.white)
            : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStatus() {
    final bool hasPhysicalStock = _physicalStock > 0;
    final bool hasRentedCopies = _currentlyRented > 0;
    final bool allCopiesRented = hasPhysicalStock && _currentlyRented >= _physicalStock;
    
    String statusMessage;
    Color statusColor;
    IconData statusIcon;
    
    if (!hasPhysicalStock) {
      // No physical copies
       statusMessage = 'Knjiga nije dostupna za iznajmljivanje jer trenutno nije na stanju';
       statusColor = Colors.red.shade600;
       statusIcon = Icons.error_outline;
    } else if (allCopiesRented) {
      // All copies are rented out
      statusMessage = 'Knjiga trenutno nije dostupna za iznajmljivanje jer su sve kopije trenutno iznajmljene. Knjigu možete rezervisati kako biste bili na listi čekanja kada knjiga ponovo bude dostupna.';
      statusColor = Colors.orange.shade600;
      statusIcon = Icons.schedule;
    } else if (hasRentedCopies) {
      // Some copies are rented but some are still available
      statusMessage = 'Knjiga trenutno ima iznajmljenih kopija, ali je još uvijek dostupna za iznajmljivanje.';
      statusColor = Colors.green.shade600;
      statusIcon = Icons.check_circle;
    } else {
      // No copies are rented, all are available
      statusMessage = 'Knjiga je trenutno dostupna za iznajmljivanje';
      statusColor = Colors.green.shade600;
      statusIcon = Icons.check_circle;
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trenutni status',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusBackgroundColor(statusColor),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusBorderColor(statusColor),
                ),
              ),
              child: Text(
                statusMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: _getStatusTextColor(statusColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTime? _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[2]), // year
        int.parse(parts[1]), // month
        int.parse(parts[0]), // day
      );
    }
    return null;
  }



  Widget _buildTimelineSegment({
    required Color color,
    int? flex,
    double? fixedWidth,
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final child = GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: fixedWidth,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 16,
                  color: Colors.white,
                ),
              if (icon != null) const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    if (fixedWidth != null) {
      return child;
    } else if (flex != null) {
      return Expanded(flex: flex, child: child);
    } else {
      return Expanded(child: child);
    }
  }

  void _showDateInfo(DateTime date, bool isRented) {
    setState(() {
      _selectedDateInfo = _formatDateInfo(date, isRented);
    });
  }

  void _showRangeInfo(String info) {
    setState(() {
      _selectedDateInfo = info;
    });
  }

  String _formatDateInfo(DateTime date, bool isRented) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final dayName = _getDayName(date.weekday);
    
    final status = isRented ? 'Nedostupno (iznajmljeno)' : 'Dostupno';
    
    return '$dayName, $day-$month-$year - $status';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Ponedjeljak';
      case 2: return 'Utorak';
      case 3: return 'Srijeda';
      case 4: return 'Četvrtak';
      case 5: return 'Petak';
      case 6: return 'Subota';
      case 7: return 'Nedjelja';
      default: return '';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day-$month-$year';
  }

  String? _extractReturnDate(BookTransaction rental) {
    if (rental.data == null || rental.data!.isEmpty) {
      return null;
    }

    final lines = rental.data!.split('\n');
    for (var line in lines) {
      if (line.contains('Izdato na period:')) {
        final periodMatch = RegExp(r'Izdato na period:\s*\d{2}-\d{2}-\d{4}\s*-\s*(\d{2}-\d{2}-\d{4})').firstMatch(line);
        if (periodMatch != null) {
          return periodMatch.group(1)!;
        }
      }
    }

    return null;
  }

  Color _getStatusBackgroundColor(Color statusColor) {
    if (statusColor == Colors.red.shade600) {
      return Colors.red.shade50;
    } else if (statusColor == Colors.orange.shade600) {
      return Colors.orange.shade50;
    } else if (statusColor == Colors.green.shade600) {
      return Colors.green.shade50;
    }
    return Colors.grey.shade50;
  }

  Color _getStatusBorderColor(Color statusColor) {
    if (statusColor == Colors.red.shade600) {
      return Colors.red.shade200;
    } else if (statusColor == Colors.orange.shade600) {
      return Colors.orange.shade200;
    } else if (statusColor == Colors.green.shade600) {
      return Colors.green.shade200;
    }
    return Colors.grey.shade200;
  }

  Color _getStatusTextColor(Color statusColor) {
    if (statusColor == Colors.red.shade600) {
      return Colors.red.shade800;
    } else if (statusColor == Colors.orange.shade600) {
      return Colors.orange.shade800;
    } else if (statusColor == Colors.green.shade600) {
      return Colors.green.shade800;
    }
    return Colors.grey.shade800;
  }
}
