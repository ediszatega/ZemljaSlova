import 'package:flutter/material.dart';
import '../models/book_transaction.dart';
import '../services/inventory_service.dart';
import '../services/api_service.dart';
import '../widgets/search_loading_indicator.dart';
import '../widgets/empty_state.dart';

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
      // Get all transactions for this book and filter for active rentals
      final allTransactions = await _inventoryService.getTransactionsById(widget.bookId);
      
      // Filter rental transactions (activityTypeId == 4)
      final allRentals = allTransactions.where((transaction) => 
        transaction.activityTypeId == 4
      ).toList();
      
      // Filter based on toggle: show only active or include expired
      final rentals = _showExpiredRentals 
        ? allRentals 
        : allRentals.where((transaction) => _isRentalActive(transaction)).toList();
      
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
