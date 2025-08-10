import 'package:flutter/material.dart';
import '../models/book_transaction.dart';
import '../services/inventory_service.dart';
import '../services/api_service.dart';
import '../widgets/search_loading_indicator.dart';
import '../widgets/empty_state.dart';

class DateRange {
  final DateTime start;
  final DateTime end;
  
  DateRange(this.start, this.end);
}

class BookRentalOverview extends StatefulWidget {
  final int bookId;
  final String bookTitle;
  
  const BookRentalOverview({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  @override
  State<BookRentalOverview> createState() => _BookRentalOverviewState();
}

class _BookRentalOverviewState extends State<BookRentalOverview> {
  bool _isLoading = true;
  List<BookTransaction> _activeRentals = [];
  String? _error;
  bool _showExpiredRentals = false;
  String? _selectedDateInfo;
  
  final InventoryService<BookTransaction> _inventoryService = InventoryService<BookTransaction>(
    ApiService(),
    'BookTransaction/book',
    BookTransaction.fromJson,
  );

  @override
  void initState() {
    super.initState();
    _loadActiveRentals();
  }

  Future<void> _loadActiveRentals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get all transactions for this book
      final allTransactions = await _inventoryService.getTransactionsById(widget.bookId);
      
      // Calculate active rentals by checking the rental balance
      final activeRentals = _calculateActiveRentals(allTransactions);
      
      // Filter based on toggle: show only active or include expired
      final rentals = _showExpiredRentals 
        ? allTransactions.where((t) => t.activityTypeId == 4).toList()
        : activeRentals;
      
      setState(() {
        _activeRentals = rentals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Greška prilikom učitavanja podataka: $e';
        _isLoading = false;
      });
    }
  }

  List<BookTransaction> _calculateActiveRentals(List<BookTransaction> allTransactions) {
    final rentalTransactions = allTransactions.where((t) => t.activityTypeId == 4).toList();
    
    // Get all return transactions (stock transactions with "Vraćeno:" in data)
    final returnTransactions = allTransactions.where((t) => 
      t.activityTypeId == 1 && 
      t.data != null && 
      t.data!.contains('Vraćeno:')
    ).toList();
    
    // Calculate net rented quantity for each rental transaction
    List<BookTransaction> activeRentals = [];
    
    for (var rental in rentalTransactions) {
      // Calculate how many books from this rental have been returned
      int returnedFromThisRental = 0;
      
      // If this rental hasn't been fully returned and the rental period hasn't expired
      if (rental.quantity > returnedFromThisRental && _isRentalNotExpired(rental)) {
        activeRentals.add(rental);
      }
    }
    
    // Ensure we have net positive rentals
    int totalRented = rentalTransactions.fold(0, (sum, t) => sum + t.quantity);
    int totalReturned = returnTransactions.fold(0, (sum, t) => sum + t.quantity);
    
    if (totalRented <= totalReturned) {
      // All books have been returned, no active rentals
      return [];
    }
    
    return activeRentals;
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');
    
    return '$day-$month-$year $hour:$minute';
  }

  bool _isRentalActive(BookTransaction transaction) {
    if (transaction.activityTypeId != 4) {
      return false;
    }

    return _isRentalNotExpired(transaction);
  }

  bool _isRentalNotExpired(BookTransaction transaction) {
    if (transaction.data == null || transaction.data!.isEmpty) {
      return true; // Consider as active if no data available
    }

    try {
      // Parse the data to extract the end date
      final lines = transaction.data!.split('\n');
      String? periodLine;
      
      for (var line in lines) {
        if (line.contains('Izdato na period:')) {
          periodLine = line;
          break;
        }
      }
      
      if (periodLine == null) {
        return true; // Consider as active if no period information found
      }
      
      // Extract the end date from format: "Izdato na period: DD-MM-YYYY - DD-MM-YYYY"
      final periodMatch = RegExp(r'Izdato na period:\s*\d{2}-\d{2}-\d{4}\s*-\s*(\d{2}-\d{2}-\d{4})').firstMatch(periodLine);
      
      if (periodMatch == null) {
        return true; // Consider as active if format doesn't match
      }
      
      final endDateStr = periodMatch.group(1)!;
      final dateParts = endDateStr.split('-');
      
      if (dateParts.length != 3) {
        return true; // Consider as active if date format is invalid
      }
      
      final endDate = DateTime(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[0]), // day
      );
      
      // Consider rental active if end date is today or in the future
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      return endDate.isAfter(todayDate) || endDate.isAtSameMomentAs(todayDate);
      
    } catch (e) {
      // If any parsing error occurs, consider the rental as active
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0, left: 80.0, right: 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Pregled iznajmljivanja: ${widget.bookTitle}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loadActiveRentals,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Osvježi podatke',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  _showExpiredRentals 
                    ? 'Prikaz svih iznajmljivanja za ovu knjigu'
                    : 'Prikaz aktivnih iznajmljivanja za ovu knjigu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      'Uključi istekla',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _showExpiredRentals,
                      onChanged: (value) {
                        setState(() {
                          _showExpiredRentals = value;
                        });
                        _loadActiveRentals();
                      },
                      activeColor: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: SearchLoadingIndicator(
          isVisible: true,
          text: 'Učitavanje iznajmljenih knjiga...',
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadActiveRentals,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_activeRentals.isEmpty) {
      return const EmptyState(
        icon: Icons.book_outlined,
        title: 'Nema iznajmljivanja',
        description: 'Ova knjiga trenutno nije iznajmljena nikome.',
      );
    }

    return _buildRentalsList();
  }

  Widget _buildRentalsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.book,
                  size: 32,
                  color: Colors.purple.shade600,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showExpiredRentals 
                        ? 'Ukupno iznajmljivanja'
                        : 'Aktivna iznajmljivanja',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
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
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Availability Timeline
        if (!_showExpiredRentals && _activeRentals.isNotEmpty)
          _buildAvailabilityTimeline(),
        
        const SizedBox(height: 16),
        
        // Rentals list
        Expanded(
          child: ListView.builder(
            itemCount: _activeRentals.length,
            itemBuilder: (context, index) {
              final rental = _activeRentals[index];
              return _buildRentalCard(rental);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dostupnost knjige',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prikaz dostupnosti u narednih 60 dana',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (_selectedDateInfo != null)
                  Text(
                    _selectedDateInfo!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTimelineVisualization(),
            const SizedBox(height: 12),
            _buildTimelineLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineVisualization() {
    final today = DateTime.now();
    const timelineDays = 60;
    final startDate = today;
    final endDate = today.add(const Duration(days: timelineDays));
    
    // Get all rental periods from active rentals
    List<DateRange> rentalPeriods = [];
    DateTime? earliestAvailable;
    
    for (var rental in _activeRentals) {
      final returnDateStr = _extractReturnDate(rental);
      if (returnDateStr != null) {
        try {
          final returnDate = _parseDate(returnDateStr);
          if (returnDate != null) {
            // Rental period from today to return date
            rentalPeriods.add(DateRange(today, returnDate));
            
            // Track earliest available date
            if (earliestAvailable == null || returnDate.isBefore(earliestAvailable)) {
              earliestAvailable = returnDate;
            }
          }
        } catch (e) {
        }
      }
    }
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: _buildTimelineSegments(startDate, endDate, rentalPeriods, earliestAvailable),
      ),
    );
  }

  List<Widget> _buildTimelineSegments(DateTime startDate, DateTime endDate, 
      List<DateRange> rentalPeriods, DateTime? earliestAvailable) {
    
    List<Widget> segments = [];
    final totalDays = endDate.difference(startDate).inDays;
    final today = DateTime.now();
    
    for (int day = 0; day < totalDays; day++) {
      final currentDate = startDate.add(Duration(days: day));
      final isToday = _isSameDay(currentDate, today);
      
      // Check if this day falls within any rental period
      bool isRented = false;
      for (var period in rentalPeriods) {
        if (_isDateInRange(currentDate, period)) {
          isRented = true;
          break;
        }
      }
      
      Color segmentColor;
      if (isRented) {
        segmentColor = Colors.red.shade400;
      } else if (earliestAvailable != null && currentDate.isAfter(earliestAvailable)) {
        segmentColor = Colors.green.shade400;
      } else {
        segmentColor = Colors.green.shade400;
      }
      
      // Check if this day should show a day marker (every 5 days)
      bool showDayMarker = day > 0 && (day + 1) % 5 == 0;
      
      Widget? childWidget;
      if (isToday) {
        childWidget = const Center(
          child: Icon(
            Icons.today,
            size: 16,
            color: Colors.white,
          ),
        );
      } else if (showDayMarker) {
        childWidget = Center(
          child: Text(
            '${day + 1}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      
      segments.add(
        Expanded(
          child: MouseRegion(
            onEnter: (_) => _showDateInfo(currentDate, isRented),
            onExit: (_) => _hideDateInfo(),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: segmentColor,
                border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
              ),
              child: childWidget,
            ),
          ),
        ),
      );
    }
    
    return segments;
  }

  Widget _buildTimelineLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLegendItem(Colors.red.shade400, 'Nedostupno (iznajmljeno)'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.green.shade400, 'Dostupno'),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.blue, 'Danas', Icons.today),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Postavite miš na bilo koji dan za prikaz datuma',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
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
            ? Icon(icon, size: 12, color: Colors.white)
            : null,
        ),
        const SizedBox(width: 4),
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

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
      }
    } catch (e) {
      // Parsing error
    }
    return null;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isDateInRange(DateTime date, DateRange range) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(range.start.year, range.start.month, range.start.day);
    final endOnly = DateTime(range.end.year, range.end.month, range.end.day);
    
    return (dateOnly.isAfter(startOnly) || dateOnly.isAtSameMomentAs(startOnly)) &&
           (dateOnly.isBefore(endOnly) || dateOnly.isAtSameMomentAs(endOnly));
  }

  void _showDateInfo(DateTime date, bool isRented) {
    setState(() {
      _selectedDateInfo = _formatDateInfo(date, isRented);
    });
  }

  void _hideDateInfo() {
    setState(() {
      _selectedDateInfo = null;
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

  String? _extractReturnDate(BookTransaction rental) {
    if (rental.data == null || rental.data!.isEmpty) {
      return null;
    }

    try {
      final lines = rental.data!.split('\n');
      for (var line in lines) {
        if (line.contains('Izdato na period:')) {
          final periodMatch = RegExp(r'Izdato na period:\s*\d{2}-\d{2}-\d{4}\s*-\s*(\d{2}-\d{2}-\d{4})').firstMatch(line);
          if (periodMatch != null) {
            return periodMatch.group(1)!;
          }
          break;
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    
    return null;
  }

  Widget _buildRentalCard(BookTransaction rental) {
    final returnDate = _extractReturnDate(rental);
    final isActive = _isRentalActive(rental);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.book,
                color: isActive ? Colors.green.shade600 : Colors.orange.shade600,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Iznajmljivanje #${rental.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Rental details
                  if (rental.data != null && rental.data!.isNotEmpty) ...[
                    ...rental.data!.split('\n').map((line) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          line,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    ).toList(),
                    const SizedBox(height: 4),
                  ],
                  
                  // Return date info
                  if (returnDate != null) ...[
                    Text(
                      'Povrat do: $returnDate',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  // Transaction info
                  Row(
                    children: [
                      Text(
                        'Količina: ${rental.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Izdano: ${_formatDate(rental.createdAt)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isActive ? Colors.green.shade200 : Colors.red.shade200),
              ),
              child: Text(
                isActive ? 'Aktivno' : 'Prosao rok',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
